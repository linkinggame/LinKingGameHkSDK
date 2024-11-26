//
//  LENetUtils.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/10.
//  Copyright © 2020 "". All rights reserved.
//

#import "LENetUtils.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <UIKit/UIKit.h>
#import "LESystem.h"
#import "LKLog.h"
@implementation LENetUtils
/**
 随机字符串
 */
+ (NSString *)randomString {
    
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    
    srand(time(0)); // 此行代码有警告:
    
    for (int i = 0; i < kNumber; i++) {
        
        unsigned index = rand() % [sourceStr length];
        
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        
        [resultStr appendString:oneStr];
    }
    return resultStr;
}
/*
 * 给字符串md5加密
 */
+ (NSString*)md5Str:(NSString *)str
{
    const char *ptr = [str UTF8String];

    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];

    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02X",md5Buffer[i]];
    
    return output;
}

// 获取签名
+ (NSString *)getSignData:(NSDictionary *)parameters
{
   NSArray *parameterNames = [parameters allKeys];
    
   parameterNames = [parameterNames sortedArrayUsingSelector:@selector(compare:)];// 字符串编码升序排序
       
     NSString *signData = @"";
    for (int i = 0; i < [parameters count]; i++) {
        NSString *_key = parameterNames[i];
        if (_key != nil) {
             id  _value = parameters[_key];
            if ([_value isKindOfClass:[NSNumber class]]) {
                
                if ([_key isEqualToString:@"subscribe"]) {
                    
                    if ([_value boolValue] == YES) {
                        _value = [NSString stringWithFormat:@"%@",@"true"];
                    }else{
                        _value = [NSString stringWithFormat:@"%@",@"false"];
                    }
                }else{
                    _value = [NSString stringWithFormat:@"%@",_value];
                }
                
                
             
            }
             signData = [signData stringByAppendingString:_value];
        }
    }
    
    LESystem *system = [LESystem getSystem];
    
//    if (system.secretkey == nil) {
//        system.secretkey = @"test";
//    }
    LKLogInfo(@"<==========>");
    LKLogInfo(@"secretkey = %@",system.secretkey);
    LKLogInfo(@"<==========>");
    NSString *signKey = system.secretkey;
    if (signKey == nil) {
        signKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"SDK_SECRETKEY"];
    }
    signData = [signData stringByAppendingString:signKey];
      
    return [self md5Str:signData];
}
//将字典转化为字符串
+(NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}

/**
  设备信息
 */
+ (NSString *)deviceInfo{
    NSString* userPhoneName = [[UIDevice currentDevice] name];  //手机别名： 用户定义的名称
    NSString* deviceName = [[UIDevice currentDevice] systemName];//设备名称
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];//手机系统版本 os版本
    NSString* phoneModel = [[UIDevice currentDevice] model];//手机型号
    NSString* localPhoneModel = [[UIDevice currentDevice] localizedModel];//地方型号  （国际化区域名称）
    
    NSString *info = [NSString stringWithFormat:@"%@:%@:%@:%@:%@",userPhoneName,deviceName,phoneVersion,phoneModel,localPhoneModel];
    return info;
}
@end
