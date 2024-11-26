//
//  LEMatrixApi.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/18.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEMatrixApi.h"
#import "LESystem.h"
#import "LEGlobalConf.h"
#import "LELanguage.h"
#import "NSObject+LEAdditions.h"
#import "LENetWork.h"
#import "LESDKConfig.h"
#import "LEBundleUtil.h"
//#define SDKConfBaseURL  @"http://lk-hkres.xxyzgame.com"
//#define SDKConfBaseURL @"https://lk-hkres.chiji-h5.com"
//#define SDKConfPrefix @"/bgsys/matrix"
@implementation LEMatrixApi
///// 获取SDK矩阵配置文件 
+ (NSString *)getSDKMatrixConf{
  NSString *language =  [LELanguage shared].preferredLanguage;
    if (language.exceptNull != nil) {
        if ([language rangeOfString:@"zh"].location != NSNotFound) {
            language = @"zh";
        }
    }
    NSString *baseUrl = [LESDKConfig getSDKConfig].auth_config[@"base_ser_url"];
    LESystem *system = [LESystem getSystem];
     NSString *string  = system.appId;
      if ([string rangeOfString:@"_"].length > 0) {
          NSArray *array = [string componentsSeparatedByString:@"_"];
          NSString *appName = array[0];
          
          
          NSString *sysBaseUrl =  [LEBundleUtil getSysAPI];
          NSString *sysBasePrefix = [LEBundleUtil getSysPrefix];
          NSString *urlStr = [NSString stringWithFormat:@"%@%@/%@/json/%@_%@.json",sysBaseUrl,sysBasePrefix,appName,appName,language];
          
         
           return urlStr;
          
      }
    
    return nil;
}
+ (void)fetchMatrixConfigComplete:(void(^)(NSError *_Nullable error,id _Nullable responseObject))complete{
    
    NSString *url = [self getSDKMatrixConf];
   
    
    [LENetWork getWithURLString:url success:^(id  _Nonnull responseObject) {

        dispatch_async(dispatch_get_main_queue(), ^{
              
              complete(nil,responseObject);
        });
        
    } failure:^(NSError * _Nonnull error) {
        complete(error,nil);
    }];
}
@end
