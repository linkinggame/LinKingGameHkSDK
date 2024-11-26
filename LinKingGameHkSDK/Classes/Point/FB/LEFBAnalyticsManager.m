//
//  LEFBAnalyticsManager.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/19.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEFBAnalyticsManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
@interface LEFBAnalyticsManager ()

@end
static LEFBAnalyticsManager *_instance = nil;
@implementation LEFBAnalyticsManager


+ (instancetype)shared{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LEFBAnalyticsManager alloc] init];
    });
    return _instance;
}

#pragma mark - 设备是否允许追踪时
- (void)setAdvertiserTrackingEnabled:(BOOL)enabled{
    [FBSDKSettings setAdvertiserTrackingEnabled:enabled];
}


// 在SDK 初始化的时候就要进行配置
#pragma mark - 禁用自动记录事件
/// 是否重新启动自动记录事件
/// @param autoLogAppEventsEnabled YES:重新启动 NO:暂停自动收集
- (void)setAutoLogAppEventsEnabled:(BOOL)autoLogAppEventsEnabled{
    [FBSDKSettings setAutoLogAppEventsEnabled:autoLogAppEventsEnabled];
}

#pragma mark - 禁用广告主编号收集功能
/// 是否禁用广告主编号收集功能
/// @param advertiserIDCollectionEnabled YES:重新启动 NO:暂停自动收集
- (void)setAdvertiserIDCollectionEnabled:(BOOL)advertiserIDCollectionEnabled{
    [FBSDKSettings setAdvertiserIDCollectionEnabled:advertiserIDCollectionEnabled];
}



/// 完成注册
/// @param registrationMethod registrationMethod description
- (void)logCompleteRegistrationEvent:(NSString *)registrationMethod {
    NSDictionary *params =
    @{FBSDKAppEventParameterNameRegistrationMethod : registrationMethod};
    [FBSDKAppEvents
     logEvent:FBSDKAppEventNameCompletedRegistration
     parameters:params];
}



/// 教程打点
/// @param contentId <#contentId description#>
/// @param success <#success description#>
- (void)logCompletedTutorialEvent:(NSString*)contentId success:(BOOL)success {

   NSDictionary *params =
       [[NSDictionary alloc] initWithObjectsAndKeys:
           contentId, FBSDKAppEventParameterNameContentID,
           [NSNumber numberWithInt:success ? 1 : 0], FBSDKAppEventParameterNameSuccess,
           nil];

   [FBSDKAppEvents logEvent: FBSDKAppEventNameCompletedTutorial
       parameters: params];
}



/// 等级打点
/// @param level <#level description#>
- (void)logAchievedLevelEvent:(NSString*)level{

   NSDictionary *params =
       [[NSDictionary alloc] initWithObjectsAndKeys:
           level, FBSDKAppEventParameterNameLevel,
           nil];

   [FBSDKAppEvents logEvent: FBSDKAppEventNameAchievedLevel
       parameters: params];
}


/// 解锁
/// @param description description description
- (void)logUnlockedAchievementEvent:(NSString*)description {

   NSDictionary *params =
       [[NSDictionary alloc] initWithObjectsAndKeys:
           description, FBSDKAppEventParameterNameDescription,
           nil];

   [FBSDKAppEvents logEvent: FBSDKAppEventNameUnlockedAchievement
       parameters: params];
}


/// 发起结账事件
/// @param contentId contentId description
/// @param contentType contentType description
/// @param numItems numItems description
/// @param paymentInfoAvailable paymentInfoAvailable description
/// @param currency currency description
/// @param totalPrice totalPrice description
- (void)logInitiatedCheckoutEvent:(NSString*)contentId
   contentType:(NSString*)contentType
   numItems:(int)numItems
   paymentInfoAvailable:(BOOL)paymentInfoAvailable
   currency:(NSString*)currency
   valToSum:(double)totalPrice {

   NSDictionary *params =
       [[NSDictionary alloc] initWithObjectsAndKeys:
           contentId, FBSDKAppEventParameterNameContentID,
           contentType, FBSDKAppEventParameterNameContentType,
           [NSNumber numberWithInt:numItems], FBSDKAppEventParameterNameNumItems,
           [NSNumber numberWithInt:paymentInfoAvailable ? 1 : 0], FBSDKAppEventParameterNamePaymentInfoAvailable,
           currency, FBSDKAppEventParameterNameCurrency,
           nil];

   [FBSDKAppEvents logEvent: FBSDKAppEventNameInitiatedCheckout
       valueToSum: totalPrice
       parameters: params];
}


/// 购买事件
/// @param numItems numItems description
/// @param contentType contentType description
/// @param contentId contentId description
/// @param currency currency description
/// @param price price description
- (void)logPurchasedEvent:(int)numItems
   contentType:(NSString*)contentType
   contentId:(NSString*)contentId
   currency:(NSString*)currency
   valToSum:(double)price {

   NSDictionary *params =
       [[NSDictionary alloc] initWithObjectsAndKeys:
           [NSNumber numberWithInt:numItems], FBSDKAppEventParameterNameNumItems,
           contentType, FBSDKAppEventParameterNameContentType,
           contentId, FBSDKAppEventParameterNameContentID,
           currency, FBSDKAppEventParameterNameCurrency,
           nil];

   [FBSDKAppEvents logPurchase:price
         currency: currency
       parameters: params];
}


#pragma mark -- 自定义事件

/// 自定义事件
/// @param eventName 事件名
/// @param params 参数
- (void)customeLogEventName:(NSString *)eventName withParameters:(NSDictionary *)params
{
    [FBSDKAppEvents logEvent:eventName parameters:params];
}


/// 自定义事件
/// @param eventName 事件名
- (void)customeLogEventName:(NSString *)eventName
{
    [FBSDKAppEvents logEvent:eventName];
}


/// 自定义事件
/// @param eventName 事件名
/// @param valueToSum 求和
/// @param params 参数
- (void)customeLogEventName:(NSString *)eventName valueToSum:(double)valueToSum withParameters:(NSDictionary *)params
{
    [FBSDKAppEvents logEvent:eventName valueToSum:valueToSum parameters:params];
}

/*

 - (void)logAdEvent:(NSString *)show
     valueToSum:(double)valueToSum {
     NSDictionary *params =
     @{@"show" : show};
     [FBSDKAppEvents
      logEvent:@"ad"
      valueToSum:valueToSum
      parameters:params];
 }
 
 **/
@end
