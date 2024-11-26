//
//  LEPointManager.m
//  LinKingEnSDK
//
//  Created by MrDML on 2020/8/16.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEPointManager.h"
#import "LESFPointManager.h"
#import "LEAFManager.h"
#import "LEFBAnalyticsManager.h"
@interface LEPointManager ()

@end

static LEPointManager *_instance = nil;
@implementation LEPointManager


+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LEPointManager alloc] init];
    });
    return _instance;
}

// ========== 接口调整-begin ==========

// === 标准事件

/// 等级
/// @param level 等级
/// @param serverId 区服Id
/// @param roleId 角色id
/// @param roleName 角色名
- (void)logLevel:(int )level serverId:(NSString *)serverId roleId:(NSString *)roleId roleName:(NSString *)roleName{
    [[LESFPointManager shared] logAchieveLevelEvent:level serverId:serverId roleId:roleId roleName:roleName complete:nil];
    
    [[LEAFManager shared] afLogLevel:level score:level];
}


/// 关卡
/// @param stage 关卡
/// @param serverId 区服id
/// @param roleId 角色id
/// @param roleName 角色名
- (void)logStage:(int)stage serverId:(NSString *)serverId roleId:(NSString *)roleId roleName:(NSString *)roleName{
    
    // LK
    [[LESFPointManager shared] logAchieveStageEvent:stage serverId:serverId roleId:roleId roleName:roleName complete:nil];
    
    
    NSDictionary *values = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithInt:stage],@"stage",
                            serverId,@"serverId",
                            roleId,@"roleId",
                          roleName,@"roleName",
                          nil];
    // AF
    [[LEAFManager shared] afLogTrackEvent:@"stage" withValues:values];
    
    // FB
    [[LEFBAnalyticsManager shared] logUnlockedAchievementEvent:[NSString stringWithFormat:@"%d",stage]];
}

/// 新手引导
/// @param contentId 内容id
/// @param content 内容
/// @param serverId 区服ID
/// @param roleId 角色id
/// @param roleName 角色名
- (void)logTutorial:(NSString *)contentId content:(NSString *)content EventServerId:(NSString *)serverId roleId:(NSString *)roleId roleName:(NSString *)roleName{
    // LK
    [[LESFPointManager shared] logAchieveCompleteTutorialId:content eventServerId:serverId roleId:roleId roleName:roleName complete:nil];
    
    // AF
    [[LEAFManager shared] afLogTutorialCompletionWithSuccess:YES userId:contentId desc:content];
    
    // FB
    [[LEFBAnalyticsManager shared] logCompletedTutorialEvent:content success:YES];
}

/// 进入游戏
/// @param serverId 区服id
/// @param roleId 角色id
/// @param roleName 角色名
/// @param enterGame 进入游戏（false单区,true多区）
- (void)logEnterGame:(NSString *)serverId roleId:(NSString *)roleId roleName:(NSString *)roleName enterGame:(BOOL)enterGame{

    [[LESFPointManager shared] logEnterGameServerId:serverId roleId:roleId roleName:roleName enterGame:enterGame complete:nil];
    
    NSDictionary *values = [NSDictionary dictionaryWithObjectsAndKeys:
                          serverId,@"serverId",
                          roleId,@"roleId",
                          roleName,@"roleName",
                          [NSNumber numberWithBool:enterGame],@"enterGame",
                          nil];
    
    
    [[LEAFManager shared] afLogTrackEvent:@"enterGame" withValues:values];
    
    
    [[LEFBAnalyticsManager shared] customeLogEventName:@"enterGame" withParameters:values];
}


/// 创建角色
/// @param serverId 区服Id
/// @param roleId 角色id
/// @param roleName 角色名
- (void)logRoleCreate:(NSString *)serverId roleId:(NSString *)roleId roleName:(NSString *)roleName{
    
    [[LESFPointManager shared] logRoleCreate:serverId roleId:roleId roleName:roleName];
    
}

/// 角色登录打点
/// @param serverId 区服Id
/// @param roleId 角色id
- (void)logRoleLogin:(NSString *)serverId roleId:(NSString *)roleId{
    [[LESFPointManager shared] logRoleLogin:serverId roleId:roleId];
}
// === 自定义事件

/// 无参自定义事件
/// @param event 事件名
- (void)logEvent:(NSString *)event {
    [self logEvent:event withValues:@{}];
}

