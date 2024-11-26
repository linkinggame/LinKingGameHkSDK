//
//  LEApplePay.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/18.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEApplePay.h"
#import <StoreKit/StoreKit.h>
#import "LEGlobalConf.h"
#import "LEProduct.h"
#import "NSObject+LEAdditions.h"
#import "LEOrderApi.h"
#import <Toast/Toast.h>
#import "LKLog.h"
@interface LEApplePay ()<SKProductsRequestDelegate, SKPaymentTransactionObserver>{
    NSString           *_purchID;
    IAPCompletionHandle _handle;
    NSDictionary      *_parames;
    BOOL             _is_pay;
    BOOL             _is_subscribe;
    
}
/** 记录产品信息(商品列表)*/
@property (nonatomic, strong) NSArray *products;
@property (nonatomic, copy)NSString      *order_no;
@property (nonatomic, copy) void(^loadProdutsCallBack)(NSError * _Nullable error, NSArray*_Nullable products,NSArray * _Nullable invalidProducts);
@property (nonatomic, strong) UIView *view;

@end
static LEApplePay*_instance = nil;
@implementation LEApplePay

+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LEApplePay alloc] init];
    });
    return _instance;
    
}
- (instancetype)init{
    self = [super init];
    if (self) {
         _is_pay = YES;
        // 购买监听写在程序入口,程序挂起时移除监听,这样如果有未完成的订单将会自动执行并回调 paymentQueue:updatedTransactions:方法
//        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
    }
    return self;
}
-(void)setup
{

    //监听SKPayment过程
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    LKLogInfo(@"RMIAPHelper 开启交易监听");
}

-(void)destroy
{
    //解除监听
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    LKLogInfo(@"RMIAPHelper 注销交易监听");
    
}

