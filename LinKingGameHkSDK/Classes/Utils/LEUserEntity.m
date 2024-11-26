//
//  LEUserEntity.m
//  LinKingEnSDK
//
//  Created by leon on 2021/6/4.
//  Copyright © 2021 dml1630@163.com. All rights reserved.
//

#import "LEUserEntity.h"

@implementation LEUserEntity
static LEUserEntity *_instance = nil;
+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LEUserEntity alloc] init];
    });
    return _instance;
}

@end