/// 有参自定义事件
/// @param event 事件名
/// @param values 参数
- (void)logEvent:(NSString *)event withValues:(NSDictionary *)values{
    // LK 自定义打点
    [[LESFPointManager shared] customePointEventName:event withParameters:values complete:nil];
    
    // AF 自定义打点
    [[LEAFManager shared] afLogTrackEvent:event withValues:values];
    
    // FB 自定义打点
    [[LEFBAnalyticsManager shared] customeLogEventName:event withParameters:values];
}



// ========== 接口调整-end ==========


/// 激活打点
/// @param complete <#complete description#>
- (void)activatePointWithComplete:(void(^)(NSError *error))complete{
    [[LESFPointManager shared] activatePointWithComplete:^(NSError * _Nullable error) {
        complete(error);
    }];
}

// 标准打点
- (void)standardLogEventName:(NSString *)eventName withParameters:(NSDictionary *)params complete:(void(^)(NSError *error))complete{
    [[LESFPointManager shared] standardPointEventName:eventName withParameters:params complete:^(NSError * _Nullable error) {
        if (complete) {
            complete(error);
        }
    }];
    
}
- (void)standardLogEventName:(NSString *)eventName complete:(void(^)(NSError *error))complete{
    [[LESFPointManager shared] standardPointEventName:eventName withParameters:nil complete:^(NSError * _Nullable error) {
       if (complete) {
           complete(error);
       }
        
    }];
    
}

// 自定义打点
- (void)customeLogEventName:(NSString *)eventName withParameters:(NSDictionary *)params complete:(void(^)(NSError *error))complete{
    [[LESFPointManager shared] customePointEventName:eventName withParameters:params complete:complete];
    
    // AF 自定义打点
    [[LEAFManager shared] afLogTrackEvent:eventName withValues:params];
    
}
- (void)customeLogEventName:(NSString *)eventName complete:(void(^)(NSError *error))complete{
    [[LESFPointManager shared] customePointEventName:eventName withParameters:nil complete:complete];
    // AF 自定义打点
    [[LEAFManager shared] afLogTrackEvent:eventName withValues:@{}];
}


// 广告打点
- (void)adLogEventName:(NSString *)eventName withParameters:(NSDictionary *)params complete:(void(^)(NSError *error))complete{
     [[LESFPointManager shared] adstandardPointEventName:eventName withParameters:params complete:complete];
    
    // AF 自定义打点
    [[LEAFManager shared] afLogTrackEvent:eventName withValues:@{}];
    
    // FB 打点
    [[LEFBAnalyticsManager shared] customeLogEventName:eventName];
    
}

/// 等级
/// @param level 等级
- (void)logAchieveLevelEvent:(int )level serverId:(NSString *)serverId roleId:(NSString *)roleId roleName:(NSString *)roleName complete:(void(^_Nullable)(NSError * _Nullable error))complete{

    // LK
    [[LESFPointManager shared] logAchieveLevelEvent:level serverId:serverId roleId:roleId roleName:roleName complete:complete];
    
    // AF
    [[LEAFManager shared] afLogLevel:level score:level];
    
    // FB
    [[LEFBAnalyticsManager shared] logAchievedLevelEvent:[NSString stringWithFormat:@"%d",level]];

}

/// 关卡
- (void)logAchieveStageEvent:(int)stage serverId:(NSString *)serverId roleId:(NSString *)roleId roleName:(NSString *)roleName complete:(void(^_Nullable)(NSError * _Nullable error))complete{
    
    // LK
    [[LESFPointManager shared] logAchieveStageEvent:stage serverId:serverId roleId:roleId roleName:roleName complete:complete];
    
    // AF
    [[LEAFManager shared] afLogTrackEvent:@"stage" withValues:@{
        @"stage":[NSNumber numberWithInt:stage],
        @"serverId":serverId,
        @"roleId":roleId,
        @"roleName":roleName
    }];
    
    // FB
    [[LEFBAnalyticsManager shared] logUnlockedAchievementEvent:[NSString stringWithFormat:@"%d",stage]];
    
    

}
/// 新手引导
- (void)logAchieveCompleteTutorialId:(NSString *)contentId content:(NSString *)content EventServerId:(NSString *)serverId roleId:(NSString *)roleId roleName:(NSString *)roleName complete:(void(^_Nullable)(NSError * _Nullable error))complete{
    
    // LK
    [[LESFPointManager shared] logAchieveCompleteTutorialId:content eventServerId:serverId roleId:roleId roleName:roleName complete:complete];
    
    // AF
    [[LEAFManager shared] afLogTutorialCompletionWithSuccess:YES userId:contentId desc:content];
    
    // FB
    [LEFBAnalyticsManager shared];
}


