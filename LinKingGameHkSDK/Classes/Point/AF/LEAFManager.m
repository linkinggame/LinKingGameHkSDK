//
//  LEAFManager.m
//  LinKingEnSDK
//
//  Created by MrDML on 2020/8/16.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEAFManager.h"
#import <AppsFlyerLib/AppsFlyerLib.h>
#import <AppTrackingTransparency/ATTrackingManager.h>
#import "LEGlobalConf.h"
#import "LESDKConfig.h"
#import "LKLog.h"
@interface LEAFManager ()<AppsFlyerLibDelegate>
@property (nonatomic, copy) NSString *appsFlyerDevKey;
@property (nonatomic, copy) NSString *appleAppIDv;
@property (nonatomic, assign) BOOL isDebug;
@end
static LEAFManager *_instance = nil;
@implementation LEAFManager
+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LEAFManager alloc] init];
    });
    return _instance;
}


- (void)loadData{
    LESDKConfig *configSDK = [LESDKConfig getSDKConfig];
    NSDictionary *point_config = configSDK.point_config;
    NSDictionary *af = point_config[@"af"];
    self.appsFlyerDevKey = af[@"appsflyer_key_ios"];
    self.appleAppIDv = af[@"apple_appid_ios"];
    
    self.isDebug = [configSDK.mode_debug boolValue];
}

/// 用于追踪游戏等级事件
/// @param level 等级
/// @param score 得分
- (void)afLogLevel:(NSInteger)level score:(CGFloat)score{
    [self afLogTrackEvent:AFEventLevelAchieved withValues:@{
        AFEventParamLevel:[NSNumber numberWithInteger:level],
        AFEventParamScore:[NSNumber numberWithFloat:score]
        
     }];
}


/// 用于追踪付款信息配置状态
/// @param success 是否成功
- (void)afLogAddPaymentInfoSuccess:(BOOL)success{
    [self afLogTrackEvent:AFEventAddPaymentInfo withValues:@{
        AFEventParamSuccess:[NSNumber numberWithBool:success]
     }];
}


/// 用于追踪付款信息配置状态
/// @param price 价格
/// @param type 商品类型
/// @param currency 货币类型
/// @param goodsId 商品id
/// @param content 商品描述
/// @param quantity 商品数量
- (void)afLogAddGoodsCartWithPrice:(NSNumber *)price goodsType:(NSString *)type currency:(NSString *)currency goodsId:(NSString *)goodsId content:(NSString *)content quantity:(int)quantity{
    [self afLogTrackEvent:AFEventAddToCart withValues:@{
        AFEventParamPrice:price,
        AFEventParamContentType:type,
        AFEventParamContentId:goodsId,
        AFEventParamContent:content,
        AFEventParamCurrency:currency,
        AFEventParamQuantity:[NSNumber numberWithInt:quantity]
     }];
}



/// 完成购买
/// @param price     购买产生的收入
/// @param orderId 购买生成的订单ID
/// @param receiptId 买家生成的收据ID
- (void)afLogCompletedPurchase:(NSNumber *)price orderId:(NSString *)orderId receiptId:(NSString *)receiptId{
    [[AppsFlyerLib shared] logEvent:@"completed_purchase"
    withValues: @{
     AFEventParamRevenue: price,
     AFEventParamOrderId: orderId,
     AFEventParamReceiptId: receiptId
    }];
}


/// 用于追踪特定商品的“添加到愿望清单”事件
/// @param price 价格
/// @param type 类型
/// @param goodsId 物品id
/// @param content 详细描述
/// @param currency 货币类型
/// @param quantity 数量
- (void)afLogAddWishlistWithPrice:(NSNumber *)price goodsType:(NSString *)type goodsId:(NSString *)goodsId content:(NSString *)content currency:(NSString *)currency quantity:(int)quantity{
    [self afLogTrackEvent:AFEventAddToWishlist withValues:@{
           @"af_price":price,
           @"af_content_type":type,
           @"af_content_id":goodsId,
           @"af_content":content,
           @"af_currency":currency,
           @"af_quantity":[NSNumber numberWithInt:quantity]
        }];
}


