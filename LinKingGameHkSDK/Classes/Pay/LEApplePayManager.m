//
//  LEApplePayManager.m
//  LinKingEnSDK
//
//  Created by leoan on 2020/9/8.
//  Copyright © 2020 dml1630@163.com. All rights reserved.
//

#import "LEApplePayManager.h"
#import <StoreKit/StoreKit.h>
#import "LEGlobalConf.h"
#import "LEProduct.h"
#import "NSObject+LEAdditions.h"
#import "LEOrderApi.h"
#import "LEGoods.h"
#import "LESandBoxHelper.h"
#import "LEUser.h"
#import "LEFBAnalyticsManager.h"
#import "LKLog.h"
#import "LEPointApi.h"
#import <AppsFlyerLib/AppsFlyerLib.h>
static NSString * const receiptKey = @"receipt";
static NSString * const dateKey = @"date_key";
static NSString * const orderIdKey = @"order_no";
static NSString * const amountKey = @"amount";
static NSString * const cpOrderNoKey = @"cp_order_no";
static NSString * const productIdKey = @"product_id";
static NSString * const userIdKey = @"user_id";
dispatch_queue_t iap_queue() {
    static dispatch_queue_t as_iap_queue;
    static dispatch_once_t onceToken_iap_queue;
    dispatch_once(&onceToken_iap_queue, ^{
        as_iap_queue = dispatch_queue_create("com.iap.queue", DISPATCH_QUEUE_CONCURRENT);
    });
    return as_iap_queue;
}
@interface LEApplePayManager ()<SKPaymentTransactionObserver, SKProductsRequestDelegate>{
    CompletionHandle _complete;
}
@property (nonatomic, assign) BOOL goodsRequestFinished; //判断一次请求是否完成

@property (nonatomic, copy) NSString *receipt; //交易成功后拿到的一个64编码字符串

@property (nonatomic, copy) NSString *date; //交易时间

@property (nonatomic, strong) NSString *orderId; //订单id
@property (nonatomic, strong) NSString *amount; //订单金额(打点使用)
@property (nonatomic, strong) NSString *cp_order_no; //cp_order_no订单(打点使用)
@property (nonatomic, strong) NSString *productId; //商品id
@property (nonatomic, strong) NSDictionary *orderParams; // 订单参数

@end
static LEApplePayManager *_instance = nil;
@implementation LEApplePayManager