/// 进入游戏
- (void)logEnterGameServerId:(NSString *)serverId roleId:(NSString *)roleId roleName:(NSString *)roleName enterGame:(BOOL)enterGame complete:(void(^_Nullable)(NSError * _Nullable error))complete{
    [[LESFPointManager shared] logEnterGameServerId:serverId roleId:roleId roleName:roleName enterGame:enterGame complete:complete];
}



/// 用于追踪付款信息配置状态
/// @param success 是否成功
- (void)logAddPaymentInfoSuccess:(BOOL)success{
   // [[LEAFManager shared] afLogAddPaymentInfoSuccess:success];
}
/// 用于追踪付款信息配置状态
/// @param price 价格
/// @param type 商品类型
/// @param currency 货币类型
/// @param goodsId 商品id
/// @param content 商品描述
/// @param quantity 商品数量
- (void)logAddGoodsCartWithPrice:(NSNumber *)price goodsType:(NSString *)type currency:(NSString *)currency goodsId:(NSString *)goodsId content:(NSString *)content quantity:(int)quantity{
   [[LEAFManager shared] afLogAddGoodsCartWithPrice:price goodsType:type currency:currency goodsId:goodsId content:content quantity:quantity];
    
}

/// 完成购买
/// @param price     购买产生的收入
/// @param orderId 购买生成的订单ID
/// @param receiptId 买家生成的收据ID
- (void)logCompletedPurchase:(NSNumber *)price orderId:(NSString *)orderId receiptId:(NSString *)receiptId{
    
 [[LEAFManager shared] afLogCompletedPurchase:price orderId:orderId receiptId:receiptId];
}

/// 用于追踪特定商品的“添加到愿望清单”事件
/// @param price 价格
/// @param type 类型
/// @param goodsId 物品id
/// @param content 详细描述
/// @param currency 货币类型
/// @param quantity 数量
- (void)logAddWishlistWithPrice:(NSNumber *)price goodsType:(NSString *)type goodsId:(NSString *)goodsId content:(NSString *)content currency:(NSString *)currency quantity:(int)quantity{
    
   [[LEAFManager shared] afLogAddWishlistWithPrice:price goodsType:type goodsId:goodsId content:content currency:currency quantity:quantity];
}

/// 用于追踪用户注册方式
/// @param style 注册方式
- (void)logCompleteRegistrationStyle:(NSString *)style{
    
   [[LEAFManager shared] afLogLoginStyle:style];
}


/// 用于追踪结账事件
/// @param price 价格
/// @param contentType 商品类型
/// @param contentId 商品id
/// @param quantity 商品数量
/// @param payment 支付方式（信息）
/// @param currency 货币类型
- (void)logInitiatedCheckoutWithPrice:(NSNumber *)price contentType:(NSString *)contentType contentId:(NSString *)contentId content:(NSString *)content  quantity:(int)quantity payment:(NSString *)payment currency:(NSString *)currency{
    
    [[LEAFManager shared] afLogInitiatedCheckoutWithPrice:price contentType:contentType contentId:contentId content:content quantity:quantity payment:payment currency:currency];
}

/// 用于追踪购买事件（及相关收入）
/// @param price 价格
/// @param type 订单了类型
/// @param currency 货币类型 USD
/// @param orderId 订单Id
/// @param desc 描述
/// @param quantity 数量
- (void)logPurchaseWithPrice:(NSNumber *)price type:(NSString *)type currency:(NSString *)currency orderId:(NSString *)orderId desc:(NSString *)desc quantity:(int)quantity{
    
   [[LEAFManager shared] afLogPurchaseWithPrice:price type:type currency:currency orderId:orderId desc:desc quantity:quantity];
}

/// 用于追踪付费订阅购买
/// @param price 价格
- (void)logSubscribeWithPrice:(NSNumber *)price{
    
   [[LEAFManager shared] afLogSubscribeWithPrice:price];
    
}

