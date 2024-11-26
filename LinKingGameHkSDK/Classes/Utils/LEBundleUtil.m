//
//  LEBundleUtil.m
//  LinKingEnSDK
//
//  Created by leon on 2021/5/26.
//  Copyright © 2021 dml1630@163.com. All rights reserved.
//

#import "LEBundleUtil.h"
#import "LKLog.h"
#import "NSObject+LEAdditions.h"
@implementation LEBundleUtil

+ (NSDictionary *)getLinKingBundleInfo{
    NSBundle *bundle =  [NSBundle mainBundle];
    NSURL *bundleURL = [bundle bundleURL];
    NSURL *linkSDKURL = [bundleURL URLByAppendingPathComponent:@"LinKingGameHk.plist"];
   
    if (linkSDKURL == nil) {
        LKLogInfo(@"***************************");
        LKLogInfo(@"=====请将配置文件放置项目中=====");
        LKLogInfo(@"***************************");
        return nil;
    }
    NSDictionary *info = [NSDictionary dictionaryWithContentsOfURL:linkSDKURL];
    LKLogInfo(@"info:%@",info);
    return info[@"SDKINFO"];
}


+ (NSString *)getConfigAPI{
    NSDictionary *info = [self getLinKingBundleInfo];
    NSString *configURL = info[@"CONFIGAPI"];
    if (configURL.exceptNull == nil) {
        NSAssert(configURL.exceptNull != nil, @"CONFIGURL is empty");
    }
    return configURL;
}
+ (NSString *)getSysAPI{
    NSDictionary *info = [self getLinKingBundleInfo];
    NSString *configURL = info[@"SYSAPI"];
    if (configURL.exceptNull == nil) {
        NSAssert(configURL.exceptNull != nil, @"SYSAPI is empty");
    }
    return configURL;
}
+ (NSString *)getSysPrefix{
    NSDictionary *info = [self getLinKingBundleInfo];
    NSString *configURL = info[@"SYSPREFIX"];
    if (configURL.exceptNull == nil) {
        NSAssert(configURL.exceptNull != nil, @"SYSPREFIX is empty");
    }
    return configURL;
}
+ (NSString *)getConfigURL{
    NSDictionary *info = [self getLinKingBundleInfo];
    NSString *configURL = info[@"CONFIGURL"];
    if (configURL.exceptNull == nil) {
        return nil;
    }
    return configURL;
}

+ (NSString *)getSDKVersion{
    NSDictionary *info = [self getLinKingBundleInfo];
    NSString *game_version =  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (info == nil) {
        return game_version;
    }
    NSString *version = info[@"VERSION"];
    if (version.exceptNull == nil) {
        version = game_version;
    }
    return version;
}

+ (NSString *)getReportedLogURL{
    NSDictionary *info = [self getLinKingBundleInfo];
    NSString *errorLog = @"";
    if (info == nil) {
        return errorLog;
    }
    NSString *log_url = info[@"LOGURL"];
    if (log_url.exceptNull == nil) {
        log_url =  errorLog;
    }
    return log_url;
}

/// 是否允许广告追踪
+ (BOOL)getTracKing {
    NSDictionary *info = [self getLinKingBundleInfo];

    if ([[info allKeys] containsObject:@"TRACKING"]) {
        BOOL isAllow = [info[@"TRACKING"] boolValue];
        return isAllow;
    } else {
        return NO;
    }
}

@end