/// 用于追踪用户注册方式
/// @param style 注册方式
- (void)afLogCompleteRegistrationStyle:(NSString *)style{
    
    [self afLogTrackEvent:AFEventCompleteRegistration withValues:@{
            @"af_registration_method":style
      }];
}
/// 用于追踪教程完成情况
/// @param success 是否成功
/// @param userId 用户id
/// @param desc 描述
- (void)afLogTutorialCompletionWithSuccess:(BOOL)success userId:(NSString *)userId desc:(NSString *)desc{
       [self afLogTrackEvent:AFEventTutorial_completion withValues:@{
           AFEventParamSuccess:[NSNumber numberWithBool:success],
           AFEventParamContentId:userId,
           AFEventParamContent:desc
       }];
}



/// 用于追踪结账事件
/// @param price 价格
/// @param contentType 商品类型
/// @param contentId 商品id
/// @param quantity 商品数量
/// @param payment 支付方式（信息）
/// @param currency 货币类型
- (void)afLogInitiatedCheckoutWithPrice:(NSNumber *)price contentType:(NSString *)contentType contentId:(NSString *)contentId content:(NSString *)content  quantity:(int)quantity payment:(NSString *)payment currency:(NSString *)currency{
    [self afLogTrackEvent:AFEventInitiatedCheckout withValues:@{
        @"af_price":price,
        @"af_content_type":contentType,
        @"af_content_id":contentId,
        @"af_content":content,
        @"af_quantity":[NSNumber numberWithInt:quantity],
        @"af_payment_info_available":payment,
        @"af_currency":currency,
    }];
}



/// 用于追踪购买事件（及相关收入）
/// @param price 价格
/// @param type 订单了类型
/// @param currency 货币类型 USD
/// @param orderId 订单Id
/// @param desc 描述
/// @param quantity 数量
- (void)afLogPurchaseWithPrice:(NSNumber *)price type:(NSString *)type currency:(NSString *)currency orderId:(NSString *)orderId desc:(NSString *)desc quantity:(int)quantity{

    [self afLogTrackEvent:AFEventPurchase withValues:@{
        AFEventParamRevenue:price,
        AFEventParamContentType:type,
        AFEventParamContentId:orderId,
        AFEventParamContent:desc,
        AFEventParamPrice:price,
        AFEventParamCurrency:currency,
        AFEventParamOrderId:orderId,
        AFEventParamQuantity:[NSNumber numberWithInt:quantity]
    }];
    
}
//

/// 用于追踪付费订阅购买
/// @param price 价格
- (void)afLogSubscribeWithPrice:(NSNumber *)price{
//     NSNumber *price = values[@"price"];
    [self afLogTrackEvent:AFEventSubscribe withValues:@{
        AFEventParamRevenue:price,
        AFEventParamCurrency:@"USD"
    }];
}



//

/// 用于追踪产品的免费试用的开始
/// @param price 价格
/// @param currency 货币类型
- (void)afLogStartTrialWithPrice:(NSNumber *)price currency:(NSString *)currency{
    [self afLogTrackEvent:AFEventStartTrial withValues:@{
              @"af_price":price,
              @"af_currency":currency
    }];
 
}

/// 用于追踪应用/商品评级事件
/// @param rating 当前评级
/// @param contentType 评级类型
/// @param contentId 评级id
/// @param content 评级内容
/// @param maxRating 最大评级
- (void)afLogWithRating:(CGFloat)rating contentType:(NSString *)contentType contentId:(NSString *)contentId content:(NSString *)content maxRating:(CGFloat)maxRating{
    [self afLogTrackEvent:AFEventRate withValues:@{
        @"af_rating_value":[NSNumber numberWithFloat:rating],
        @"af_content_type":contentType,
        @"af_content_id":contentId,
        @"af_content":content,
        @"af_max_rating_value":[NSNumber numberWithFloat:maxRating]
    }];
}


/// 用于追踪搜索事件
/// @param contentType 搜索类别
/// @param searchWords 搜索关键字
/// @param success 是否搜索成功
- (void)afLogSearchWithContentType:(NSString *)contentType searchWords:(NSString *)searchWords success:(BOOL)success{
    [self afLogTrackEvent:AFEventSearch withValues:@{
        @"af_content_type":contentType,
        @"af_search_string":searchWords,
        @"af_success":[NSNumber numberWithBool:success]
    }];
}


