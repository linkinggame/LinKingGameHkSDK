//
//  LEPointApi.m
//  LinKingEnSDK
//
//  Created by MrDML on 2020/8/16.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEPointApi.h"
#import "LEGlobalConf.h"
#import "LEUUID.h"
#import "LENetUtils.h"
#import "LESystem.h"
#import "LESDKConfig.h"
#import "NSObject+LEAdditions.h"
#import "UIImage+LEAdditions.h"
#import "NSBundle+LEAdditions.h"
#import "LESDKConfig.h"
#import "LEUser.h"
#import "LENetWork.h"
#import <Toast/Toast.h>
#import "LKLog.h"
#import "LEBundleUtil.h"

@implementation LEPointApi
+ (void)pointEventName:(NSString *)eventName withTp:(NSString *)tp withValues:(NSDictionary *)values complete:(void(^)(NSError *error))complete{
    
        if ([self isStartSLS]) {
    
            LKLogInfo(@"开启SLS日志收集");
            [self sls_pointEventName:eventName withTp:tp withValues:values complete:complete];
        }else{
            LKLogInfo(@"使用平台日志收集");
            [self originPointEventName:eventName withTp:tp withValues:values complete:complete];
        }
        
    
}

+ (void)adPointEventName:(NSString *)eventName withValues:(NSDictionary *)values complete:(void(^)(NSError *error))complete{
    
        if ([self isStartSLS]) {
            LKLogInfo(@"ad开启SLS日志收集");
            [self sls_adPointEventName:eventName withValues:values complete:complete];
        }else{
            LKLogInfo(@"ad使用平台日志收集");
            [self originadPointEventName:eventName withValues:values complete:complete];
        }

    
}
+ (BOOL)isStartSLS{
    LESDKConfig *sdkConfig =[LESDKConfig getSDKConfig];
    
    id object = sdkConfig.point_config[@"lk"];
   
    NSDictionary *lk = (NSDictionary *)object;
    
    NSNumber *sls_enable = lk[@"sls_enable"]; // 是否启用
    LKLogInfo(@"是否开始SLS日志上报==%d",[sls_enable intValue]);
    return [sls_enable boolValue];
}
+ (void)sls_adPointEventName:(NSString *)eventName withValues:(NSDictionary *)values complete:(void(^)(NSError *error))complete{
    
    LEUser *user = [LEUser getUser];
    if (user != nil) {
             LESDKConfig *sdkConfig =[LESDKConfig getSDKConfig];
          
          if (sdkConfig == nil) {
              LKLogInfo(@"⚠️SDK未初始化成功⚠️");
              return;
          }
          
          id object = sdkConfig.point_config[@"lk"];
          if (![object isKindOfClass:[NSDictionary class]]) {
              LKLogInfo(@"⚠️数据格式错误⚠️");
              return;
          }
          
          NSDictionary *lk = (NSDictionary *)object;
          
          NSString *sls_base_uri = lk[@"sls_base_uri"];
          
         
          if (sls_base_uri.exceptNull == nil) {
              LKLogInfo(@"⚠️SDK未初始化成功⚠️");
              return;
          }
        
        // 封装参数
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:@"linking" forKey:@"__topic__"];
        [parameters setValue:@"sdk" forKey:@"__source__"];
        
        NSMutableDictionary *logParamters = [NSMutableDictionary dictionaryWithDictionary:values];
        [logParamters setObject:@"ios" forKey:@"channel"];
        [logParamters setObject:@"AppStore" forKey:@"sub_channel"];
        [logParamters setObject:[LEUUID getUUID] forKey:@"device_id"];
        [logParamters setObject:[LENetUtils deviceInfo] forKey:@"device_info"];
        LESystem *system = [LESystem getSystem];
        [logParamters setObject:system.appId forKey:@"app_id"];
        [logParamters setObject:eventName forKey:@"event"];
        [logParamters setObject:user.userId forKey:@"user_id"];
        [logParamters setObject:[NSString stringWithFormat:@"%@",user.is_new_user] forKey:@"is_new"]; // 是否是新用户
        
        [logParamters setObject:system.appId forKey:@"app_id"];
        [logParamters setObject:[LEBundleUtil getSDKVersion] forKey:@"version"];
        NSString *game_version =  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        [logParamters setObject:game_version forKey:@"game_version"];

        // 海外新增country字段
        NSString * country = [self getCountry];
       if (country.exceptNull != nil) {
           [logParamters setObject:country forKey:@"country"];
        }
        
        
        NSMutableArray *logArray = [NSMutableArray array];
        [logArray addObject:logParamters];
       
        [parameters setObject:logArray forKey:@"__logs__"];
        
        
        NSMutableDictionary *tagsParamters = [NSMutableDictionary dictionary];
        [tagsParamters setObject:@"linking-sdk" forKey:@"ak"];
        [tagsParamters setObject:@"ad" forKey:@"tp"];

        [tagsParamters setObject:game_version forKey:@"game_version"]; //游戏版本
    
        [parameters setObject:tagsParamters forKey:@"__tags__"];
     
        
        
       // 封装请求头
        NSMutableDictionary *headParamters = [NSMutableDictionary dictionary];
        [headParamters setObject:@"application/json" forKey:@"Content-Type"];
        [headParamters setObject:@"0.6.0" forKey:@"x-log-apiversion"];
        [headParamters setObject:@"1234" forKey:@"x-log-bodyrawsize"];
      
        
        LKLogInfo(@"parameters:===>%@",parameters);
        
        [LENetWork postNormalWithURLString:sls_base_uri parameters:parameters HTTPHeaderField:headParamters success:^(id  _Nonnull responseObject) {
            LKLogInfo(@"sls ad point 上报成功");
            if (complete) {
                complete(nil);
            }
          } failure:^(NSError * _Nonnull error) {
              LKLogInfo(@"sls ad point 上报失败%@",error);
              if (complete) {
                  complete(error);
              }
        }];
        
        
        
    }else{
        LKLogInfo(@"用户信息为空");
    }
    
    
}

