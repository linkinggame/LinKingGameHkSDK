//
//  LEAdConfInfo.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/17.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEAdConfInfo.h"
#import "LESDKConfig.h"
@interface LEAdConfInfo ()

@end
static LEAdConfInfo *_instance = nil;
@implementation LEAdConfInfo
+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LEAdConfInfo alloc] init];
    });
    return _instance;
}
/// 获取广告的配置信息，返回具体某一种类型的广告字典信息
- (NSDictionary *)getAdConfInfo:(NSString *)key{
    LESDKConfig *sdkConf = [LESDKConfig getSDKConfig];
    NSDictionary *Audience_Dict = nil;
    if (sdkConf != nil) {
        if ([sdkConf.ad_config_ios isKindOfClass:[NSDictionary class]]) {
            NSDictionary *AD_CONFI_Dict = sdkConf.ad_config_ios;
            if ([AD_CONFI_Dict isKindOfClass:[NSDictionary class]]) {
                Audience_Dict = AD_CONFI_Dict[key];
            }
        }
    }
    return Audience_Dict;
}
// 获取广告加载比例
- (NSArray *)getAdConfInfos:(NSString *)key{
    LESDKConfig *sdkConf = [LESDKConfig getSDKConfig];
    NSArray *arrayPrs = nil;
    if (sdkConf != nil) {
        if ([sdkConf.ad_config_ios isKindOfClass:[NSDictionary class]]) {
            NSDictionary *AD_CONFI_Dict = sdkConf.ad_config_ios;
            if ([AD_CONFI_Dict isKindOfClass:[NSDictionary class]]) {
                arrayPrs = AD_CONFI_Dict[key];
            }
        }
    }
    return arrayPrs;
}
@end