+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LEApplePayManager alloc] init];
    });
    
    return _instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        // 购买监听写在程序入口,程序挂起时移除监听,这样如果有未完成的订单将会自动执行并回调 paymentQueue:updatedTransactions:方法
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)dealloc{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

/**
 启动工具
 */
- (void)startManager{
    self.goodsRequestFinished = YES;
}


/**
 结束工具
 */
- (void)stopManager{}

// 查询订阅
- (void)querysubscribeProduct:(NSString *)productId Complete:(void(^)(NSError *error, NSDictionary*results))complete{
    
    [LEOrderApi querySubscribeProduct:productId Complete:^(NSError * _Nonnull error, NSDictionary * _Nonnull results) {
        if (complete) {
            complete(error,results);
        }
    }];
}

/// 拉取所有商品信息
- (void)itemsListOnFinished:(void(^)(NSError * _Nullable error, NSArray*_Nullable products))complete{
    
    [self requestProductDatasComplete:complete];
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



//开始内购
- (void)statrtProductWithId:(NSString *)productId parames:(NSDictionary *)parames completeHandle:(CompletionHandle)handle{

    // 开始购买
    [self statrtPrivateProductWithId:productId parames:parames completeHandle:handle];

}

/**
 开始购买
 */
- (void)statrtPrivateProductWithId:(NSString *)productId parames:(NSDictionary *)parames completeHandle:(CompletionHandle)handle{
    if (self.goodsRequestFinished) {
        self.amount = parames[amountKey];
        self.cp_order_no = parames[cpOrderNoKey];
        self.productId = productId;
        // 请求下单接口
          _complete = handle;

        self.orderParams = parames;

        if ([SKPaymentQueue canMakePayments]) { //用户允许app内购
            if (productId.exceptNull != nil) {
                LKLogInfo(@"%@商品正在请求中",productId);
                self.goodsRequestFinished = NO; //正在请求
                
                NSArray *product = @[productId];
                NSSet *set = [NSSet setWithArray:product];
                
                SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
                request.delegate = self;
                [request start];
            } else {
                [self handleActionWithType:PurchNoGoods error:[self responserErrorMsg:@"没有商品" code:-101]];
                self.goodsRequestFinished = YES; //完成请求
            }
        } else { //没有权限
            
            [self handleActionWithType:PurchNotArrow error:[self responserErrorMsg:@"没有权限" code:-102]];
            self.goodsRequestFinished = YES; //完成请求
        }
    }else{
        [self handleActionWithType:PurchOrderNoComplete error:[self responserErrorMsg:@"订单未完成" code:-103]];
    }
    

}



- (NSError *)responserErrorMsg:(NSString *)msg code:(int)code{
    if (msg.exceptNull == nil) {
        msg = @"系统错误";
    }
       NSString *domain = @"com.linking.sdk.ErrorDomain";
        NSString *errorDesc = NSLocalizedString(msg, @"");
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : errorDesc };
        NSError *error = [NSError errorWithDomain:domain code:code userInfo:userInfo];
    return error;
}

#pragma mark SKProductsRequestDelegate 查询成功后的回调
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSArray *products = response.products;
    
    if (products.count <= 0) {
        
        
        [self handleActionWithType:PurchNoGoods error:[self responserErrorMsg:@"没有商品" code:-101]];
        
        self.goodsRequestFinished = YES; //失败，请求完成
        [self logPayBehaviourReportWithProductId:self.productId WithEvent:@"NO_GOODS" WithEventName:@"没有商品" WithOrderId:@"" WithReceipt:@"" WithTransactionIdentifier:@"" WithAllOrders:nil];
        
    } else {
        //发起购买请求
        LKLogInfo(@"请求商品集合:%@",products);
        SKProduct *product = products[0];
        if ([product.productIdentifier isEqualToString:self.productId]) {
            LKLogInfo(@"正在请求的商品:%@",product);

            [self logPayBehaviourReportWithProductId:self.productId WithEvent:@"WILL_CREATE_ORDER" WithEventName:@"即将创建订单" WithOrderId:@"" WithReceipt:@"" WithTransactionIdentifier:@"" WithAllOrders:nil];
            
            // 下单请求
            [self createOrderRequest:product];
        }else{
            LKLogInfo(@"product.productIdentifier = %@,self.productId = %@； 不一致",product.productIdentifier,self.productId);
            [self logPayBehaviourReportWithProductId:self.productId WithEvent:@"WILL_CREATE_ORDER" WithEventName:[NSString stringWithFormat:@"商品id%@-%@",product.productIdentifier,self.productId] WithOrderId:@"" WithReceipt:@"" WithTransactionIdentifier:@"" WithAllOrders:nil];
            self.goodsRequestFinished = YES; //下单失败，请求完成
        }
       
    }
}