/// 用于追踪积分花费事件
/// @param price 价格
/// @param contentType 事件类型
/// @param contentId 事件id
/// @param content 事件内容
- (void)afLogSpentCreditsWithPrice:(NSNumber *)price ContentType:(NSString *)contentType contentId:(NSString *)contentId content:(NSString *)content {
    [self afLogTrackEvent:AFEventSpentCredits withValues:@{
        @"af_price":price,
        @"af_content_type":contentType,
        @"af_content_id":contentId,
        @"af_content":content
    }];
}


/// 用于追踪成就解锁事件
/// @param desc 详细描述
- (void)afLogAchievementUnlockedWithDesc:(NSString *)desc{
    [self afLogTrackEvent:AFEventAchievementUnlocked withValues:@{
              @"af_description":desc
    }];
}

/// 用于追踪内容视图事件
/// @param price 价格
/// @param contentType 内容类型
/// @param contentId 内容id
/// @param content 内容描述
/// @param currency 货币类型
- (void)afLogContentViewWithPrice:(NSNumber *)price contentType:(NSString *)contentType contentId:(NSString *)contentId content:(NSString *)content currency:(NSString *)currency{
    [self afLogTrackEvent:AFEventAchievementUnlocked withValues:@{
              @"af_price":price,
              @"af_content_type":price,
              @"af_content_id":price,
              @"af_content":price,
              @"af_currency":price
    }];
}



/// 用于追踪列表视图事件
/// @param contentType 列表视图类别
/// @param contentList 列表集合
- (void)afLogListViewWithContentType:(NSString *)contentType contentList:(NSArray *)contentList{
    [self afLogTrackEvent:AFEventListView withValues:@{
        @"af_content_type":contentType,
        @"af_content_list":contentList
    }];
}

//  用于追踪应用中展示广告的点击次数
- (void)afLogAdclickWithAdStyle:(NSString *)style{
    
    [self afLogTrackEvent:AFEventAdClick withValues:@{
        AFEventParamAdRevenueAdType:style
    }];
}
// 用于追踪应用中展示广告的展示次数
- (void)afLogAdView:(NSString *)style{
    [self afLogTrackEvent:AFEventAdView withValues:@{
          AFEventParamAdRevenueAdType:style
    }];
}

/// 用于追踪分享事件
/// @param desc 分享描述
- (void)afLogShareDesc:(NSString*)desc{
       [self afLogTrackEvent:AFEventShare withValues:@{
           AFEventParamDescription:desc
       }];
}


/// 用于追踪邀请（社交）事件
- (void)afLogInvite{
       [self afLogTrackEvent:AFEventInvite withValues:@{
          
       }];
}

//  用于追踪用户的重参与事件
- (void)afLogActive{
    [self afLogTrackEvent:AFEventReEngage withValues:@{}];
}

// 用于追踪用户登录事件
- (void)afLogLoginStyle:(NSString *)style{
    [self afLogTrackEvent:AFEventLogin withValues:@{
          @"LoginStyle":style
    }];
}

// 从推送通知打开 用于追踪从推送通知打开应用的事件
- (void)afLogOpenedFromPushNotification{
    [self afLogTrackEvent:AFEventOpenedFromPushNotification withValues:@{
    
    }];
}

/// 用于追踪更新事件
/// @param contentId 更新事件Id
- (void)afLogWithContentId:(NSString *)contentId{
    [self afLogTrackEvent:AFEventUpdate withValues:@{
    
    }];
}


/// 应用内事件
/// @param eventName <#eventName description#>
/// @param values <#values description#>
- (void)afLogTrackEvent:(NSString *)eventName withValues:(NSDictionary *)values{
    
    [[AppsFlyerLib shared] logEvent:eventName withValues:values];
    
}


-(void)sendLaunch:(UIApplication *)application {
//    [[AppsFlyerLib shared] trackAppLaunch];
}
#pragma mark -- 注册AF
- (void)registAppsFlyer{
     /** APPSFLYER INIT **/
    //  @"Rz7VqcsJLyJeofrrdNMQgg"; id134568790
    //  @"1509598801"; 苹果应用的appleId 1509598801 这个是全民赛车的
    
    
    LESDKConfig *sdkConfig = [LESDKConfig getSDKConfig];
    
    if (sdkConfig != nil) {
        NSDictionary *af = sdkConfig.point_config[@"af"];
        NSString *appsflyer_key_ios = af[@"appsflyer_key_ios"];
        NSString *appleAppID = af[@"apple_appid_ios"]; // id134568790
        [AppsFlyerLib shared].appsFlyerDevKey =  appsflyer_key_ios;
        [AppsFlyerLib shared].appleAppID =appleAppID;
        [AppsFlyerLib shared].delegate = self;
        if (@available(iOS 14, *)) {
            [[AppsFlyerLib shared] waitForAdvertisingIdentifierWithTimeoutInterval:60];
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status){

            }];
        }
          /* Set isDebug to true to see AppsFlyer debug logs */
