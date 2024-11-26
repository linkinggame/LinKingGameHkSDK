//
//  LESDKConfigApi.m
//  LinKingEnSDK
//
//  Created by MrDML on 2020/8/15.
//  Copyright © 2020 "". All rights reserved.
//

#import "LESDKConfigApi.h"
#import "LESystem.h"
#import "LEGlobalConf.h"
#import "LENetWork.h"
#import "LESDKConfig.h"
#import "LEUser.h"
#import "LELanguage.h"
#import "LKLog.h"
#import "LEBundleUtil.h"
#import "NSObject+LEAdditions.h"
//#define SDKConfBaseURL  @"http://lk-hkres.xxyzgame.com"
//#define SDKConfPrefix @"/bgsys/matrix"
@implementation LESDKConfigApi

/// 获取SDK配置文件
//+ (NSString *)getSDKConf{
//   LESystem *system = [LESystem getSystem];
//   NSString *string  = system.appID;
//    if ([string rangeOfString:@"_"].length > 0) {
//        NSArray *array = [string componentsSeparatedByString:@"_"];
//        NSString *appName = array[0];
//        NSString *urlStr = [NSString stringWithFormat:@"%@%@/%@/json/%@.json",SDKConfBaseURL,SDKConfPrefix,appName, system.appID];
//        return urlStr;
//    }
//    return nil;
//}

//+ (void)fetchSDKConfigComplete:(void(^_Nullable)(NSError *_Nullable error))complete{
//
//    NSString *url = [self getSDKConf];
//
//    [LENetWork getWithURLString:url success:^(id  _Nonnull responseObject) {
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//              LESDKConfig *sdkConfig = [[LESDKConfig alloc] initWithDictionary:responseObject];
//
//              [LESDKConfig setSDKConfig:sdkConfig];
//
//              complete(nil);
//        });
//
//    } failure:^(NSError * _Nonnull error) {
//        complete(error);
//    }];
//}


+ (void)fetchSDKConfigURLWithAppId:(NSString *)appId complete:(void(^_Nullable)(NSString * _Nullable url,NSError *_Nullable error))complete{
    NSString *configURL = [LEBundleUtil getConfigURL];
    LKLogInfo("configURL:%@",configURL);
    if (configURL != nil) {
        if (complete) {
            complete(configURL,nil); // 如果可以直接获取到配置SDK配置的json,就无需获取下面的接口获取了
            return;
        }
    }
    NSString *sdkVersion = [LEBundleUtil getSDKVersion];
    if (sdkVersion.exceptNull == nil) {
        sdkVersion = @"1.0.0";
    }
    NSString *configAPI = [LEBundleUtil getConfigAPI];
    // @"http://php-config-hk.xxyzgame.com/json.php"
    NSString *url = [NSString stringWithFormat:@"%@?g=%@&v=%@",configAPI,appId,sdkVersion];
    LKLogInfo("config--url:%@",url);
    [LENetWork getFromPhpithURLString:url success:^(id  _Nonnull responseObject) {
        LKLogInfo("responseObject:%@",responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSString *configURL = responseObject[@"url"];
            if (configURL.exceptNull != nil) {
                if (complete) {
                    complete(configURL,nil);
                }
            }else{
                NSError *custome_error = [self responserErrorMsg:@"数据为空" code:-1008];
                [self alterTipPhPAppId:appId info:custome_error.localizedDescription code:[NSString stringWithFormat:@"%d",(int)custome_error.code] complete:complete];
            }

        }else{
            NSError *custome_error = [self responserErrorMsg:@"数据解析失败" code:-1007];
            [self alterTipPhPAppId:appId info:custome_error.localizedDescription code:[NSString stringWithFormat:@"%d",(int)custome_error.code] complete:complete];
        }
    } failure:^(NSError * _Nonnull error) {
        static int phpcount = 1;
        if (phpcount <= 3 && phpcount > 0) {
            LKLogError(@"php重试次数:%d",phpcount);
            [self fetchSDKConfigURLWithAppId:appId complete:complete];
            phpcount += 1;
        }else{
            phpcount = 1;
            complete(nil,error);
            
            NSString *code = [NSString stringWithFormat:@"%ld",(long)error.code];
            
            [self alterTipPhPAppId:appId info:error.localizedDescription code:code complete:complete];
        }
    }];
    
}

+ (void)alterTipPhPAppId:(NSString *)appId info:(NSString*)info code:(NSString *)code complete:(void(^_Nullable)(NSString * _Nullable url,NSError *_Nullable error))complete{
    
    NSString *tip = [NSString stringWithFormat:@"%@(%@)，请重试",info,code];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertControler = [UIAlertController alertControllerWithTitle:@"温馨提示" message:tip preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confimAction = [UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self fetchSDKConfigURLWithAppId:appId complete:complete];

        }];
        [alertControler addAction:confimAction];
      
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertControler animated:YES completion:^{
            
        }];
    });
    

}



+ (void)fetchSDKConfigWithURL:(NSString *)url complete:(void(^_Nullable)(NSError *_Nullable error))complete{
    
    [LENetWork getWithURLString:url success:^(id  _Nonnull responseObject) {

        LESDKConfig *sdkConfig = [[LESDKConfig alloc] initWithDictionary:responseObject];
        [LESDKConfig setSDKConfig:sdkConfig];
        if (complete) {
            complete(nil);
        }
        
    } failure:^(NSError * _Nonnull error) {
        static int count = 1;
        if (count <= 3 && count > 0) {
            LKLogError(@"重试次数:%d",count);
            [self fetchSDKConfigWithURL:url complete:complete];
            count += 1;
        }else{
            count = 1;
            complete(error);
            
            NSString *code = [NSString stringWithFormat:@"%ld",(long)error.code];
            
            [self alterTipURL:url info:error.localizedDescription code:code complete:complete];
        }
    }];
}