- (void)createOrderRequest:(SKProduct *)product{
    [LEOrderApi createOrderType:@"ios" withParameters:self.orderParams complete:^(NSError * _Nullable error, NSDictionary * _Nonnull result) {
       
        if (error == nil) {
            
            NSNumber *success = result[@"success"];
            NSString *desc = result[@"desc"];
            NSString *code = [NSString stringWithFormat:@"%@",result[@"code"]];
            NSDictionary *data = result[@"data"];
            
            if ([success boolValue] == YES) {
                
                NSString* order_no = nil;
                order_no  = data[@"order_no"];
                self.orderId = order_no;
                
                // 发起苹果购买请求
                [self startApplePaymentWithProduct:product];
                
                // 创建订单成功日志
                [self logPayBehaviourReportWithProductId:self.productId WithEvent:@"CREATE_ORDER_SUCCESS" WithEventName:@"创建订单成功" WithOrderId:order_no WithReceipt:@"" WithTransactionIdentifier:@"" WithAllOrders:nil];
                
                // 保存订单信息
                [self saveOrderInfoWithOrderId:order_no];
                
                
            }else{
                
                NSError *err = [self responserErrorMsg:desc code:[code intValue]];
                // 展示信息
                [self showResponse:err.localizedDescription];
                
                [self handleActionWithType:PurchOrderFail error:err];
                self.goodsRequestFinished = YES; //下单失败，请求完成
                // 上报日志
                [self logPayBehaviourReportWithProductId:product.productIdentifier WithEvent:@"CREATE_ORDER_FAILE" WithEventName:@"创建订单失败" WithOrderId:[NSString stringWithFormat:@"error:%@-code:%ld",err.localizedDescription,(long)err.code] WithReceipt:@"" WithTransactionIdentifier:@"" WithAllOrders:nil];
            }
            
            
        }else{
            // 网络请求超时
            [self handleActionWithType:PurchServiceFail error:error];
            self.goodsRequestFinished = YES; //下单失败，请求完成
            
            // 上报日志
            [self logPayBehaviourReportWithProductId:product.productIdentifier WithEvent:@"CREATE_ORDER_REQUEST_FAILE" WithEventName:[NSString stringWithFormat:@"%@-error:%@",@"创建订单接口无响应",error.localizedDescription] WithOrderId:@"" WithReceipt:@"" WithTransactionIdentifier:@"" WithAllOrders:nil];
        }
        
     }];
}