//        [AppsFlyerLib shared].isDebug = YES;
          
//        if (@available(iOS 10, *)) {
//                UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//                center.delegate = self;
//                [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
//                }];
//          } else {
//                UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes: UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge categories:nil];
//                [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
//          }
//          [[UIApplication sharedApplication] registerForRemoteNotifications];
//    }else{
//        LKLogInfo(@"⚠️SDK未初始化成功⚠️");
//    }
//
    }
}

    

- (void)registAppsFlyerDevKey:(NSString * _Nonnull)devKey appleAppID:(NSString * _Nonnull)appleAppID isDebug:(BOOL)isDebug {
     /** APPSFLYER INIT **/
    //  @"Rz7VqcsJLyJeofrrdNMQgg";
    //  @"1509598801"; 苹果应用的appleId 1509598801 这个是全民赛车的
    
    [AppsFlyerLib shared].appsFlyerDevKey =  devKey;
    [AppsFlyerLib shared].appleAppID = appleAppID;
      [AppsFlyerLib shared].delegate = self;
      /* Set isDebug to true to see AppsFlyer debug logs */
//    [AppsFlyerLib shared].isDebug =  isDebug;
    if (@available(iOS 14, *)) {
        [[AppsFlyerLib shared] waitForAdvertisingIdentifierWithTimeoutInterval:60];
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status){

        }];
    }
      [[NSNotificationCenter defaultCenter] addObserver:self
          selector:@selector(sendLaunch:)
          name:UIApplicationDidBecomeActiveNotification
          object:nil];
}


#pragma mark -- AppsFlyerTrackerDelegate
- (void)onConversionDataFail:(nonnull NSError *)error {
    LKLogInfo(@"%@",error); // Error Domain=com.appsflyer.sdk.gcd Code=0 "App ID is incorrect" UserInfo={NSLocalizedDescription=App ID is incorrect}
    if ([self.delegate respondsToSelector:@selector(onConversionDataFail:)]) {
        [self.delegate onConversionDataFail:error];
    }
}

- (void)onConversionDataSuccess:(nonnull NSDictionary *)conversionInfo {
    id status = [conversionInfo objectForKey:@"af_status"];
    if([status isEqualToString:@"Non-organic"]) {
        id sourceID = [conversionInfo objectForKey:@"media_source"];
        id campaign = [conversionInfo objectForKey:@"campaign"];
        LKLogInfo(@"This is a none organic install. Media source: %@  Campaign: %@",sourceID,campaign);
    } else if([status isEqualToString:@"Organic"]) {
        LKLogInfo(@"This is an organic install.");
    }
    
    if ([self.delegate respondsToSelector:@selector(onConversionDataSuccess:)]) {
        [self.delegate onConversionDataSuccess:conversionInfo];
    }
    
}


//Handle Direct Deep Link
- (void) onAppOpenAttribution:(NSDictionary*) attributionData {
    LKLogInfo(@"%@",attributionData);
    if ([self.delegate respondsToSelector:@selector(onAppOpenAttribution:)]) {
        [self.delegate onAppOpenAttribution:attributionData];
    }
}
- (void) onAppOpenAttributionFailure:(NSError *)error {
    LKLogInfo(@"%@",error);
    if ([self.delegate respondsToSelector:@selector(onConversionDataFail:)]) {
        [self.delegate onConversionDataFail:error];
    }
}

// 设置客户用户 ID
- (void)afLogTrackSetCustomerUserID:(NSString *)userId{
    if (userId != nil) {
           [AppsFlyerLib shared].customerUserID= userId;
    }

}

// 获取AppsFlyer ID
- (NSString *)afLogTrackAppsFlyerUID{
    NSString *appsflyerId = [AppsFlyerLib shared].getAppsFlyerUID;
    return appsflyerId;;
}

@end
