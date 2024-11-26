//
//  LEProduct.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/10.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEProduct.h"
#import <StoreKit/StoreKit.h>
@implementation LEProduct
- (instancetype)initWithArray:(SKProduct *)product
{
    self = [super init];
    if (self) {
        self.productId = product.productIdentifier;
        self.desc = [product description];
        self.localizedTitle = [product localizedTitle];
        self.localizedDescription = [product localizedDescription];
        self.price = [product price];
    }
    return self;
}
@end