- (void)showResponse:(NSString *)message{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:message preferredStyle:UIAlertControllerStyleAlert];
         [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
 
         }]];
         [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)startApplePaymentWithProduct:(SKProduct *)product{
    //发起购买请求
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    payment.applicationUsername = self.orderId;
    LKLogInfo(@"applicationUsername:%@",payment.applicationUsername);
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

// 保存订单信息
- (void)saveOrderInfoWithOrderId:(NSString *)orderId{
    LKLogInfo(@"currentThread:%@",[NSThread currentThread]);
    LEUser *user = [LEUser getUser];
    if (user != nil) {
        [self saveReceipt:nil withOrderId:orderId];
    }else{
        LKLogInfo(@"用户信息为空");
    }

}

#pragma mark 获取交易成功后的购买凭证
- (NSString *)getReceipt {
    
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
    NSString * receipt = [receiptData base64EncodedStringWithOptions:0];
    self.receipt = receipt;
    return receipt;
}


/// 移除已完成或者失效的票据
- (void)removeReceipt{
    NSMutableArray *orderList = [self getMyAllOrders];
    NSDictionary *orderInfo = [self getCurrentOrderInfo:self.productId];
    if (orderInfo != nil) {
        [orderList removeObject:orderInfo];

        // 重新写入
        NSDictionary *dict = [self getReceiptFromeFile];
        NSMutableDictionary *outDict= [NSMutableDictionary dictionaryWithDictionary:dict];
        LEUser *user = [LEUser getUser];
        NSString *key = [NSString stringWithFormat:@"%@_key",user.userId];
        if (user != nil && user.userId.exceptNull != nil) {
            // 重新写入list
            [outDict setObject:orderList forKey:key];
        }
        
        NSString *path = [NSString stringWithFormat:@"%@/order.plist",[LESandBoxHelper iapReceiptPath]];
        LKLogInfo(@"outDict:%@",outDict);
        [outDict writeToFile:path atomically:YES];
    }
    self.receipt = nil;
    self.orderId = nil;
    self.productId = nil;
    self.amount = nil;
    self.cp_order_no = nil;

    
}

#pragma mark  持久化存储用户购买凭证(这里最好还要存储当前日期，用户id等信息，用于区分不同的凭证)
- (void)saveReceipt:(SKPaymentTransaction *)transaction withOrderId:(NSString *)orderId{

    LEUser *user = [LEUser getUser];
    if (user == nil || user.userId.exceptNull == nil) {
        return;
    }
    NSString *userId = user.userId;
    // key 用户id value 字典数组
    
    NSDictionary *dict = [self getReceiptFromeFile];
    NSMutableDictionary *outDict=  [NSMutableDictionary dictionaryWithDictionary:dict];
    NSString *key = [NSString stringWithFormat:@"%@_key",userId];
    
    
    if (transaction != nil) {
        if (self.productId.exceptNull == nil) {
            self.productId = transaction.payment.productIdentifier;
        }
    }
    LKLogInfo(@"self.productId:%@",self.productId);
    // 当前的订单字典
    NSDictionary *orderInfo = [self getCurrentOrderInfo:self.productId];
    
    // 我所有的订单集合数组
    NSMutableArray *myAllOrders = [self getMyAllOrders];
    
    // 我新的订单集合数组
    NSMutableArray *newMyAllOrders = [NSMutableArray array];
   
    
    if (orderInfo != nil) {
        
        // 如果存在取出后更新订单里面的值，然后在覆盖掉
        NSMutableDictionary *map = [NSMutableDictionary dictionaryWithDictionary:orderInfo];
        if (self.receipt.exceptNull != nil) {
            [map setObject:self.receipt forKey:receiptKey];
        }
        if (self.date.exceptNull != nil) {
            [map setObject:self.date forKey:dateKey];
        }
        if (orderId.exceptNull != nil) {
            
            [map setObject:orderId forKey:orderIdKey];
        }
        if (self.amount.exceptNull != nil) {
            [map setObject:self.amount forKey:amountKey];
        }
        if (self.cp_order_no.exceptNull != nil) {
            [map setObject:self.cp_order_no forKey:cpOrderNoKey];
        }
        if (userId.exceptNull != nil) {
            [map setObject:userId forKey:userIdKey];
        }
        if (self.productId.exceptNull != nil) {
            [map setObject:self.productId forKey:productIdKey];
        }
        
        
        for (NSDictionary *dict in myAllOrders) {
            NSString *productId = dict[productIdKey];
            if ([self.productId isEqualToString:productId]) {
                [newMyAllOrders addObject:map];
            }else{
                [newMyAllOrders addObject:dict];
            }
        }
        
        [outDict setObject:newMyAllOrders forKey:key];
        
        
    }else{
        
        // 如果不存在向我的集合数组中新增一个
        // 如果订单id为nil说明不是下单新增 而是苹果主动消费
        if (orderId.exceptNull == nil) {
            return;
        }
        
        // 如果存在取出后更新订单里面的值，然后在覆盖掉
        NSMutableDictionary *map = [NSMutableDictionary dictionaryWithDictionary:orderInfo];
        if (self.receipt.exceptNull != nil) {
            [map setObject:self.receipt forKey:receiptKey];
        }
        if (self.date.exceptNull != nil) {
            [map setObject:self.date forKey:dateKey];
        }
        if (orderId.exceptNull != nil) {
            [map setObject:orderId forKey:orderIdKey];
        }
        if (self.amount.exceptNull != nil) {
            [map setObject:self.amount forKey:amountKey];
        }
        if (self.cp_order_no.exceptNull != nil) {
            [map setObject:self.cp_order_no forKey:cpOrderNoKey];
        }
        if (userId.exceptNull != nil) {
            [map setObject:userId forKey:userIdKey];
        }
        if (self.productId.exceptNull != nil) {
            [map setObject:self.productId forKey:productIdKey];
        }
        
        // 在原有的集合上新增一个
        newMyAllOrders = [NSMutableArray arrayWithArray:myAllOrders];
        [newMyAllOrders addObject:map];
        
        [outDict setObject:newMyAllOrders forKey:key];
        
    }
    
    LKLogInfo(@"outDict:%@",outDict);
    /**
     
      
           {
             "userId":
                     [

                        {
                                        "productId":"cccccccc"
                                        "orderId":"cccccccc"
                                                                     
                        }
                     ]
                    ,
             "userId":
                     [

                        {
                                        "productId":"cccccccc"
                                        "orderId":"cccccccc"
                                                                     
                        }
                     ]
            },
     
     
     
     */
    
    NSString *path = [NSString stringWithFormat:@"%@/order.plist",[LESandBoxHelper iapReceiptPath]];
    [outDict writeToFile:path atomically:YES];
    

    
    // 添加日志
    [self logPayBehaviourReportWithProductId:self.productId WithEvent:@"GET_ORDER_INOF" WithEventName:@"获取订单信息" WithOrderId:orderId WithReceipt:self.receipt WithTransactionIdentifier:@"" WithAllOrders:outDict];
    
}



/// 通过商品id获取我当前的订单信息
/// @param productId productId description
- (NSDictionary *)getCurrentOrderInfo:(NSString *)productId{
    
    NSDictionary *orderInfo = nil;
    NSArray *list = [self getMyAllOrders];
    if (list != nil) {
        for (NSDictionary *dict in list) {
            
            NSString*productId_old = dict[productIdKey];
            // 已存在商品
            if ([productId isEqualToString:productId_old]) {
                orderInfo = dict;
                break;
            }
        }
    }
    return orderInfo;
}



/// 获取我所有的商品
- (NSMutableArray *)getMyAllOrders{
    NSDictionary *dict1 = [self getReceiptFromeFile];
    LEUser *user = [LEUser getUser];
    NSMutableArray *allOrders = [NSMutableArray array];
    if (user != nil && user.userId.exceptNull != nil) {
        NSString *key1 = [NSString stringWithFormat:@"%@_key",user.userId];
        allOrders = dict1[key1];
    }
    return allOrders;
    
}

- (NSDictionary *)getReceiptFromeFile{
    NSString *path = [NSString stringWithFormat:@"%@/order.plist",[LESandBoxHelper iapReceiptPath]];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    return dict;
}


#pragma mark SKProductsRequestDelegate 查询失败后的回调
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    [self handleActionWithType:PurchFailed error:error];
    
    self.goodsRequestFinished = YES; //失败，请求完成
    
    // 上报
    [self logPayBehaviourReportWithProductId:self.productId WithEvent:@"APPLE_REQUEST_FAILE" WithEventName:@"APPLE拉取商品失败" WithOrderId:[NSString stringWithFormat:@"order:%@,error:%@",self.orderId,error.localizedDescription] WithReceipt:self.receipt WithTransactionIdentifier:@"" WithAllOrders:nil];
}

