//
//  LESystem.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/10.
//  Copyright © 2020 "". All rights reserved.
//

#import "LESystem.h"
#import "LEGlobalConf.h"
#import "LKLog.h"
@implementation LESystem
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

// 解码
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        
        self.loginStyle = [coder decodeObjectForKey:@"loginStyle"];
        self.token = [coder decodeObjectForKey:@"token"];
        self.userToken = [coder decodeObjectForKey:@"userToken"];
        self.gameId = [coder decodeObjectForKey:@"gameId"];
        self.appId = [coder decodeObjectForKey:@"appId"];
        self.secretkey = [coder decodeObjectForKey:@"secretkey"];
        self.matrixLanguage = [coder decodeObjectForKey:@"matrixLanguage"];
        
    }
    return self;
}

// 编码
- (void)encodeWithCoder:(NSCoder *)coder
{
     [coder encodeObject:self.loginStyle forKey:@"loginStyle"];
     [coder encodeObject:self.token forKey:@"token"];
     [coder encodeObject:self.userToken forKey:@"userToken"];
     [coder encodeObject:self.gameId forKey:@"gameId"];
     [coder encodeObject:self.appId forKey:@"appId"];
     [coder encodeObject:self.secretkey forKey:@"secretkey"];
     [coder encodeObject:self.matrixLanguage forKey:@"matrixLanguage"];
    
}
+ (BOOL)supportsSecureCoding {
    return true;
}

+ (LESystem *)getSystem{
    //获取本地数据
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SYSTEMSDKKEY];
    if(data == nil){
        LKLogInfo(@"No configuration information is available or obtained locally!!!");
       return [[LESystem alloc] init];
    }
   if (@available(iOS 11.0, *)) {
        LESystem *system = (LESystem *)[NSKeyedUnarchiver unarchivedObjectOfClass:LESystem.class fromData:data error:nil];
        return system;
    } else {
        LESystem *system = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return system;
    }
   
}



+ (void)clearSystemConf{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SYSTEMSDKKEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (void)setSystem:(LESystem *)system{

   [[NSUserDefaults standardUserDefaults] removeObjectForKey:SYSTEMSDKKEY];
    NSData *sdkConfData =nil;
    if (@available(iOS 11.0, *)) {
       sdkConfData = [NSKeyedArchiver archivedDataWithRootObject:system requiringSecureCoding:YES error:nil];
    } else {
       sdkConfData =[NSKeyedArchiver archivedDataWithRootObject:system];
    }
    [[NSUserDefaults standardUserDefaults] setObject:sdkConfData forKey:SYSTEMSDKKEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
