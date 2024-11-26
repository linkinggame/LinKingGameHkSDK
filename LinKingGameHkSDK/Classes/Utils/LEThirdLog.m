//
//  LEThirdLog.m
//  LinKingEnSDK
//
//  Created by leon on 2021/6/3.
//  Copyright © 2021 dml1630@163.com. All rights reserved.
//

#import "LEThirdLog.h"
#import <AppsFlyerLib/AppsFlyerLib.h>
#import <FBAudienceNetwork/FBAudienceNetwork.h>
@implementation LEThirdLog
+ (void)setThirdLog:(LEThirdLogLevel)level{
    
    if (level == LEThirdLogLevelOn) {
       
        // 开启 AppsFlyer
        [self setAppsFlyerisDebug:YES];
        
        [self setFBAdisDebug:YES];
        
    } else {
      
        // 关闭 AppsFlyer
        [self setAppsFlyerisDebug:NO];
        
        [self setFBAdisDebug:NO];
    }
}
+ (void)setAppsFlyerisDebug:(BOOL)isDebug{
    [AppsFlyerLib shared].isDebug = isDebug;
}
+ (void)setFBAdisDebug:(BOOL)isDebug{
    
    if (isDebug == YES) {
        [FBAdSettings setLogLevel:FBAdLogLevelLog];
    }else{
        [FBAdSettings setLogLevel:FBAdLogLevelNone];
        
    }
    
    
}

@end