#pragma Mark 购买操作后的回调
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(nonnull NSArray<SKPaymentTransaction *> *)transactions {
    
    for (SKPaymentTransaction *transaction in transactions) {
        
        switch (transaction.transactionState) {
                
            case SKPaymentTransactionStatePurchasing://正在交易
            {}
                break;
                
            case SKPaymentTransactionStatePurchased://交易完成
            {
                // 等待用户登录成功后
                [self completeTransaction:transaction];
            }
                break;
                
            case SKPaymentTransactionStateFailed://交易失败
            {
                [self failedTransaction:transaction];
            }
                break;
                
            case SKPaymentTransactionStateRestored://已经购买过该商品
            {
                [self restoreTransaction:transaction];
            }
                break;
            default:
                break;
        }
    }
}
// 交易结束
- (void)completeTransaction:(SKPaymentTransaction *)transaction{
    NSString * productIdentifier = transaction.payment.productIdentifier;
    self.productId = productIdentifier;

    // 再次获取票据 当前票据
    NSString *receipt = nil;
    // 再次获取票据
    NSString *receipt_temp =  [self getReceipt];
    // 保存订单
    [self saveReceipt:transaction withOrderId:nil];
    
    // 再冲字典中获取
    NSDictionary *orderInfo = [self getCurrentOrderInfo:self.productId];
    if (orderInfo != nil) {
        receipt = orderInfo[receiptKey];
        LKLogInfo(@"current-dict-receipt:%@",receipt);
        if (receipt.exceptNull == nil) {
            receipt = receipt_temp;
        }
    }else{
        if (receipt_temp.exceptNull != nil) {
            receipt = receipt_temp;
        }
    }
    LKLogInfo(@"receipt:%@",receipt);

    if ([productIdentifier length] > 0) {

        NSString * orderId = nil;
        // 从沙盒获取
        NSDictionary *orderInfo = [self getCurrentOrderInfo:productIdentifier];
        orderId = orderInfo[orderIdKey];
        // 保存一份到全局
        self.orderId = orderId;
        
        // 日志输出
        [self logPayBehaviourReportWithProductId:productIdentifier WithEvent:@"WILL_FINISH_ORDER" WithEventName:@"即将完成订单" WithOrderId:orderId WithReceipt:receipt WithTransactionIdentifier:transaction.transactionIdentifier WithAllOrders:nil];


        // 向自己的服务器验证购买凭证
        [self verifyReceiptWithtransaction:transaction orderId:orderId receipt:receipt];
    }else{
        self.goodsRequestFinished = YES; //请求完成
    }


}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    LKLogInfo(@"transaction.error.code = %ld", (long)transaction.error.code);
    LKLogInfo(@"transaction.error = %@", transaction.error);
    
    if(transaction.error.code != SKErrorPaymentCancelled) {
        [self handleActionWithType:PurchFailed error:transaction.error];
        [self privateReportFailedTransactionContent:@"APPLE支付失败" transaction:transaction];
    } else {
        [self handleActionWithType:PurchCancle error:[self responserErrorMsg:@"取消支付" code:-100]];
        [self privateReportFailedTransactionContent:@"APPLE取消支付" transaction:transaction];
    }
    
   
    // 取消移除订单信息
    [self removeReceipt];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    // 订单已完成
    self.goodsRequestFinished = YES;
    
}