/// 用于追踪产品的免费试用的开始
/// @param price 价格
/// @param currency 货币类型
- (void)logStartTrialWithPrice:(NSNumber *)price currency:(NSString *)currency{
    
  [[LEAFManager shared] afLogStartTrialWithPrice:price currency:currency];
}

/// 用于追踪应用/商品评级事件
/// @param rating 当前评级
/// @param contentType 评级类型
/// @param contentId 评级id
/// @param content 评级内容
/// @param maxRating 最大评级
- (void)logWithRating:(CGFloat)rating contentType:(NSString *)contentType contentId:(NSString *)contentId content:(NSString *)content maxRating:(CGFloat)maxRating{
    
   [[LEAFManager shared] afLogWithRating:rating contentType:contentType contentId:contentId content:content maxRating:maxRating];
}

/// 用于追踪搜索事件
/// @param contentType 搜索类别
/// @param searchWords 搜索关键字
/// @param success 是否搜索成功
- (void)logSearchWithContentType:(NSString *)contentType searchWords:(NSString *)searchWords success:(BOOL)success{
    
   [[LEAFManager shared] afLogSearchWithContentType:contentType searchWords:searchWords success:success];
}

/// 用于追踪积分花费事件
/// @param price 价格
/// @param contentType 事件类型
/// @param contentId 事件id
/// @param content 事件内容
- (void)logSpentCreditsWithPrice:(NSNumber *)price ContentType:(NSString *)contentType contentId:(NSString *)contentId content:(NSString *)content{
    
    [[LEAFManager shared] afLogSpentCreditsWithPrice:price ContentType:contentType contentId:contentId content:content];
}

/// 用于追踪成就解锁事件
/// @param desc 详细描述
- (void)logAchievementUnlockedWithDesc:(NSString *)desc{
    
   [[LEAFManager shared] afLogAchievementUnlockedWithDesc:desc];
}

/// 用于追踪内容视图事件
/// @param price 价格
/// @param contentType 内容类型
/// @param contentId 内容id
/// @param content 内容描述
/// @param currency 货币类型
- (void)logContentViewWithPrice:(NSNumber *)price contentType:(NSString *)contentType contentId:(NSString *)contentId content:(NSString *)content currency:(NSString *)currency{
    
   [[LEAFManager shared] afLogContentViewWithPrice:price contentType:contentType contentId:contentId content:content currency:currency];
    
}

/// 用于追踪列表视图事件
/// @param contentType 列表视图类别
/// @param contentList 列表集合
- (void)logListViewWithContentType:(NSString *)contentType contentList:(NSArray *)contentList{
    
   [[LEAFManager shared] afLogListViewWithContentType:contentType contentList:contentList];
}

///  用于追踪应用中展示广告的点击次数
- (void)logAdclickWithAdStyle:(NSString *)style{
    
    [[LEAFManager shared] afLogLoginStyle:style];
}

/// 用于追踪应用中展示广告的展示次数
- (void)logAdView:(NSString *)style{
    
    [[LEAFManager shared] afLogLoginStyle:style];
}

/// 用于追踪分享事件
/// @param desc 分享描述
- (void)logShareDesc:(NSString*)desc{
    
    [[LEAFManager shared] afLogShareDesc:desc];
}

/// 用于追踪邀请（社交）事件
- (void)logInvite{
    
   [[LEAFManager shared] afLogInvite];
}

///  用于追踪用户的重参与事件
- (void)logActive{
    
   [[LEAFManager shared] afLogActive];
    
}

/// 用于追踪用户登录事件
- (void)logLoginStyle:(NSString *)style{
    
    [[LEAFManager shared] afLogLoginStyle:style];
}

/// 从推送通知打开 用于追踪从推送通知打开应用的事件
- (void)logOpenedFromPushNotification{
    
    [[LEAFManager shared] afLogOpenedFromPushNotification];
    
}

/// 用于追踪更新事件
/// @param contentId 更新事件Id
- (void)logWithContentId:(NSString *)contentId{
    
    [[LEAFManager shared] afLogWithContentId:contentId];
}



/// 设置用户id
/// @param userId <#userId description#>
- (void)logTrackSetCustomerUserID:(NSString *)userId{
    
   [[LEAFManager shared] afLogTrackSetCustomerUserID:userId];
}



@end
