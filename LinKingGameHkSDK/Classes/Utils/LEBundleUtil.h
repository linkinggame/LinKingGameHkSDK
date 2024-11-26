//
//  LEBundleUtil.h
//  LinKingEnSDK
//
//  Created by leon on 2021/5/26.
//  Copyright © 2021 dml1630@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LEBundleUtil : NSObject
+ (NSDictionary *)getLinKingBundleInfo;
+ (NSString *)getConfigURL;
+ (NSString *)getConfigAPI;
+ (NSString *)getSysAPI;
+ (NSString *)getSysPrefix;
+ (NSString *)getSDKVersion;
+ (NSString *)getReportedLogURL;
/// 是否允许广告追踪
+ (BOOL)getTracKing;
@end

NS_ASSUME_NONNULL_END
