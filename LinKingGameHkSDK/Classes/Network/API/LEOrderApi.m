//
//  LEOrderApi.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/18.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEOrderApi.h"
#import "LESystem.h"
#import "LEGlobalConf.h"
#import "LELanguage.h"
#import "NSObject+LEAdditions.h"
#import "LENetWork.h"
#import "LESDKConfig.h"
#import "LEUser.h"
#import "LKLog.h"
#import "LEBundleUtil.h"
//#define SDKConfBaseURL  @"http://lk-hkres.xxyzgame.com"
//#define SDKConfBaseURL @"https://lk-hkres.chiji-h5.com"
//#define SDKConfPrefix @"/bgsys/matrix"
@implementation LEOrderApi
+ (void)orderRecordQuery:(NSString *)fullDate month:(NSString *)month complete:(void(^)(NSError *error,NSArray *records))complete{

         NSString *url = [NSString stringWithFormat:@"%@%@",[self baseURL],@"pay/record_query"];
        
         NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[self defaultParamesSimple]];
         
        [parameters setObject:fullDate forKey:@"one_month"];
        [parameters setObject:month forKey:@"month"];
    
       
        NSMutableDictionary *headers = [NSMutableDictionary dictionary];
        if ([LELanguage shared].preferredLanguage != nil) {
             [headers setObject:[LELanguage shared].preferredLanguage forKey:@"LK_LANGUAGE"];
        }
         LEUser *user = [LEUser getUser];
         
         [headers setObject:user.token forKey:@"LK_TOKEN"];

        [LENetWork postWithURLString:url parameters:parameters HTTPHeaderField:headers success:^(id  _Nonnull responseObject) {

            NSNumber *success = responseObject[@"success"];
            NSString *desc = responseObject[@"desc"];
            NSDictionary *data = responseObject[@"data"];
            if ([success boolValue] == YES) {
                   dispatch_async(dispatch_get_main_queue(), ^{
                       if (complete) {
                           NSArray *records = data[@"records"];
                           complete(nil,records);
                       }
                   });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete([self responserErrorMsg:desc],nil);
                });
            }
        } failure:^(NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(error,nil);
            });
        }];
    
    
}

+ (void)createOrderType:(NSString *)type withParameters:(NSDictionary *)parames complete:(void(^)(NSError *error, NSDictionary*result))complete{
    NSString *url = [NSString stringWithFormat:@"%@%@",[self baseURL],@"pay/create"];
     
      NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[self defaultParamesSimple]];
 
     for (NSString *key in parames.allKeys) {
         
         [parameters setObject:parames[key] forKey:key];
     }
     

 
     NSMutableDictionary *headers = [NSMutableDictionary dictionary];
 
      LEUser *user = [LEUser getUser];
      
      [headers setObject:user.token forKey:@"LK_TOKEN"];

     [LENetWork postWithURLString:url parameters:parameters HTTPHeaderField:headers success:^(id _Nonnull responseObject) {
         if (complete) {
             complete(nil,responseObject);
         }
         
     } failure:^(NSError * _Nonnull error) {
         if (complete) {
             complete(error,nil);
         }
     }];

}
/*
 {
   "success" : true,
   "code" : null,
   "data" : {
     "order_no" : "1286121524264435712",
     "body" : "ok",
     "paypal_token" : null,
     "wechat_body" : {
       "partnerid" : "1596630141",
       "return_code" : "SUCCESS",
       "paySign" : "CA6B55E9C64030A647845CD75C434A92",
       "package" : "Sign=WXPay",
       "noncestr" : "CNiGM5CI0GQyPsO2",
       "timestamp" : "1595470241423",
       "appid" : "wx68f4cb8ec2696459",
       "prepayid" : "wx231010413558752e1cf44a711476672500"
     }
   },
   "desc" : null
 }
 
 **/



+ (void)appleFinishOrderNum:(NSString *)orderNum receipt:(NSString *)receipt subscribe:(BOOL)subscribe complete:(void(^)(NSError *error, NSDictionary*result))complete{
    
         NSString *url = [NSString stringWithFormat:@"%@%@",[self baseURL],@"pay/finish"];
        
         NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[self defaultParamesSimple]];
    
          [parameters setObject:@"ios" forKey:@"type"];
          [parameters setObject:orderNum forKey:@"order_no"];
          [parameters setObject:receipt forKey:@"receipt"];
          [parameters setObject:[NSNumber numberWithBool:subscribe] forKey:@"subscribe"];
//          [parameters setObject:amount forKey:@"amount"];
    
         NSMutableDictionary *headers = [NSMutableDictionary dictionary];
            if ([LELanguage shared].preferredLanguage != nil) {
                 [headers setObject:[LELanguage shared].preferredLanguage forKey:@"LK_LANGUAGE"];
            }
         LEUser *user = [LEUser getUser];
         
         [headers setObject:user.token forKey:@"LK_TOKEN"];

        [LENetWork postWithURLString:url parameters:parameters HTTPHeaderField:headers success:^(id  _Nonnull responseObject) {

            NSNumber *success = responseObject[@"success"];
            NSString *desc = responseObject[@"desc"];
            NSDictionary *data = responseObject[@"data"];
            if ([success boolValue] == YES) {
                   dispatch_async(dispatch_get_main_queue(), ^{
                       if (complete) {
                           NSDictionary *result = data;
                           complete(nil,result);
                       }
                   });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete([self responserErrorMsg:desc],nil);
                });
            }
        } failure:^(NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(error,nil);
            });
        }];
    
    
    
}

