//
//  LEAppleProduct.m
//  LinKingArSDK
//
//  Created by leon on 2021/2/22.
//  Copyright © 2021 dml1630@163.com. All rights reserved.
//

#import "LEAppleProduct.h"
#import <StoreKit/StoreKit.h>
#import "LEGlobalConf.h"
#import "LEProduct.h"
#import "NSObject+LEAdditions.h"
#import "LEOrderApi.h"
#import "LEGoods.h"
#import "LESandBoxHelper.h"


static LEAppleProduct *_instance = nil;

@interface LEAppleProduct ()<SKProductsRequestDelegate>
@property (nonatomic, assign) BOOL isGetGoodsList; //是否是获取商品列表
@property (nonatomic, copy) void(^goodsListComplete)(NSError * _Nullable error, NSArray<LEGoods *>*_Nullable products); //商品列表集合
@end

@implementation LEAppleProduct

+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LEAppleProduct alloc] init];
    });
    return _instance;
}

/// 拉取所有商品信息
- (void)requestProductDatasComplete:(void(^_Nullable)(NSError * _Nullable error, NSArray*_Nullable products))complete{
    [LEOrderApi fetchtAppleProductDatasComplete:^(NSError * _Nonnull error, NSArray * _Nonnull results) {
          if (error == nil) {
              NSMutableArray *productIds = [NSMutableArray array];
              for (NSDictionary *dict in results) {
                  LEGoods *goods = [[LEGoods alloc] initWithDictionary:dict];

                    [productIds addObject:goods];
               }
              dispatch_async(dispatch_get_main_queue(), ^{
                  if (complete) {
                      complete(nil,productIds);
                  }
              });

          }else{
              
              dispatch_async(dispatch_get_main_queue(), ^{
                  if (complete) {
                      complete(error,nil);
                  }
              });
          }
          
      }];
}


/// 拉取苹果所有商品信息
- (void)requestProductFromeAppleDatasComplete:(void(^_Nullable)(NSError * _Nullable error, NSArray<LEGoods *>*_Nullable products))complete{
    [LEOrderApi fetchtAppleProductDatasComplete:^(NSError * _Nonnull error, NSArray * _Nonnull results) {
          if (error == nil) {
              NSMutableArray *productIds = [NSMutableArray array];
              for (NSDictionary *dict in results) {
                   NSString *productId = dict[@"id"];
                  if (productId.exceptNull != nil) {
                      [productIds addObject:productId];
                  }
              }
              if (complete) {
                  self.goodsListComplete = complete;
              }
              // 请求商品列表
              [self requestProductFromeAppleDatas:productIds];
          }else{
              dispatch_async(dispatch_get_main_queue(), ^{
                  if (complete) {
                      complete(error,nil);
                  }
              });
          }
          
      }];
}

/// 从游戏返回商品集合
- (void)requestProductFromeGameDatas:(NSArray *_Nonnull)productIds complete:(void(^_Nullable)(NSError * _Nullable error, NSArray<LEGoods *>*_Nullable products))complete{
    
    
    if (complete) {
        self.goodsListComplete = complete;
    }
    if (productIds != nil) {
        // 请求商品列表
        [self requestProductFromeAppleDatas:productIds];
    }

}


/// 从苹果获取多个商品ID，查询多个商品信息
/// @param productIds productIds description
- (void)requestProductFromeAppleDatas:(NSArray <NSString *>*)productIds{
    NSSet *nsset = [NSSet setWithArray:productIds];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
    request.delegate = self;
    [request start];
}
#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
     NSArray *products = response.products;
     NSMutableArray *goodsArray = [[NSMutableArray alloc] init];
   for(SKProduct *pro in products){
       
       LEGoods *goods = [[LEGoods alloc] init];
       
       NSNumberFormatter*numberFormatter = [[NSNumberFormatter alloc] init];
       [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
       [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
       [numberFormatter setLocale:pro.priceLocale];
       NSString*formattedPrice = [numberFormatter stringFromNumber:pro.price];//例如 ￥12.00
       
       goods.amount = pro.price;
       goods.goodsDescription = pro.localizedDescription;
       goods.priceLocale = formattedPrice;
       goods.name = pro.localizedTitle;
       goods.productId = pro.productIdentifier;
       
       [goodsArray addObject:goods];
       
   }
   
    if (self.goodsListComplete) {
        self.goodsListComplete(nil, goodsArray);
    }
    

}




@end