+ (void)alterTipURL:(NSString *)url info:(NSString*)info code:(NSString *)code complete:(void(^_Nullable)(NSError *_Nullable error))complete{
    
    NSString *tip = [NSString stringWithFormat:@"%@(%@)，请重试",info,code];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertControler = [UIAlertController alertControllerWithTitle:@"温馨提示" message:tip preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confimAction = [UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self fetchSDKConfigWithURL:url complete:complete];

        }];
        [alertControler addAction:confimAction];
      
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertControler animated:YES completion:^{
            
        }];
    });
    

}




//+ (void)fetchSDKConfigAppId:(NSString *)appId complete:(void(^_Nullable)(NSError *_Nullable error))complete{
//
//    NSString *url = [self getSDKConf];
//    if (url == nil) {
//        if ([appId rangeOfString:@"_"].length > 0) {
//            NSArray *array = [appId componentsSeparatedByString:@"_"];
//            NSString *appName = array[0];
//            url = [NSString stringWithFormat:@"%@%@/%@/json/%@.json",SDKConfBaseURL,SDKConfPrefix,appName, appId];
//        }
//    }
//
//    LKLogInfo(@"request sdk config url:%@",url);
//
//    [LENetWork getWithURLString:url success:^(id  _Nonnull responseObject) {
//
//        LESDKConfig *sdkConfig = [[LESDKConfig alloc] initWithDictionary:responseObject];
//        [LESDKConfig setSDKConfig:sdkConfig];
//        if (complete) {
//            complete(nil);
//        }
//
//    } failure:^(NSError * _Nonnull error) {
//        static int count = 1;
//        if (count <= 3 && count > 0) {
//            LKLogError(@"重试次数:%d",count);
//            [self fetchSDKConfigAppId:appId complete:complete];
//            count += 1;
//        }else{
//            count = 1;
//            complete(error);
//
//            NSString *code = [NSString stringWithFormat:@"%ld",(long)error.code];
//
//            [self alterTipAppId:appId info:error.localizedDescription code:code complete:complete];
//        }
//    }];
//}
//



//+ (void)alterTipAppId:(NSString *)appId info:(NSString*)info code:(NSString *)code complete:(void(^_Nullable)(NSError *_Nullable error))complete{
//
//    NSString *tip = [NSString stringWithFormat:@"%@(%@)，请重试",info,code];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        UIAlertController *alertControler = [UIAlertController alertControllerWithTitle:@"温馨提示" message:tip preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *confimAction = [UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//            [self fetchSDKConfigAppId:appId complete:complete];
//
//        }];
//        [alertControler addAction:confimAction];
//
//        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertControler animated:YES completion:^{
//
//        }];
//    });
//
//
//}


+ (void)checkUserInfoComplete:(void(^)(NSError *error))complete{
    LEUser *user = [LEUser getUser];
    if (user != nil) {
        LESDKConfig *sdkConf = [LESDKConfig getSDKConfig];
        LESystem *system = [LESystem getSystem];
        NSString *urlStr = [NSString stringWithFormat:@"%@%@%@?token=%@&uid=%@",sdkConf.auth_config[@"base_ser_url"],system.appId,@"/user/check",user.token,user.userId];
        [LENetWork getWithURLString:urlStr success:^(id responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) {
                    complete(nil);
                }
           });

        } failure:^(NSError *error) {
            if (complete) {
                complete(error);
            }
        }];
    }
     
}

+ (void)checkUserInfoWithTime:(int)second complete:(void(^)(NSDictionary *result,NSError *error))complete{
    LEUser *user = [LEUser getUser];
    if (user != nil) {
         NSString *url = [NSString stringWithFormat:@"%@%@",[self baseURL],@"user/check_token"];
        
         NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[self defaultParamesSimple]];
         
        [parameters setObject:[NSNumber numberWithInt:second] forKey:@"time"];
        NSMutableDictionary *headers = [NSMutableDictionary dictionary];
        if ([LELanguage shared].preferredLanguage != nil) {
             [headers setObject:[LELanguage shared].preferredLanguage forKey:@"LK_LANGUAGE"];
        }
         [headers setObject:user.token forKey:@"LK_TOKEN"];
        [LENetWork postWithURLString:url parameters:parameters HTTPHeaderField:headers success:^(id  _Nonnull responseObject) {

            NSNumber *success = responseObject[@"success"];
            NSString *desc = responseObject[@"desc"];
             NSString *code = responseObject[@"code"];
            if ([success boolValue] == YES) {
                if (complete) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            complete(responseObject,nil);
                        });
                    }
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([code intValue] == 2234) {
                        if ([code intValue]) {
                            NSDictionary *data = responseObject[@"data"];
                            if ([data isKindOfClass:[NSDictionary class]]) {
                               NSString *userId = data[@"user_id"];
                               if (userId != nil) {
                                   [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"LKUSERID"];
                                   [[NSUserDefaults standardUserDefaults] synchronize];
                               }
                            }
                        }
                    }
                    
                    complete(responseObject,[self responserErrorMsg:desc code:[code intValue]]);
                });
            }
        } failure:^(NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil,error);
            });
        }];
    }else{
//        LKLogInfo(@"用户信息不存在,无法轮询");
    }

    
    
}

@end
