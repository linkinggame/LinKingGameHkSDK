//
//  LEUUID.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/10.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEUUID.h"
#import "LEKeyChainStore.h"
@implementation LEUUID
+ (NSString *)getUUID
{
    

    NSString *bundleIdentifier = @"com.linkingen.wwww";

   
    NSString * strUUID = (NSString *)[LEKeyChainStore load:bundleIdentifier];
    
    //首次执行该方法时，uuid为空
    if ([strUUID isEqualToString:@""] || !strUUID)
    {
        
        //生成一个uuid的方法
        
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        
        strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
        
        //将该uuid保存到keychain
        
        [LEKeyChainStore save:bundleIdentifier data:strUUID];
        
    }
    return strUUID;
}
@end