-(BOOL)canMakePayments
{
    return [SKPaymentQueue canMakePayments];
}
#pragma 恢复流程
//发起恢复
-(void)restore
{
   [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


- (void)setContentView:(UIView *)view{
    self.view = view;
}

#pragma mark -- 查询订阅
- (void)querysubscribeProduct:(NSString *)productId Complete:(void(^)(NSError *error, NSDictionary*results))complete {
    [LEOrderApi querySubscribeProduct:productId Complete:^(NSError * _Nonnull error, NSDictionary * _Nonnull results) {

        if (complete) {
            complete(error,results);
        }
    }];

}

/**
  加载平台产品
 */
- (void)requestProductDatasComplete:(void(^_Nullable)(NSError * _Nullable error, NSArray*_Nullable products,NSArray * _Nullable invalidProducts))complete{
    // 不支付，仅仅请求商品信息
       _is_pay = NO;
       [LEOrderApi fetchtAppleProductDatasComplete:^(NSError * _Nonnull error, NSArray * _Nonnull results) {
           
           if (error == nil) {
               
               self.loadProdutsCallBack = complete;
               
               NSMutableArray *productIds = [NSMutableArray array];
               for (NSDictionary *dict in results) {
                    NSString *productId = dict[@"id"];
                      if (productId.exceptNull != nil) {
                           [productIds addObject:productId];
                      }
                }
                [self requestProductDatas:productIds];
           }else{
               if (complete) {
                   complete(error,nil,nil);
               }
           }
           
       }];
}


/// 根据单个商品id 查询商品信息
/// @param productId productId description
- (void)requestProductData:(NSString *)productId{
    // 不支付，仅仅请求商品信息
    _is_pay = NO;

    NSArray *product = [[NSArray alloc] initWithObjects:productId,nil];
    
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
    request.delegate = self;
    [request start];

}


/// 多个商品ID，查询多个商品信息
/// @param productIds productIds description
- (void)requestProductDatas:(NSArray <NSString *>*)productIds{
    // 不支付，仅仅请求商品信息
   _is_pay = NO;

    NSSet *nsset = [NSSet setWithArray:productIds];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
    request.delegate = self;
    [request start];

}

- (void)dealloc{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}
 #pragma mark - 🚪public
 - (void)startPurchWithID:(NSString *)purchID completeHandle:(IAPCompletionHandle)handle{
   //  [self checkCloseFinishOrder];
     [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
      _is_pay = YES;
     if (purchID) {
         if ([SKPaymentQueue canMakePayments]) {
             // 开始购买服务
             _purchID = purchID;
             _handle = handle;
             NSSet *nsset = [NSSet setWithArray:@[purchID]];
             SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
             request.delegate = self;
             [request start];
         }else{
             [self handleActionWithType:SIAPPurchNotArrow data:nil];
         }
     }
 }

- (void)startPurchWithID:(NSString *)purchID parames:(NSDictionary *)parames completeHandle:(IAPCompletionHandle)handle{
   // [self checkCloseFinishOrder];
     _is_pay = YES;
    if (purchID) {
            if ([SKPaymentQueue canMakePayments]) {
                // 开始购买服务
                _purchID = purchID;
                _handle = handle;
                _parames = parames;
                NSSet *nsset = [NSSet setWithArray:@[purchID]];
                SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
                request.delegate = self;
                [request start];
            }else{
                [self handleActionWithType:SIAPPurchNotArrow data:nil];
            }
        }
    
}


#pragma mark - 🔒private
- (void)handleActionWithType:(SIAPPurchType)type data:(NSData *)data{
#if DEBUG
    switch (type) {
        case SIAPPurchSuccess:
            LKLogInfo(@"购买成功");
            break;
        case SIAPPurchFailed:
            LKLogInfo(@"购买失败");
            break;
        case SIAPPurchCancle:
            LKLogInfo(@"用户取消购买");
            break;
        case SIAPPurchVerFailed:
            LKLogInfo(@"订单校验失败");
            break;
        case SIAPPurchVerSuccess:
            LKLogInfo(@"订单校验成功");
            break;
        case SIAPPurchNotArrow:
            LKLogInfo(@"不允许程序内付费");
            break;
        case SIAPPurchRestoredGoods:
            LKLogInfo(@"-已经购买过该商品-");
            
            break;
        default:
            break;
    }
#endif
    if(_handle){
        _handle(type,data);
    }
}
#pragma mark - 🍐delegate
// 交易结束
- (void)completeTransaction:(SKPaymentTransaction *)transaction{
  // Your application should implement these two methods.
    NSString * productIdentifier = transaction.payment.productIdentifier;
    //NSString * receipt = [transaction.transactionReceipt base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    //[transaction.transactionReceipt base64EncodedString];
    if ([productIdentifier length] > 0) {
        // 向自己的服务器验证购买凭证
       // NSURL *recepitURL = [[NSBundle mainBundle] appStoreReceiptURL];
        NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];
        
        [self verifyMyServer:receipt withProductId:productIdentifier];
        
    }
 
  
}

- (void)verifyMyServer:(NSData *)receipt withProductId:(NSString *)productId{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *orderNumber = [[NSUserDefaults standardUserDefaults] objectForKey:productId];
    if(orderNumber.exceptNull != nil){
        self.order_no = orderNumber;
        if (self.order_no.exceptNull != nil) {
             [params setObject:@"ios" forKey:@"type"];
             [params setObject:self.order_no forKey:@"order_no"];
            NSString * restrictJsonString = [receipt base64EncodedStringWithOptions:0];
            //[[[[self dictionaryToJson:jsonResponse] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"\n" witfhString:@""] stringByReplacingOccurrencesOfString:@"\\" withString:@""];

            [params setObject:restrictJsonString forKey:@"receipt"];
            
            [params setObject:[NSNumber numberWithBool:_is_subscribe] forKey:@"subscribe"];
            
            LKLogInfo(@"=========>%@",params);
            /*
             {
               "success" : true,
               "code" : null,
               "data" : 1,
               "desc" : null
             }
             **/
            
            [LEOrderApi appleFinishOrderNum:self.order_no receipt:restrictJsonString subscribe:_is_subscribe complete:^(NSError * _Nonnull error, NSDictionary * _Nonnull result) {
                if (error == nil) {
                    if (self->_handle) {
                        self->_handle(SIAPPurchSuccess,nil);
                    }
                    if ([self.delegate respondsToSelector:@selector(storePayFinishPay:withError:)]) {
                        if (error == nil) {
                             [self.delegate storePayFinishPay:YES withError:error];
                        }else{
                             [self.delegate storePayFinishPay:NO withError:error];
                        }
                    }
                }else{
                    //[self.view makeToast:error.localizedDescription];
                     self->_handle(SIAPPurchServiceFail,nil);
                }
                
                
            }];


        }

    }else{
      //  LKLogInfo(@"===订单号不存在===");
    }
    

}

// 交易失败
- (void)failedTransaction:(SKPaymentTransaction *)transaction{
    if (transaction.error.code != SKErrorPaymentCancelled) {
        [self handleActionWithType:SIAPPurchFailed data:nil];
    }else{
        [self handleActionWithType:SIAPPurchCancle data:nil];
        if ([self.delegate respondsToSelector:@selector(storePayCancelPay)]) {
            [self.delegate storePayCancelPay];
        }
    }
     
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}
 


  
 #pragma mark - SKProductsRequestDelegate
 - (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{

      NSArray *product = response.products;
     if(_is_pay == YES){
         LKLogInfo(@"products--->%@",response.products);
         LKLogInfo(@"invalidProductIdentifiers--->%@",response.invalidProductIdentifiers);
             if([product count] <= 0){
         #if DEBUG
                 LKLogInfo(@"--------------没有商品------------------");
                 if (_handle) {
                     _handle(SIAPPurchNoGoods,nil);
                 }
         #endif
                 return;
             }
             SKProduct *p = nil;
             for(SKProduct *pro in product){
                 if([pro.productIdentifier isEqualToString:_purchID]){
                     p = pro;
                     break;
                 }
             }
         #if DEBUG
         LKLogInfo(@"productID:%@", _purchID);
         LKLogInfo(@"产品付费数量:%lu",(unsigned long)[product count]);
         LKLogInfo(@"%@",[p description]);
         LKLogInfo(@"%@",[p localizedTitle]);
         LKLogInfo(@"%@",[p localizedDescription]);
         LKLogInfo(@"%@",[p price]);
         LKLogInfo(@"%@",[p productIdentifier]);
         LKLogInfo(@"发送购买请求");
         #endif

         /*
          {
            "success" : true,
            "code" : null,
            "data" : {
              "order_no" : "1286193749155905536",
              "body" : null,
              "paypal_token" : null,
              "wechat_body" : null
            },
            "desc" : null
          }
          */
         // 开始向自己的服务端发起请求创建订单，成功之后拉起苹果内购请求
         [LEOrderApi createOrderType:@"ios" withParameters:_parames complete:^(NSError * _Nonnull error, NSDictionary * _Nonnull result) {
             if (error == nil) {
                   self.order_no  = result[@"order_no"];
                  [[NSUserDefaults standardUserDefaults] setObject:self.order_no forKey:self->_purchID];
                  [[NSUserDefaults standardUserDefaults] synchronize];
                 
                 SKPayment *payment = [SKPayment paymentWithProduct:p];
                 [[SKPaymentQueue defaultQueue] addPayment:payment];
                 
               
             }else{
                   //[self.view makeToast:error.localizedDescription];
                   self->_handle(SIAPPurchServiceFail,nil);
             }
             if ([self.delegate respondsToSelector:@selector(storePayCreateOrderId:withError:)]) {
                    [self.delegate storePayCreateOrderId:self.order_no withError:error];
                }

         }];
 
     }else{
          NSMutableArray *LE_products = [[NSMutableArray alloc] init];
         // 转化对象
         for(SKProduct *pro in product){
            LEProduct *LE_product = [[LEProduct alloc] initWithArray:pro];
             [LE_products addObject:LE_product];
         }
         // 响应外部回调
//         if ([self.delegate respondsToSelector:@selector(productsRequest:invalidProductIdentifiers:didFailWithError:)]) {
//             [self.delegate productsRequest:LE_products invalidProductIdentifiers:response.invalidProductIdentifiers didFailWithError:nil];
//         }
         // 回调block
         dispatch_async(dispatch_get_main_queue(), ^{
             if (self.loadProdutsCallBack) {
                 self.loadProdutsCallBack(nil, LE_products, response.invalidProductIdentifiers);
             }
         });

         
     }

 }
#pragma mark -- 恢复交易处理

//交易完成之后，调用； 据我理解应该是[_paymentQueue finishTransaction:transaction]; 调用成功之后的回掉
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    LKLogInfo(@"removedTransactions called:");
    LKLogInfo(@"=======================================================");
}

// Sent when all transactions from the user's purchase history have successfully been added back to the queue.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    LKLogInfo(@"paymentQueueRestoreCompletedTransactionsFinished called:");
    LKLogInfo(@"SKPaymentQueue:%@",queue);
    LKLogInfo(@"=======================================================");
}
// Sent when the download state has changed.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads
{
    LKLogInfo(@"updatedDownloads called:");
    LKLogInfo(@"=======================================================");
}

//恢复失败
-(void) paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error{

    LKLogInfo(@"restoreCompletedTransactionsFailedWithError called:");
    LKLogInfo(@"error:%@",error);
    LKLogInfo(@"=======================================================");
}

 //请求失败
 - (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
 #if DEBUG
     LKLogInfo(@"------------------错误-----------------:%@", error);
 #endif
     // 响应外部回调
//     if ([self.delegate respondsToSelector:@selector(productsRequest:invalidProductIdentifiers:didFailWithError:)]) {
//         [self.delegate productsRequest:nil invalidProductIdentifiers:nil didFailWithError:error];
//     }
     if (self.loadProdutsCallBack) {
         self.loadProdutsCallBack(error, nil, nil);
     }
 }
  
 - (void)requestDidFinish:(SKRequest *)request{
 #if DEBUG
     LKLogInfo(@"------------反馈信息结束-----------------");
 #endif
 }
  
 #pragma mark - SKPaymentTransactionObserver
 - (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
     for (SKPaymentTransaction *tran in transactions) {
         switch (tran.transactionState) {
             case SKPaymentTransactionStatePurchased:
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                 [self completeTransaction:tran];
                
                 // 订阅特殊处理
                 if (tran.originalTransaction) {
                      
                     // 如果是自动续费的订单,originalTransaction会有内容
                     LKLogInfo(@"自动续费的订单,originalTransaction = %@",tran.originalTransaction.payment.productIdentifier);
                     // 查询订阅
                     //[self querySubscribe:tran.originalTransaction.payment.productIdentifier];
                     _is_subscribe = YES;
                 }else{
                      // 普通购买，以及第一次购买自动订阅
                     _is_subscribe = NO;
                     LKLogInfo(@"普通购买，以及第一次购买自动订阅");
                     //[self completeTransaction:tran];
                 }
                 break;
             case SKPaymentTransactionStatePurchasing:
 #if DEBUG
                 LKLogInfo(@"商品添加进列表");
 #endif
                 break;
             case SKPaymentTransactionStateRestored:
 #if DEBUG
                 LKLogInfo(@"已经购买过商品");
 #endif
                 // 消耗型不支持恢复购买
                 [self handleActionWithType:SIAPPurchRestoredGoods data:nil];
                 [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                 break;
             case SKPaymentTransactionStateFailed:
                 [self failedTransaction:tran];
                 break;
             default:
                 break;
         }
     }
 }


@end