/// 获取支付配信息
+ (NSString *)getSDKPayConf{
    
     LESystem *system = [LESystem getSystem];
      NSString *string  = system.appId;
    if (string == nil) {
       string = [[NSUserDefaults standardUserDefaults] objectForKey:@"SDK_APPID"];
     }
      if ([string rangeOfString:@"_"].length > 0) {
          NSArray *array = [string componentsSeparatedByString:@"_"];
          NSString *appName = array[0];
//           NSString *urlStr = [NSString stringWithFormat:@"%@%@/%@/json/%@_product.json",SDKConfBaseURL,SDKConfPrefix,appName, system.appID];
          
          // https://lk-hkres.chiji-h5.com/bgsys/matrix/SoccerClubTycoon/json/SoccerClubTycoon_ios_product.json
          // https://lk-sdk-hk.chiji-h5.com/bgsys/matrix/SoccerClubTycoon/json/SoccerClubTycoon_ios_product.json
          NSString *sysBaseUrl =  [LEBundleUtil getSysAPI];
          NSString *sysBasePrefix = [LEBundleUtil getSysPrefix];
          NSString *urlStr = [NSString stringWithFormat:@"%@%@/%@/json/%@_product.json",sysBaseUrl,sysBasePrefix,appName, system.appId];
           return urlStr;
          
      }
    
    return nil;
}

+ (void)fetchtAppleProductDatasComplete:(void(^)(NSError *error, NSArray*results))complete{
    
    NSString *url = [self getSDKPayConf];
    //@"http://lk-hzres.oss-cn-hangzhou.aliyuncs.com/bgsys/matrix/qmscs/json/qmscs_ios_product.json";
        
    [LENetWork getWithURLString:url success:^(id  _Nonnull responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            if (complete) {
                complete(nil,responseObject);
            }
        }

    } failure:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(error,nil);
            }
        });
    }];

}
+ (void)querySubscribeProduct:(NSString *)productId Complete:(void(^)(NSError *error, NSDictionary*results))complete{
    
        
     NSString *url = [NSString stringWithFormat:@"%@%@",[self baseURL],@"pay/subscribe_query"];
    
     NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[self defaultParamesSimple]];

      [parameters setObject:@"ios" forKey:@"type"];
      [parameters setObject:productId forKey:@"product_id"];


     NSMutableDictionary *headers = [NSMutableDictionary dictionary];

     LEUser *user = [LEUser getUser];
     
     [headers setObject:user.token forKey:@"LK_TOKEN"];

    [LENetWork postWithURLString:url parameters:parameters HTTPHeaderField:headers success:^(id  _Nonnull responseObject) {

        NSNumber *success = responseObject[@"success"];
        NSString *desc = responseObject[@"desc"];
        NSDictionary *data = responseObject[@"data"];
        if ([success boolValue] == YES) {
               dispatch_async(dispatch_get_main_queue(), ^{
                   if (complete) {
                       NSDictionary *result = data;
                       complete(nil,result);
                   }
               });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                complete([self responserErrorMsg:desc],nil);
            });
        }
    } failure:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(error,nil);
        });
    }];

}
+ (void)appleFinishOrderNum:(NSString *)orderNum receipt:(NSString *)receipt transactionIdentifier:(NSString *)transactionIdentifier subscribe:(BOOL)subscribe complete:(void(^)(NSError *error, NSDictionary*result))complete{
    
    NSString *url = [NSString stringWithFormat:@"%@%@",[self baseURL],@"pay/finish"];
   
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[self defaultParamesSimple]];

     [parameters setObject:@"ios" forKey:@"type"];
     [parameters setObject:orderNum forKey:@"order_no"];
     [parameters setObject:receipt forKey:@"receipt"];
       if (transactionIdentifier.exceptNull != nil) {
           [parameters setObject:transactionIdentifier forKey:@"client_original_transaction_id"];
       }
     [parameters setObject:[NSNumber numberWithBool:subscribe] forKey:@"subscribe"];

    NSMutableDictionary *headers = [NSMutableDictionary dictionary];

    LEUser *user = [LEUser getUser];
    
   if (user != nil && user.token.exceptNull != nil) {
       [headers setObject:user.token forKey:@"LK_TOKEN"];
   }else{
       LKLogInfo(@"user:%@ ; user.token:%@",user,user.token);
   }

   [LENetWork postWithURLString:url parameters:parameters HTTPHeaderField:headers success:^(id  _Nonnull responseObject) {


       
       if (complete) {
           complete(nil,responseObject);
       }
   } failure:^(NSError * _Nonnull error) {
       
       if (complete) {
           complete(error,nil);
       }
   }];
}
@end