- (void)privateReportFailedTransactionContent:(NSString *)content transaction:(SKPaymentTransaction *)transaction{
    // 上报
    [self logPayBehaviourReportWithProductId:self.productId WithEvent:@"APPLE_TRANSACTION_FAILE" WithEventName:content WithOrderId:[NSString stringWithFormat:@"order:%@,error:%@ errorCode:%ld",self.orderId,transaction.error.localizedDescription,(long)transaction.error.code] WithReceipt:self.receipt WithTransactionIdentifier:transaction.transactionIdentifier WithAllOrders:[self getReceiptFromeFile]];
    
}
- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    self.goodsRequestFinished = YES; //恢复购买，请求完成
    
    // 上报
    [self logPayBehaviourReportWithProductId:self.productId WithEvent:@"RESTORE_TRANSACTION" WithEventName:@"重置交易" WithOrderId:[NSString stringWithFormat:@"order:%@",self.orderId] WithReceipt:self.receipt WithTransactionIdentifier:transaction.transactionIdentifier WithAllOrders:nil];
    
}

//将凭证发送给服务器
- (void)verifyReceiptWithtransaction:(SKPaymentTransaction *)transaction orderId:(NSString *)orderId receipt:(NSString *)receipt
{
    NSString *transactionIdentifier = transaction.transactionIdentifier;
    LKLogInfo(@"transactionIdentifier:%@",transactionIdentifier);
    NSString *productId =  transaction.payment.productIdentifier;
    
    if (orderId.exceptNull == nil) {
        orderId = @"none";
        LKLogInfo(@"====丢单了===none");
        [self logPayBehaviourReportWithProductId:productId WithEvent:@"LOSE_ORDER" WithEventName:@"订单号为空" WithOrderId:orderId WithReceipt:receipt WithTransactionIdentifier:transactionIdentifier WithAllOrders:nil];
    }
    if (receipt.exceptNull != nil) {
        
        [LEOrderApi appleFinishOrderNum:orderId receipt:receipt transactionIdentifier:transactionIdentifier subscribe:NO complete:^(NSError * _Nullable error, NSDictionary * _Nullable result) {
            
            if (error == nil) {
                NSNumber *success = result[@"success"];
                NSString *desc = result[@"desc"];
                if ([success boolValue] == YES) {
                    [self handleActionWithType:PurchSuccess error:nil];
                    // 先打点 后移除
                    [self logPointPayWithorderId:orderId productId:productId];
                    // 告知苹果完成订单
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                    
                    self.goodsRequestFinished = YES; //请求完成
                    
                    // 交易完成上报
                    [self logPayBehaviourReportWithProductId:productId WithEvent:@"FINISH_ORDER" WithEventName:@"完成交易" WithOrderId:orderId WithReceipt:receipt WithTransactionIdentifier:transaction.transactionIdentifier WithAllOrders:[self getReceiptFromeFile]];

                }else{
                    NSString *code = result[@"code"];
                    
                    if (code.exceptNull == nil) {
                        code = @"-1";
                    }
                    
                    NSError *err = [self responserErrorMsg:desc code:[code intValue]];
                    if (code.exceptNull != nil && [code isEqualToString:@"1037"]) { // 票据无效
                        [self handleActionWithType:PurchReceiptInvalid error:err];
                        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                        [self removeReceipt];
                    } else if (code.exceptNull != nil && [code isEqualToString:@"2301"]){ // 支付订单不存在
                        [self handleActionWithType:PurchOrderNotExist error:err];
                        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                        [self removeReceipt];
                    }else if (code.exceptNull != nil && [code isEqualToString:@"2302"]){ // 支付订单已结束
                        [self handleActionWithType:PurchOrderClosed error:err];
                        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                        [self removeReceipt];
                    }else if (code.exceptNull != nil && [code isEqualToString:@"2306"]){// 记录异常订单
                        [self handleActionWithType:PurchAbnormalOrder error:err];
                    }else{
                        [self handleActionWithType:PurchServiceFail error:err];
                    }
                    // 上报
                    [self logPayBehaviourReportWithProductId:productId WithEvent:@"FINISH_ORDER_FAILE" WithEventName:@"交易验证失败" WithOrderId:[NSString stringWithFormat:@"order:%@,error:%@",orderId,err.localizedDescription] WithReceipt:receipt WithTransactionIdentifier:transactionIdentifier WithAllOrders:[self getReceiptFromeFile]];
                    self.goodsRequestFinished = YES; //失败，请求完成
                }
            }else{
                [self handleActionWithType:PurchServiceFail error:error];
                self.goodsRequestFinished = YES; //失败，请求完成
                
                // 上报
                [self logPayBehaviourReportWithProductId:productId WithEvent:@"FINISH_ORDER_NET_ERROR" WithEventName:@"校验订单接口无响应" WithOrderId:orderId WithReceipt:receipt WithTransactionIdentifier:transactionIdentifier WithAllOrders:[self getReceiptFromeFile]];
            }
            
            
        }];
    }else{
        self.goodsRequestFinished = YES; //失败，请求完成
        NSLog(@"===票据丢单了===");
        
        // 上报
        [self logPayBehaviourReportWithProductId:productId WithEvent:@"LOSE_RECEIPT" WithEventName:@"票据丢单了" WithOrderId:orderId WithReceipt:receipt WithTransactionIdentifier:transactionIdentifier WithAllOrders:[self getReceiptFromeFile]];
    }
}