+ (void)sls_pointEventName:(NSString *)eventName withTp:(NSString *)tp withValues:(NSDictionary *)values complete:(void(^)(NSError *error))complete{
    LEUser *user = [LEUser getUser];
    if ([eventName isEqualToString:@"Activation"] || [eventName isEqualToString:@"StartUp"]) {
        LKLogInfo(@"不校验用户");
    }else{
        LEUser *userTmp = [LEUser getUser];
        if (userTmp == nil) {
            LKLogInfo(@"⚠️用户信息为空⚠️");
            return;
        }
    }

    
    LESDKConfig *sdkConfig =[LESDKConfig getSDKConfig];
    
    if (sdkConfig == nil) {
        LKLogInfo(@"⚠️SDK未初始化成功⚠️");
        return;
    }
    
    id object = sdkConfig.point_config[@"lk"];
    if (![object isKindOfClass:[NSDictionary class]]) {
        LKLogInfo(@"⚠️数据格式错误⚠️");
        return;
    }
    
    NSDictionary *lk = (NSDictionary *)object;
    
    NSString *sls_base_uri = lk[@"sls_base_uri"];
    
   
    if (sls_base_uri.exceptNull == nil) {
        LKLogInfo(@"⚠️SDK未初始化成功⚠️");
        return;
    }
    
    
    // 封装参数
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"linking" forKey:@"__topic__"];
    [parameters setValue:@"sdk" forKey:@"__source__"];
    
    NSMutableDictionary *logParamters = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryValueCovertStringStyle:values]];
    [logParamters setObject:@"ios" forKey:@"channel"];
    [logParamters setObject:@"AppStore" forKey:@"sub_channel"];
    [logParamters setObject:[LEUUID getUUID] forKey:@"device_id"];
    [logParamters setObject:[LENetUtils deviceInfo] forKey:@"device_info"];
    [logParamters setObject:eventName forKey:@"event"];
    LESystem *system = [LESystem getSystem];
    [logParamters setObject:system.appId forKey:@"app_id"];
    if (user != nil && user.userId.exceptNull != nil) {
        [logParamters setObject:user.userId forKey:@"user_id"];
    }
    [logParamters setObject:[LEBundleUtil getSDKVersion] forKey:@"version"];
    NSString *game_version =  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [logParamters setObject:game_version forKey:@"game_version"];

    
    
    // 海外新增country字段
     NSString * country = [self getCountry];
    if (country.exceptNull != nil) {
        [logParamters setObject:country forKey:@"country"];
     }

    
    NSMutableArray *logArray = [NSMutableArray array];
    [logArray addObject:logParamters];
   
    [parameters setObject:logArray forKey:@"__logs__"];
    
    NSMutableDictionary *tagsParamters = [NSMutableDictionary dictionary];
    [tagsParamters setObject:@"linking-sdk" forKey:@"ak"];

    [tagsParamters setObject:game_version forKey:@"game_version"]; //游戏版本
    [tagsParamters setObject:tp forKey:@"tp"]; // 事件

    [parameters setObject:tagsParamters forKey:@"__tags__"];
 
    
   // 封装请求头
    NSMutableDictionary *headParamters = [NSMutableDictionary dictionary];
    [headParamters setObject:@"0.6.0" forKey:@"x-log-apiversion"];
    [headParamters setObject:@"1234" forKey:@"x-log-bodyrawsize"];
    
    [LENetWork postNormalWithURLString:sls_base_uri parameters:parameters HTTPHeaderField:headParamters success:^(id  _Nonnull responseObject) {
        LKLogInfo(@"sls ad point 上报成功");
        if (complete) {
            complete(nil);
        }
      } failure:^(NSError * _Nonnull error) {
          LKLogInfo(@"sls ad point 上报失败%@",error);
          if (complete) {
              complete(error);
          }
    }];
    
    
    
}


