//
//  LEBaseApi.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/10.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEBaseApi.h"
#import "LEUUID.h"
#import "LENetUtils.h"
#import "LESystem.h"
#import "LEGlobalConf.h"
#import "LESDKConfig.h"
#import "LKLog.h"
#import "LEBundleUtil.h"
@implementation LEBaseApi
+ (NSString *)baseURL{

      LESDKConfig *configSDK = [LESDKConfig getSDKConfig];
    if (configSDK != nil) {
           NSString *base_ser_url = configSDK.auth_config[@"base_ser_url"];
           LESystem *system =  [LESystem getSystem];
           if (system != nil && system.appId != nil) {
               NSString *base = [NSString stringWithFormat:@"%@%@/",base_ser_url,system.appId];
               return base;
           }else{
               NSString *appId = [[NSUserDefaults standardUserDefaults] objectForKey:@"SDK_APPID"];
               if (appId != nil) {
                   NSString *base = [NSString stringWithFormat:@"%@%@/",base_ser_url,appId];
                   return base;
               }else{
                   LKLogInfo(@"⚠️appID不能为空⚠️");
               }
           }
    }else{
        LKLogInfo(@"⚠️SDK未初始化成功⚠️");
    }
     
    
    return nil;
    
}
+ (NSDictionary *)defaultParames{
       NSMutableDictionary *parames = [NSMutableDictionary dictionary];
       [parames setObject:@"ios" forKey:@"channel"];
       [parames setObject:@"AppStore" forKey:@"sub_channel"];
        [parames setObject:[LEUUID getUUID] forKey:@"device_id"];
       [parames setObject:[LENetUtils deviceInfo] forKey:@"device_info"];
       [parames setObject:[[UIDevice currentDevice] systemName] forKey:@"os"];
       [parames setObject:[LEBundleUtil getSDKVersion] forKey:@"version"];
        NSString *game_version =  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        [parames setObject:game_version forKey:@"game_version"]; //游戏版本
       // 获取随机字符串
       NSString *randString = [LENetUtils randomString];
       // 加密类型
       NSString *sign_type = @"MD5";
       
       [parames setObject:sign_type forKey:@"sign_type"];
       [parames setObject:randString forKey:@"nonce_str"];
     
    return parames;
}
+ (NSDictionary *)defaultParamesSimple{
       NSMutableDictionary *parames = [NSMutableDictionary dictionary];
       // 获取随机字符串
       NSString *randString = [LENetUtils randomString];
       // 加密类型
       NSString *sign_type = @"MD5";
       
       [parames setObject:sign_type forKey:@"sign_type"];
       [parames setObject:randString forKey:@"nonce_str"];
     
    return parames;
}
+ (NSError *)responserErrorMsg:(NSString *)msg{
    NSString *domain = @"com.linking.sdk.ErrorDomain";
        NSString *errorDesc = NSLocalizedString(msg, @"");
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : errorDesc };
        NSError *error = [NSError errorWithDomain:domain code:-101 userInfo:userInfo];
    return error;
}
+ (NSError *)responserErrorMsg:(NSString *)msg code:(int)code{
    NSString *domain = @"com.linking.sdk.ErrorDomain";
        NSString *errorDesc = NSLocalizedString(msg, @"");
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : errorDesc };
        NSError *error = [NSError errorWithDomain:domain code:code userInfo:userInfo];
    return error;
}
@end
