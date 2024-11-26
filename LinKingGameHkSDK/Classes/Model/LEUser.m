//
//  LEUser.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/10.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEUser.h"
#import "LEGlobalConf.h"
#import "LKLog.h"
#import "LEUserEntity.h"
@implementation LEUser
- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.userId = [NSString stringWithFormat:@"%@",dictionary[@"id"]];
        self.real_name = [NSString stringWithFormat:@"%@",dictionary[@"real_name"]];
        self.phone = [NSString stringWithFormat:@"%@",dictionary[@"phone"]];
        self.age = [NSString stringWithFormat:@"%@",dictionary[@"age"]];
        self.timestamp = [NSString stringWithFormat:@"%@",dictionary[@"timestamp"]];
        self.verify = [NSString stringWithFormat:@"%@",dictionary[@"verify"]];
        self.login_type = [NSString stringWithFormat:@"%@",dictionary[@"login_type"]];
        self.ppid = [NSString stringWithFormat:@"%@",dictionary[@"ppid"]];
        self.is_new_user = [NSString stringWithFormat:@"%@",dictionary[@"is_new_user"]];
        self.nick_name = [NSString stringWithFormat:@"%@",dictionary[@"nick_name"]];
        self.third_id = [NSString stringWithFormat:@"%@",dictionary[@"third_id"]];
        self.head_icon = [NSString stringWithFormat:@"%@",dictionary[@"head_icon"]];
        self.token = [NSString stringWithFormat:@"%@",dictionary[@"token"]];
        self.id_card = [NSString stringWithFormat:@"%@",dictionary[@"id_card"]];
        self.create_time = [NSString stringWithFormat:@"%@",dictionary[@"create_time"]];
        self.gender = [NSString stringWithFormat:@"%@",dictionary[@"gender"]];
    }
    return self;
}
// 解码
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        
        self.userId = [coder decodeObjectForKey:@"id"];
        self.real_name = [coder decodeObjectForKey:@"real_name"];
        self.phone = [coder decodeObjectForKey:@"phone"];
        self.age = [coder decodeObjectForKey:@"age"];
        self.timestamp = [coder decodeObjectForKey:@"timestamp"];
        self.verify = [coder decodeObjectForKey:@"verify"];
        self.login_type = [coder decodeObjectForKey:@"login_type"];
        self.ppid = [coder decodeObjectForKey:@"ppid"];
        self.is_new_user = [coder decodeObjectForKey:@"is_new_user"];
        self.nick_name = [coder decodeObjectForKey:@"nick_name"];
        self.third_id = [coder decodeObjectForKey:@"third_id"];
        self.head_icon = [coder decodeObjectForKey:@"head_icon"];
        self.token = [coder decodeObjectForKey:@"token"];
        self.id_card = [coder decodeObjectForKey:@"id_card"];
        self.create_time = [coder decodeObjectForKey:@"create_time"];
        self.gender = [coder decodeObjectForKey:@"gender"];
          
        
    }
    return self;
}

// 编码
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.userId forKey:@"id"];
    [coder encodeObject:self.real_name forKey:@"real_name"];
    [coder encodeObject:self.phone forKey:@"phone"];
    [coder encodeObject:self.age forKey:@"age"];
    [coder encodeObject:self.timestamp forKey:@"timestamp"];
    [coder encodeObject:self.verify forKey:@"verify"];
    [coder encodeObject:self.login_type forKey:@"login_type"];
    [coder encodeObject:self.ppid forKey:@"ppid"];
    [coder encodeObject:self.is_new_user forKey:@"is_new_user"];
    [coder encodeObject:self.nick_name forKey:@"nick_name"];
    [coder encodeObject:self.third_id forKey:@"third_id"];
    [coder encodeObject:self.head_icon forKey:@"head_icon"];
    [coder encodeObject:self.token forKey:@"token"];
    [coder encodeObject:self.id_card forKey:@"id_card"];
    [coder encodeObject:self.create_time forKey:@"create_time"];
    [coder encodeObject:self.gender forKey:@"gender"];

    
}

+ (LEUser *)getUser{
    // 先从内存中获取用户对象
    if ([LEUserEntity shared].user != nil) {
        return [LEUserEntity shared].user;
    }
    // 从沙盒中获取
    return [self getUserCachePrivate];
    
    
   
}

+ (LEUser *)getUserCachePrivate{
    
    // 或取本地数据
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:USERKEY];
    if(data == nil){
        LKLogInfo(@"No configuration information is available or obtained locally!!!");
       return nil;
    }

    if (@available(iOS 11.0, *)) {
        LEUser *user = (LEUser *)[NSKeyedUnarchiver unarchivedObjectOfClass:LEUser.class fromData:data error:nil];
        if (user != nil) {
            // 存入一份到本地
            [LEUserEntity shared].user = user;
        }else{
            LKLogInfo(@"===user对象为空===");
        }
         return user;
     } else {
         LEUser *user = [NSKeyedUnarchiver unarchiveObjectWithData:data];
         if (user != nil) {
             // 存入一份到本地
             [LEUserEntity shared].user = user;
         }else{
             LKLogInfo(@"===user对象为空===");
         }
          return user;
     }

}
+ (BOOL)supportsSecureCoding {
    return true;
}

+ (void)setUser:(LEUser *)user{

  
    // 先存入缓存
    [LEUserEntity shared].user = user;

    // 在存入沙盒
    [self setUserCachePrivate:user];
}

+ (void)setUserCachePrivate:(LEUser *)user{
    
    NSData *userData =nil;
    if (@available(iOS 11.0, *)) {
       userData = [NSKeyedArchiver archivedDataWithRootObject:user requiringSecureCoding:YES error:nil];
    } else {
       userData =[NSKeyedArchiver archivedDataWithRootObject:user];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:userData forKey:USERKEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (void)removeUserInfo{
    [LEUserEntity shared].user = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERKEY];
}
@end