+ (void)originPointEventName:(NSString *)eventName withTp:(NSString *)tp withValues:(NSDictionary *)values complete:(void(^)(NSError *error))complete{
    LEUser *user = [LEUser getUser];
    if ([eventName isEqualToString:@"Activation"] || [eventName isEqualToString:@"StartUp"]) {
        LKLogInfo(@"不校验用户");
    }else{
        LEUser *userTmp = [LEUser getUser];
        if (userTmp == nil) {
            LKLogInfo(@"⚠️用户信息为空⚠️");
            return;
        }
    }
    
    LESDKConfig *sdkConfig =[LESDKConfig getSDKConfig];
    
    if (sdkConfig == nil) {
        LKLogInfo(@"⚠️SDK未初始化成功⚠️");
        return;
    }
    
    id object = sdkConfig.point_config[@"lk"];
    if (![object isKindOfClass:[NSDictionary class]]) {
        LKLogInfo(@"⚠️数据格式错误⚠️");
        return;
    }
    
    NSDictionary *lk = (NSDictionary *)object;
    
    NSString *log_base_uri = lk[@"log_base_uri"];
    
   
    if (log_base_uri.exceptNull == nil) {
        LKLogInfo(@"⚠️SDK未初始化成功⚠️");
        return;
    }
     
     NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryValueCovertStringStyle:values]];
     NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
      
    [dictionary setObject:@"ios" forKey:@"channel"];
    [dictionary setObject:@"AppStore" forKey:@"sub_channel"];
    [dictionary setObject:[LEUUID getUUID] forKey:@"device_id"];
    [dictionary setObject:[LENetUtils deviceInfo] forKey:@"device_info"];
    [dictionary setObject:eventName forKey:@"event"];
    
    [dictionary setObject:[LEBundleUtil getSDKVersion] forKey:@"version"];
    NSString *game_version =  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [dictionary setObject:game_version forKey:@"game_version"];
    // 海外新增country字段
    NSString * country = [self getCountry];
   if (country.exceptNull != nil) {
       [dictionary setObject:country forKey:@"country"];
    }
    
    LESystem *system = [LESystem getSystem];
    [dictionary setObject:system.appId forKey:@"app_id"];
    if (user != nil && user.userId.exceptNull != nil) {
        [dictionary setObject:user.userId forKey:@"user_id"];
    }
 
    [parameters setObject:@"linking-sdk" forKey:@"ak"];
    [parameters setObject:tp forKey:@"tp"];
    NSString *json = [self dictionaryToJson:dictionary];
    [parameters setObject:json forKey:@"param"];

    [LENetWork postWithURLString:log_base_uri parameters:parameters success:^(id  _Nonnull responseObject) {
        NSNumber *success = responseObject[@"success"];
        NSString *desc = responseObject[@"desc"];
        if ([success boolValue] == YES) {
            if (complete) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        complete(nil);
                    });
                }
        }else{
            if (complete) {
                complete([self responserErrorMsg:desc]);
            }
            
        }
    } failure:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(error);
            }
            
        });
    }];
     
     return;
    
}

