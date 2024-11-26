//
//  LKLog.m
//  LinKingEnSDK
//
//  Created by leon on 2021/5/26.
//  Copyright © 2021 dml1630@163.com. All rights reserved.
//

#import "LKLog.h"

@implementation LKLog
#ifdef DEBUG

LKLogLevel lkLogLevel = LKLogLevelVerbose;

#else

LKLogLevel lkLogLevel = LKLogLevelWarning;

#endif


+ (void)setLogLevel:(LKLogLevel)logLevel{
    lkLogLevel = logLevel;
   
}

   
@end