/// 支付打点
- (void)logPointPayWithorderId:(NSString *)orderId productId:(NSString *)productId{
    NSDictionary *paramDic = [self getCurrentOrderInfo:self.productId];
    NSString *price = nil;
    if (self.amount.exceptNull != nil) {
        price = self.amount;
    }else{
        NSString *amount = paramDic[amountKey];
        price = amount;
    }
    
    // AF
    LKLogInfo(@"=== pay_info ===");
    LKLogInfo(@"price:%@",price);
    LKLogInfo(@"orderId:%@",orderId);
    LKLogInfo(@"=== pay_info ===");
    if (productId == nil) {
        productId = orderId;
    }
    if (price.exceptNull != nil && orderId.exceptNull != nil) {
        
        // AF
        [[AppsFlyerLib shared] logEvent:AFEventPurchase
        withValues: @{
           AFEventParamRevenue: price,
           AFEventParamCurrency: @"USD",
           AFEventParamQuantity: @1,
           AFEventParamContentId: productId,
           @"order_id": orderId,
           AFEventParamReceiptId: orderId
        }];
        
        
        // FB
        [[LEFBAnalyticsManager shared] logPurchasedEvent:1 contentType:orderId contentId:productId currency:@"USD" valToSum:[price doubleValue]];
        LKLogInfo(@"FB pay Point Success");
    }
    
    // 支付成功移除本地保存的订单
    [self removeReceipt];
    
    
}