+ (void)originadPointEventName:(NSString *)eventName withValues:(NSDictionary *)values complete:(void(^)(NSError *error))complete{
    LEUser *user = [LEUser getUser];
    if (user != nil) {
             LESDKConfig *sdkConfig =[LESDKConfig getSDKConfig];
          
          if (sdkConfig == nil) {
              LKLogInfo(@"⚠️SDK未初始化成功⚠️");
              return;
          }
          
          id object = sdkConfig.point_config[@"lk"];
          if (![object isKindOfClass:[NSDictionary class]]) {
              LKLogInfo(@"⚠️数据格式错误⚠️");
              return;
          }
          
          NSDictionary *lk = (NSDictionary *)object;
          
          NSString *log_base_uri = lk[@"log_base_uri"];
          
         
          if (log_base_uri.exceptNull == nil) {
              LKLogInfo(@"⚠️SDK未初始化成功⚠️");
              return;
          }
           

         NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:values];
         NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
          
        [dictionary setObject:@"ios" forKey:@"channel"];
        [dictionary setObject:@"AppStore" forKey:@"sub_channel"];
        [dictionary setObject:[LEUUID getUUID] forKey:@"device_id"];
        [dictionary setObject:[LENetUtils deviceInfo] forKey:@"device_info"];
        LESystem *system = [LESystem getSystem];
        [dictionary setObject:system.appId forKey:@"app_id"];
        [dictionary setObject:eventName forKey:@"event"];
        [dictionary setObject:user.userId forKey:@"user_id"];
        
        [dictionary setObject:[LEBundleUtil getSDKVersion] forKey:@"version"];
        NSString *game_version =  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        [dictionary setObject:game_version forKey:@"game_version"];
        // 海外新增country字段
        NSString * country = [self getCountry];
       if (country.exceptNull != nil) {
           [dictionary setObject:country forKey:@"country"];
        }
        [dictionary setObject:[NSNumber numberWithInt:[[NSString stringWithFormat:@"%@",user.is_new_user] intValue]] forKey:@"is_new"]; // 是否是新用户

        
        [parameters setObject:@"linking-sdk" forKey:@"ak"];
        [parameters setObject:@"Ad" forKey:@"tp"];
        NSString *json = [self dictionaryToJson:dictionary];
        [parameters setObject:json forKey:@"param"];
        
        
          NSMutableDictionary *headers = [NSMutableDictionary dictionary];
          [headers setObject:user.token forKey:@"LK_TOKEN"];
         [LENetWork postWithURLString:log_base_uri parameters:parameters HTTPHeaderField:headers success:^(id  _Nonnull responseObject) {

             NSNumber *success = responseObject[@"success"];
             NSString *desc = responseObject[@"desc"];
             if ([success boolValue] == YES) {
                 if (complete) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             complete(nil);
                         });
                     }
             }else{
                 dispatch_async(dispatch_get_main_queue(), ^{
                     complete([self responserErrorMsg:desc]);
                 });
             }
         } failure:^(NSError * _Nonnull error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 complete(error);
             });
         }];
    }else{
        LKLogInfo(@"⚠️用户信息为空⚠️");
    }

     

    
}
+ (void)logReportServerWithEvent:(NSString *)event eventName:(NSString *)eventName infos:(NSDictionary *_Nullable)infos WithOtherLogInfo:(NSDictionary*_Nullable)logInfors complete:(void(^_Nullable)(NSError *_Nullable error))complete{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"linking" forKey:@"__topic__"];
    [parameters setValue:@"sdk" forKey:@"__source__"];
    
    NSMutableArray *logArray = [NSMutableArray array];
    if (logInfors != nil) {
        // 转换成json字符串、
       NSString *jsonString = [self dictionaryToJson:logInfors];
        NSDictionary *content = [NSDictionary dictionaryWithObjectsAndKeys:jsonString,@"conctent", nil];
        [logArray addObject:content];
    }else{
        NSDictionary *content = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"conctent", nil];
        [logArray addObject:content];
    }
   
    [parameters setObject:logArray forKey:@"__logs__"];
    
    NSMutableDictionary *tagsParamters = [NSMutableDictionary dictionaryWithDictionary:infos];
    [tagsParamters setObject:@"linking-sdk" forKey:@"ak"];
    [tagsParamters setObject:event forKey:@"event"];
    [tagsParamters setObject:eventName forKey:@"eventName"];
    // 海外新增country字段
    NSString * country = [self getCountry];
   if (country.exceptNull != nil) {
       [tagsParamters setObject:country forKey:@"country"];
    }
    
    [parameters setObject:tagsParamters forKey:@"__tags__"];
    
    
    
    NSMutableDictionary *headParamters = [NSMutableDictionary dictionary];
    [headParamters setObject:@"application/json" forKey:@"Content-Type"];
    [headParamters setObject:@"0.6.0" forKey:@"x-log-apiversion"];
    [headParamters setObject:@"1234" forKey:@"x-log-bodyrawsize"];
    
    
    LKLogInfo(@"report-log-info:%@",parameters);
    
    NSString *reportedLogUR = [LEBundleUtil getReportedLogURL];
    [LENetWork postNormalWithURLString:reportedLogUR parameters:parameters HTTPHeaderField:headParamters success:^(id  _Nonnull responseObject) {
        LKLogInfo(@"===上报结果成功===");
        } failure:^(NSError * _Nullable error) {
            LKLogInfo(@"===上报结果失败%@===",error);
    }];

}


