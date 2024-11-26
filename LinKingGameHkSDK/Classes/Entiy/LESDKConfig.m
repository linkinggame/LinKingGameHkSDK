//
//  LESDKConfig.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/10.
//  Copyright © 2020 "". All rights reserved.
//

#import "LESDKConfig.h"
#import "LEGlobalConf.h"
#import "LKLog.h"
@implementation LESDKConfig
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.ready_type = [NSString stringWithFormat:@"%@",dictionary[@"ready_type"]];
        self.pay_type = [NSString stringWithFormat:@"%@",dictionary[@"pay_type"]];
        self.mode_debug = dictionary[@"mode_debug"];
        self.wsy = dictionary[@"wsy"];
        self.sdk_config = dictionary[@"sdk_config"];
        self.wx_config = dictionary[@"wx_config"];
        self.auth_config = dictionary[@"auth_config"];
        self.point_config = dictionary[@"point_config"];
        self.ad_config_ios = dictionary[@"ad_config_ios"];
        self.share_info = dictionary[@"share_info"];
        self.updateGame = dictionary[@"updateGame"];
        self.pay_config = dictionary[@"pay_config"];
    }
    return self;
}
// 解码
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.ready_type =  [coder decodeObjectForKey:@"ready_type"];
        self.pay_type =[coder decodeObjectForKey:@"pay_type"];
        self.mode_debug =[coder decodeObjectForKey:@"mode_debug"];
        self.wsy = [coder decodeObjectForKey:@"wsy"];
        self.sdk_config = [coder decodeObjectForKey:@"sdk_config"];
        self.wx_config =[coder decodeObjectForKey:@"wx_config"];
        self.auth_config =[coder decodeObjectForKey:@"auth_config"];
        self.point_config= [coder decodeObjectForKey:@"point_config"];
        self.ad_config_ios =[coder decodeObjectForKey:@"ad_config_ios"];
        self.share_info = [coder decodeObjectForKey:@"share_info"];
        self.updateGame = [coder decodeObjectForKey:@"updateGame"];
        self.pay_config = [coder decodeObjectForKey:@"pay_config"];
    }
    return self;
}

// 编码
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.ready_type forKey:@"ready_type"];
    [coder encodeObject:self.pay_type forKey:@"pay_type"];
    [coder encodeObject:self.mode_debug forKey:@"mode_debug"];
    [coder encodeObject:self.wsy forKey:@"wsy"];
    [coder encodeObject:self.sdk_config forKey:@"sdk_config"];
    [coder encodeObject:self.wx_config forKey:@"wx_config"];
    [coder encodeObject:self.auth_config forKey:@"auth_config"];
    [coder encodeObject:self.point_config forKey:@"point_config"];
    [coder encodeObject:self.ad_config_ios forKey:@"ad_config_ios"];
    [coder encodeObject:self.share_info forKey:@"share_info"];
    [coder encodeObject:self.updateGame forKey:@"updateGame"];
    [coder encodeObject:self.updateGame forKey:@"pay_config"];
}

+ (LESDKConfig *)getSDKConfig{
    // 或取本地数据
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SDKCONFKEY];
    if(data == nil){
        LKLogInfo(@"No configuration information is available or obtained locally!!!");
       return nil;
    }

    if (@available(iOS 11.0, *)) {
        NSError *error = nil;
         LESDKConfig *sdkConfig = (LESDKConfig *)[NSKeyedUnarchiver unarchiveTopLevelObjectWithData:data error:&error];
         return sdkConfig;
     } else {
         LESDKConfig *sdkConfig = [NSKeyedUnarchiver unarchiveObjectWithData:data];
          return sdkConfig;
     }
    
   
}
+ (BOOL)supportsSecureCoding {
    return true;
}

+ (void)setSDKConfig:(LESDKConfig *)config{
       [[NSUserDefaults standardUserDefaults] removeObjectForKey:SDKCONFKEY];
    NSData *configData =nil;
    if (@available(iOS 11.0, *)) {
       configData = [NSKeyedArchiver archivedDataWithRootObject:config requiringSecureCoding:YES error:nil];
    } else {
       configData =[NSKeyedArchiver archivedDataWithRootObject:config];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:configData forKey:SDKCONFKEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    

}

+ (void)removeSDKConfig{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SDKCONFKEY];
}
@end