#pragma mark 错误信息反馈
- (void)handleActionWithType:(PurchType)type error:(NSError * _Nullable)error {
    
    switch (type) {
           case PurchSuccess:
            LKLogInfo(@"购买成功");
               break;
           case PurchFailed:
            LKLogInfo(@"购买失败");
               break;
           case PurchCancle:
            LKLogInfo(@"用户取消购买");
               break;
           case PurchVerFailed:
            LKLogInfo(@"订单校验失败");
               break;
           case PurchVerSuccess:
            LKLogInfo(@"订单校验成功");
               break;
           case PurchNotArrow:
            LKLogInfo(@"不允许程序内付费");
               break;
           case PurchRestoredGoods:
            LKLogInfo(@"-已经购买过该商品-");
               
               break;
           default:
               break;
       }
    
    if (_complete) {
        _complete(type,error);
    }
}


- (void)logPayBehaviourReportWithProductId:(NSString *)productId WithEvent:(NSString *)event WithEventName:(NSString *)eventName WithOrderId:(NSString *)orderId WithReceipt:(NSString *)receipt WithTransactionIdentifier:(NSString *)transactionIdentifier WithAllOrders:(NSDictionary *)orderInfos{
    
//    以下暂时注释-以下代码是将sdk日志上报sls查看支付相关错误的
//    productId = productId.exceptNull != nil ? productId : @"";
//    receipt = receipt.exceptNull != nil ? receipt : @"";
//    transactionIdentifier = transactionIdentifier.exceptNull != nil ? transactionIdentifier : @"";
//
//
//    NSDictionary *orderInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//                               productId,@"productId_current",
//                               receipt, @"receipt_current",
//                               transactionIdentifier,@"transactionIdentifier_current",
//                               orderId,@"orderId_current",
//                               nil];
//    NSMutableDictionary *result = [LEPointApi getReportLogInfo];
//    [result addEntriesFromDictionary:orderInfo];
//
//    [LEPointApi logReportServerWithEvent:event eventName:eventName infos:result WithOtherLogInfo:orderInfos complete:^(NSError * _Nullable error) {
//
//    }];
}
- (NSString *)chindDateFormate:(NSDate *)update{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *destDateString = [dateFormatter stringFromDate:update];
    return destDateString;
}

- (NSString *)uuid
{
    // create a new UUID which you own
    CFUUIDRef uuidref = CFUUIDCreate(kCFAllocatorDefault);
    
    // create a new CFStringRef (toll-free bridged to NSString)
    // that you own
    CFStringRef uuid = CFUUIDCreateString(kCFAllocatorDefault, uuidref);
    
    NSString *result = (__bridge NSString *)uuid;
    //release the uuidref
    CFRelease(uuidref);
    // release the UUID
    CFRelease(uuid);
    
    return result;
}

/* AF
 Rz7VqcsJLyJeofrrdNMQgg
 id134568790
 
 id1509598801
 **/
@end