+ (NSDictionary *)dictionaryValueCovertStringStyle:(NSDictionary *)dict{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (NSString *key in dict.allKeys) {
        NSString *val = [NSString stringWithFormat:@"%@",dict[key]];
        [result setObject:val forKey:key];
        
    }
    return  result;
    
}


//将字典转化为字符串
+ (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
     
}

+ (NSMutableDictionary *)getReportLogInfo{
    LESystem *system = [LESystem getSystem];
    LEUser *user = [LEUser getUser];
    NSString *appId = system.appId.exceptNull != nil ? system.appId : @"";
    NSString *userId = user.userId.exceptNull != nil ? user.userId : @"";
    NSString *version = [LEBundleUtil getSDKVersion].exceptNull != nil ? [LEBundleUtil getSDKVersion] : @"";
    NSString *gameVersion =  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
     
    NSMutableDictionary *infor = [NSMutableDictionary dictionary];
    [infor setObject:appId forKey:@"appId"];
    [infor setObject:userId forKey:@"userId"];
    [infor setObject:version forKey:@"version"];
    [infor setObject:gameVersion forKey:@"gameVersion"];
    [infor setObject:@"ios" forKey:@"channel"];
    [infor setObject:@"AppStore" forKey:@"subChannel"];
    [infor setObject:[LEUUID getUUID] forKey:@"deviceId"];
    [infor setObject:[LENetUtils deviceInfo] forKey:@"deviceInfo"];
    return infor;
    
}

+ (NSString *)getCountry{
    
    NSString *area = nil;
    // 海外新增country字段
    // zh-Hant_CN
    // zh-Hant_TW@CALENDAR=BUDDHIST
    NSString *localeLanguageCode = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];
   if ([localeLanguageCode rangeOfString:@"_"].location != NSNotFound) {
       NSArray *languages = [localeLanguageCode componentsSeparatedByString:@"_"];
       area = languages.lastObject;
       //有的机型可能返回 TW@CALENDAR=BUDDHIST
       if ([area rangeOfString:@"@"].location != NSNotFound) {
           NSArray *languages_fix = [area componentsSeparatedByString:@"@"];
           area = languages_fix.firstObject;
       }
   }
    return area;
}


@end
