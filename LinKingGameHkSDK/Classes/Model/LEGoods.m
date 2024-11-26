//
//  LEGoods.m
//  LinKingEnSDK
//
//  Created by leon on 2020/9/8.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEGoods.h"

@implementation LEGoods
- (instancetype)initWithDictionary:(NSDictionary *)product{
    self = [super init];
    if (self) {
        self.productId = product[@"id"];
        self.name = product[@"id"];
        self.num = product[@"num"];
        self.amount =  product[@"amount"];
     
    }
    return self;
}
@end
