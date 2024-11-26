//
//  LEAdManager.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/17.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEAdManager.h"
#import "LEFacebookAdManager.h"
#import "LESDKConfig.h"
#import "LEIronSourceAdManager.h"
#import "LEPointManager.h"
#import <IronSource/IronSource.h>
@interface LEAdManager (){
    BOOL _isLoadRewardAdFail; // 激励视频是否加载失败
}
@property (nonatomic, assign) LEPLATFORM platform;
@property (nonatomic, assign) BOOL isautoload;
@property (nonatomic, assign) LEPAYUSERTYPE payUserBannerType;
@property (nonatomic, assign) LEPAYUSERTYPE payUserVideoType;
@property (nonatomic, assign) LEPAYUSERTYPE payUserInterstitialType;
@property (nonatomic, strong) UIViewController *viewController;
@end
LEAdManager *_instance = nil;
@implementation LEAdManager
+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LEAdManager alloc] init];
        [_instance getDefaultFacebookParames];
        [_instance adCallBack];
    });
    return _instance;
}

- (void)getDefaultFacebookParames{
    //[ISIntegrationHelper validateIntegration];
    // 查看是否开启自动加载
    NSNumber *isautoload = [LESDKConfig getSDKConfig].ad_config_ios[@"isautoload"];
    self.isautoload = [isautoload boolValue];
}

- (void)adCallBack{
    
    
#pragma mark -- 横屏 CallBack
    
#pragma mark -- Facebook
    [LEFacebookAdManager shared].bannerAdViewDidLoadCallBack = ^{
        
        // 横屏广告加载完成
        if ([self.delegate respondsToSelector:@selector(adDidFinishLoading:)]) {
            [self.delegate adDidFinishLoading:ADTYPE_BANNER];
        }
        
    };
    [LEFacebookAdManager shared].bannerAdViewDidLoadFailCallBack = ^(NSError * _Nonnull error) {
        
        if (error != nil && self.isautoload == YES) { // 发生错误并且自动加载
            // 初始化
        }
        if (error != nil) {
            NSDictionary *param = [self getAdBannerParamChannel:@"facebook"];
            [[LEPointManager shared] adLogEventName:@"show_fail" withParameters:param complete:nil];
        }
        if ([self.delegate respondsToSelector:@selector(bannerAdDidLoadFail:)]) {
            [self.delegate bannerAdDidLoadFail:error];
        }
        
 
    };
    [LEFacebookAdManager shared].bannerAdViewDidClickCallBack = ^{
    
        NSDictionary *param =  [self getAdBannerParamChannel:@"facebook"];
        [[LEPointManager shared] adLogEventName:@"click" withParameters:param complete:nil];
        if ([self.delegate respondsToSelector:@selector(bannerAdDidClick)]) {
            [self.delegate bannerAdDidClick];
        }
        

        
    };
    
    
    [LEFacebookAdManager shared].bannerAdViewWillLogImpressionCallBack = ^{
        NSDictionary *param = [self getAdBannerParamChannel:@"facebook"];
        [[LEPointManager shared] adLogEventName:@"show" withParameters:param complete:nil];
        if ([self.delegate respondsToSelector:@selector(bannerAdDidVisible)]) {
            [self.delegate bannerAdDidVisible];
        }

    };

#pragma mark -- IronSource
    [LEIronSourceAdManager shared].bannerAdDidLoadCallBack = ^{
        
        // 横屏广告加载完成
        if ([self.delegate respondsToSelector:@selector(adDidFinishLoading:)]) {
            [self.delegate adDidFinishLoading:ADTYPE_BANNER];
        }
        
    };
    [LEIronSourceAdManager shared].bannerAdDidLoadFailCallBack = ^(NSError * _Nonnull error) {
        NSDictionary *param = [self getAdBannerParamChannel:@"ironSource"];
        [[LEPointManager shared] adLogEventName:@"show_fail" withParameters:param complete:nil];
        if ([self.delegate respondsToSelector:@selector(bannerAdDidLoadFail:)]) {
            [self.delegate bannerAdDidLoadFail:error];
        }

    };
    [LEIronSourceAdManager shared].bannerAdWillPresentCallBack = ^{
        NSDictionary *param =  [self getAdBannerParamChannel:@"ironSource"];
        [[LEPointManager shared] adLogEventName:@"show" withParameters:param complete:nil];
        if ([self.delegate respondsToSelector:@selector(bannerAdDidVisible)]) {
            [self.delegate bannerAdDidVisible];
        }

    };
    [LEIronSourceAdManager shared].bannerAdDidClickCallBack = ^{
        NSDictionary *param = [self getAdBannerParamChannel:@"ironSource"];
        [[LEPointManager shared] adLogEventName:@"click" withParameters:param complete:nil];
        if ([self.delegate respondsToSelector:@selector(bannerAdDidClick)]) {
            [self.delegate bannerAdDidClick];
        }

    };
    [LEIronSourceAdManager shared].bannerAdDidDismissCallBack = ^{
        
        NSDictionary *param =  [self getAdBannerParamChannel:@"ironSource"];
        [[LEPointManager shared] adLogEventName:@"close" withParameters:param complete:nil];
        if ([self.delegate respondsToSelector:@selector(bannerAdDidClose)]) {
            [self.delegate bannerAdDidClose];
        }
    

    };
    
    

    
#pragma mark -- 插屏 CallBack
#pragma mark -- Facebook
    [LEFacebookAdManager shared].interstitialAdDidLoadCallBack = ^{
        
        if ([self.delegate respondsToSelector:@selector(adDidFinishLoading:)]) {
            [self.delegate adDidFinishLoading:ADTYPE_INTERSTITAL];
        }
        
        
    };
    [LEFacebookAdManager shared].interstitialAdDidFailCallBack = ^(NSError * _Nonnull error) {
        if (error != nil && self.isautoload == YES) { // 发生错误并且自动加载
            
        }
        NSDictionary *param = [self getAdInterstitialParamChannel:@"facebook"];
        [[LEPointManager shared] adLogEventName:@"show_fail" withParameters:param complete:nil];
        if ([self.delegate respondsToSelector:@selector(interstitialAdDidLoadFail:)]) {
            [self.delegate interstitialAdDidLoadFail:error];
        }
        

    };
    [LEFacebookAdManager shared].interstitialAdWillLogImpressionCallBack = ^{
        
        NSDictionary *param = [self getAdInterstitialParamChannel:@"facebook"];
        [[LEPointManager shared] adLogEventName:@"show" withParameters:param complete:nil];
        if ([self.delegate respondsToSelector:@selector(interstitialAdDidVisible)]) {
            [self.delegate interstitialAdDidVisible];
        }
        

    };
    [LEFacebookAdManager shared].interstitialAdDidClickCallBack = ^{
        
        NSDictionary *param = [self getAdInterstitialParamChannel:@"facebook"];
        [[LEPointManager shared] adLogEventName:@"click" withParameters:param complete:nil];
        if ([self.delegate respondsToSelector:@selector(interstitialAdDidClick)]) {
            [self.delegate interstitialAdDidClick];
        }

        
    };

    [LEFacebookAdManager shared].interstitialAdDidCloseCallBack = ^{
        
        NSDictionary *param = [self getAdInterstitialParamChannel:@"facebook"];
        [[LEPointManager shared] adLogEventName:@"close" withParameters:param complete:nil];
        if ([self.delegate respondsToSelector:@selector(interstitialAdDidClose)]) {
            [self.delegate interstitialAdDidClose];
        }
        
        

    };
    
#pragma mark -- IronSource
    
    [LEIronSourceAdManager shared].interstitialAdDidLoadCallBack = ^{
        
        if ([self.delegate respondsToSelector:@selector(adDidFinishLoading:)]) {
            [self.delegate adDidFinishLoading:ADTYPE_INTERSTITAL];
        }
        
    };
    [LEIronSourceAdManager shared].interstitialAdDidLoadFailCallBack = ^(NSError * _Nonnull error) {
        
            NSDictionary *param = [self getAdInterstitialParamChannel:@"ironSource"];
            [[LEPointManager shared] adLogEventName:@"show_fail" withParameters:param complete:nil];
        if ([self.delegate respondsToSelector:@selector(interstitialAdDidLoadFail:)]) {
            [self.delegate interstitialAdDidLoadFail:error];
        }

    };
    [LEIronSourceAdManager shared].interstitialAdDidShowCallBack = ^{
        NSDictionary *param = [self getAdInterstitialParamChannel:@"ironSource"];
        [[LEPointManager shared] adLogEventName:@"show" withParameters:param complete:nil];
        if ([self.delegate respondsToSelector:@selector(interstitialAdDidVisible)]) {
            [self.delegate interstitialAdDidVisible];
        }

    };
    [LEIronSourceAdManager shared].interstitialAdDidShowFailCallBack = ^(NSError * _Nonnull error) {
        NSDictionary *param = [self getAdInterstitialParamChannel:@"ironSource"];
        [[LEPointManager shared] adLogEventName:@"show_fail" withParameters:param complete:nil];
        if ([self.delegate respondsToSelector:@selector(interstitialAdDidLoadFail:)]) {
            [self.delegate interstitialAdDidLoadFail:error];
        }
        

        
    };
    [LEIronSourceAdManager shared].interstitialAdDidCloseCallBack = ^{
        NSDictionary *param = [self getAdInterstitialParamChannel:@"ironSource"];
          [[LEPointManager shared] adLogEventName:@"close" withParameters:param complete:nil];
        if ([self.delegate respondsToSelector:@selector(interstitialAdDidClose)]) {
            [self.delegate interstitialAdDidClose];
        }

    };
    [LEIronSourceAdManager shared].interstitialAdDidClickCallBack = ^{
        NSDictionary *param = [self getAdInterstitialParamChannel:@"ironSource"];
        [[LEPointManager shared] adLogEventName:@"click" withParameters:param complete:nil];
        if ([self.delegate respondsToSelector:@selector(interstitialAdDidClick)]) {
            [self.delegate interstitialAdDidClick];
        }

    };
    
    
#pragma mark -- 激励 CallBack
#pragma mark -- Facebook
    [LEFacebookAdManager shared].rewardAdDidLoadCallBack = ^{

        if ([self.delegate respondsToSelector:@selector(adDidFinishLoading:)]) {
            [self.delegate adDidFinishLoading:ADTYPE_REWARDVIDEO];
        }
    };
    [LEFacebookAdManager shared].rewardAdDidFailCallBack = ^(NSError * _Nonnull error) {
        NSDictionary *param =  [self getAdVideoParamChannel:@"facebook"];
        [[LEPointManager shared] adLogEventName:@"show_fail" withParameters:param complete:nil];
        if (error != nil && self.isautoload == YES) { // 发生错误并且自动加载
            self->_isLoadRewardAdFail = YES;
            [self initializationRewardVideoAd:self.viewController platform:LEPLATFORM_IronSource];
            self.isautoload = NO; // 取消自动加载否则会循环加载，目前每次打开应用只尝试一次
        }else{
            if ([self.delegate respondsToSelector:@selector(rewardAdDidLoadFail:)]) {
                [self.delegate rewardAdDidLoadFail:error];
            }
        }

    };
    [LEFacebookAdManager shared].rewardAdDidClickCallBack = ^{
        NSDictionary *param =   [self getAdVideoParamChannel:@"facebook"];
        [[LEPointManager shared] adLogEventName:@"click" withParameters:param complete:nil];
        if ([self.delegate respondsToSelector:@selector(rewardAdDidClick)]) {
            [self.delegate rewardAdDidClick];
        }
        

    };
    [LEFacebookAdManager shared].rewardAdVideoCompleteCallBack = ^{
        NSDictionary *param =   [self getAdVideoParamChannel:@"facebook"];
        [[LEPointManager shared] adLogEventName:@"complete" withParameters:param complete:nil];
        if ([self.delegate respondsToSelector:@selector(rewardAdWinReward)]) {
            [self.delegate rewardAdWinReward];
        }
        

    };
    [LEFacebookAdManager shared].rewardAdDidCloseCallBack = ^{
        NSDictionary *param =  [self getAdVideoParamChannel:@"facebook"];
        [[LEPointManager shared] adLogEventName:@"cancel" withParameters:param complete:nil];
        if ([self.delegate respondsToSelector:@selector(rewardAdDidClose)]) {
            [self.delegate rewardAdDidClose];
        }
        

        
    };
    [LEFacebookAdManager shared].rewardAdWillCloseCallBack = ^{
        
        
    };
    [LEFacebookAdManager shared].rewardAdWillLogImpressionCallBack = ^{

        if ([self.delegate respondsToSelector:@selector(rewardAdDidVisible)]) {
            [self.delegate rewardAdDidVisible];
        }
    };
#pragma mark -- IronSource
    
    [LEIronSourceAdManager shared].rewardAdHasChangedCallBack = ^{
       
    };
    
    [LEIronSourceAdManager shared].rewardADidShowFailCallBack = ^(NSError * _Nonnull error) {
        NSDictionary *param = [self getAdVideoParamChannel:@"ironSource"];
        [[LEPointManager shared] adLogEventName:@"show_fail" withParameters:param complete:nil];
        if ([self.delegate respondsToSelector:@selector(rewardAdDidLoadFail:)]) {
            [self.delegate rewardAdDidLoadFail:error];
        }

    };
    
    [LEIronSourceAdManager shared].rewardADidReceiveCallBack = ^{
        NSDictionary *param = [self getAdVideoParamChannel:@"ironSource"];
       [[LEPointManager shared] adLogEventName:@"complete" withParameters:param complete:nil];
        if ([self.delegate respondsToSelector:@selector(rewardAdWinReward)]) {
            [self.delegate rewardAdWinReward];
        }

    };
    
    [LEIronSourceAdManager shared].rewardADidCloseCallBack = ^{
        NSDictionary *param = [self getAdVideoParamChannel:@"ironSource"];
        [[LEPointManager shared] adLogEventName:@"cancel" withParameters:param complete:nil];
        if ([self.delegate respondsToSelector:@selector(rewardAdDidClose)]) {
            [self.delegate rewardAdDidClose];
        }

    };
    
    [LEIronSourceAdManager shared].rewardADidClickCallBack = ^{
        NSDictionary *param = [self getAdVideoParamChannel:@"ironSource"];
        [[LEPointManager shared] adLogEventName:@"click" withParameters:param complete:nil];
        if ([self.delegate respondsToSelector:@selector(rewardAdDidClick)]) {
            [self.delegate rewardAdDidClick];
        }

    };
    
    [LEIronSourceAdManager shared].rewardADidOpenCallBack = ^{


        if ([self.delegate respondsToSelector:@selector(adDidFinishLoading:)]) {
            [self.delegate adDidFinishLoading:ADTYPE_REWARDVIDEO];
        }
        
        if ([self.delegate respondsToSelector:@selector(rewardAdDidVisible)]) {
            [self.delegate rewardAdDidVisible];
        }
    };
    
}

/// 注册广告
- (void)registerAd{
    [[LEFacebookAdManager shared] registerFacebookAd];
    [[LEIronSourceAdManager shared] registerIronSourceAd];
    
}
/// 初始化广告
/// @param type 广告类型
/// @param viewController 控制器
/// @param superView 视图
- (void)initAd:(LEADTYPE)type rootViewController:(UIViewController * _Nonnull)viewController superView:(UIView * _Nullable)superView{
    if (type ==  ADTYPE_BANNER) {
        [self initializationBannerRootViewController:viewController superView:superView];
    }else if(type == ADTYPE_REWARDVIDEO){
        [self initializationRewardVideoAd:viewController];
    }else if(type == ADTYPE_INTERSTITAL){
        [self initializationRewardVideoAd:viewController];
    }
}

/// 展示横屏
- (void)showBanner{
    if (self.platform == LEPLATFORM_Facebook) {
         [self pointEventPullUp:@"banner" channel:@"facebook"];
         [[LEFacebookAdManager shared] showFacebookBanner];
      }else{
          [self pointEventPullUp:@"banner" channel:@"ironSource"];
          [[LEIronSourceAdManager shared] showIronSourceBanner];
          
      }
}

/// 展示横屏
/// @param type LK_UNDEFINED:未定义 LK_ALREADYPAY:已经付费 LK_NOPAY:非付费
- (void)showBannerPayuser:(LEPAYUSERTYPE)type{
    self.payUserBannerType = type;
    NSDictionary *param = @{};
    if (self.platform == LEPLATFORM_Facebook) {
         param = [self getAdBannerParamChannel:@"facebook"];
         [[LEPointManager shared] adLogEventName:@"pull_up" withParameters:param complete:nil];
         [[LEFacebookAdManager shared] showFacebookBanner];
      }else{
          param = [self getAdBannerParamChannel:@"ironSource"];
          [[LEPointManager shared] adLogEventName:@"pull_up" withParameters:param complete:nil];
          [[LEIronSourceAdManager shared] showIronSourceBanner];
      }
    
    
}

- (NSDictionary *)getAdBannerParamChannel:(NSString *)channel{
    NSDictionary *param = @{};
    if (self.payUserBannerType == LE_UNDEFINED) {
        param = @{@"ad_type":@"banner",@"ad_channel":channel};
    } else if (self.payUserBannerType == LE_PAY){
        param = @{@"ad_type":@"banner",@"ad_channel":channel,@"pay_user":@"1"}; // 付费
    } else if (self.payUserBannerType == LE_NOPAY){
        param = @{@"ad_type":@"banner",@"ad_channel":channel,@"pay_user":@"2"}; // 非付费
    } else {
        param = @{@"ad_type":@"banner",@"ad_channel":channel};
    }
    return param;
}


/// 展现插屏
- (void)showInterstitialAd{
    if (self.platform == LEPLATFORM_Facebook) {
         [self pointEventPullUp:@"interstitial" channel:@"facebook"];
         [[LEFacebookAdManager shared] showFacebookInterstitialAd];
      }else{
         [self pointEventPullUp:@"interstitial" channel:@"ironSource"];
         [[LEIronSourceAdManager shared] showIronSourceInterstitialAd];
      }
}


/// 展现插屏
/// @param type LK_UNDEFINED:未定义 LK_ALREADYPAY:已经付费 LK_NOPAY:非付费
- (void)showInterstitialAdPayuser:(LEPAYUSERTYPE)type{
    self.payUserInterstitialType = type;
    
    if (self.platform == LEPLATFORM_Facebook) {;
        NSDictionary *param = [self getAdInterstitialParamChannel:@"facebook"];
        [[LEPointManager shared] adLogEventName:@"pull_up" withParameters:param complete:nil];
        [[LEFacebookAdManager shared] showFacebookInterstitialAd];
      }else{
          NSDictionary *param = [self getAdInterstitialParamChannel:@"ironSource"];
          [[LEPointManager shared] adLogEventName:@"pull_up" withParameters:param complete:nil];
         [[LEIronSourceAdManager shared] showIronSourceInterstitialAd];
      }
}


- (NSDictionary *)getAdInterstitialParamChannel:(NSString *)channel{
    NSDictionary *param = @{};
    if (self.payUserInterstitialType == LE_UNDEFINED) {
        param = @{@"ad_type":@"interstitial",@"ad_channel":channel};
    } else if (self.payUserInterstitialType == LE_PAY){
        param =  @{@"ad_type":@"interstitial",@"ad_channel":channel,@"pay_user":@"1"};// 付费
    } else if (self.payUserInterstitialType == LE_NOPAY){
        param =  @{@"ad_type":@"interstitial",@"ad_channel":channel,@"pay_user":@"2"}; // 非付费
    } else {
        param = @{@"ad_type":@"interstitial",@"ad_channel":channel};
    }
    return param;
}




/// 展示激励视频广告
- (void)showRewardVideoAd{
    if (self.platform == LEPLATFORM_Facebook) {
         [self pointEventPullUp:@"video" channel:@"facebook"];
         [[LEFacebookAdManager shared] showFacebookRewardVideoAd];
      }else{
           [self pointEventPullUp:@"video" channel:@"ironSource"];
           [[LEIronSourceAdManager shared] showIronSourceRewardVideoAd];
      }
}

/// 是否可以获取
- (BOOL)getRewardVideoAdIsValid {
    if (self.platform == LEPLATFORM_Facebook) {
        return [[LEFacebookAdManager shared] getRewardVideoAdIsValid];
      }else{
          return [[LEIronSourceAdManager shared] getRewardVideoAdIsValid];
      }
}

/// 展示激励视频广告
/// @param type LK_UNDEFINED:未定义 LK_ALREADYPAY:已经付费 LK_NOPAY:非付费
- (void)showRewardVideoAdPayuser:(LEPAYUSERTYPE)type{
    self.payUserVideoType = type;
    
    if (self.platform == LEPLATFORM_Facebook) {
        NSDictionary *param = [self getAdVideoParamChannel:@"facebook"];
        [[LEPointManager shared] adLogEventName:@"pull_up" withParameters:param complete:nil];
        [[LEFacebookAdManager shared] showFacebookRewardVideoAd];
        
        [[LEPointManager shared] adLogEventName:@"show" withParameters:param complete:nil];
      }else{
          NSDictionary *param = [self getAdVideoParamChannel:@"ironSource"];
          [[LEPointManager shared] adLogEventName:@"pull_up" withParameters:param complete:nil];
        [[LEIronSourceAdManager shared] showIronSourceRewardVideoAd];
          
        [[LEPointManager shared] adLogEventName:@"show" withParameters:param complete:nil];
      }
}

- (NSDictionary *)getAdVideoParamChannel:(NSString *)channel{
    NSDictionary *param = @{};
    if (self.payUserVideoType == LE_UNDEFINED) {
        param = @{@"ad_type":@"video",@"ad_channel":channel};
    } else if (self.payUserVideoType == LE_PAY){
        param =  @{@"ad_type":@"video",@"ad_channel":channel,@"pay_user":@"1"};;// 付费
    } else if (self.payUserVideoType == LE_NOPAY){
        param =  @{@"ad_type":@"video",@"ad_channel":channel,@"pay_user":@"2"};// 非付费
    }else{
        param = @{@"ad_type":@"video",@"ad_channel":channel};
    }
    return param;
}


/// 初始化Banner广告
- (void)initializationBannerRootViewController:(UIViewController *)viewController superView:(UIView *)superView{
 
    // LEPLATFORM_Facebook
    [self initializationBannerRootViewController:viewController superView:superView platform:LEPLATFORM_Facebook];
    
}

- (void)initializationBannerRootViewController:(UIViewController *)viewController superView:(UIView *)superView platform:(LEPLATFORM)platform{
    self.platform = platform;
    self.viewController = viewController;
    if (platform == LEPLATFORM_Facebook) {
        [self initializationFacebookBannerRootViewController:viewController superView:superView];
    }else{
        [self initializationIronSourceBannerRootViewController:viewController superView:superView];
        
    }
    
}

/// 移除Banner
- (void)removeBannerViewFromSuperView{
    [[LEFacebookAdManager shared]  removeBannerViewFromSuperView];
}

/// 初始化插屏广告
- (void)initializationInterstitialAd:(UIViewController *)viewController{
    
    [self initializationInterstitialAd:viewController platform:LEPLATFORM_Facebook];
}


- (void)initializationInterstitialAd:(UIViewController *)viewController platform:(LEPLATFORM)platform{
    self.platform = platform;
    self.viewController = viewController;
    if (platform == LEPLATFORM_Facebook) {
        [self initializationFacebookInterstitialAd:viewController];
    }else{
        
        [self initializationIronSourceInterstitialAd:viewController];
    }
}


/// 初始化激励视频广告
- (void)initializationRewardVideoAd:(UIViewController *)viewController{
    [self initializationRewardVideoAd:viewController platform:LEPLATFORM_Facebook];
    
}


- (void)initializationRewardVideoAd:(UIViewController *)viewController platform:(LEPLATFORM)platform{
    self.platform = platform;
    self->_isLoadRewardAdFail = NO; // 初始化没有加载失败
    self.viewController = viewController;
    if (self.platform == LEPLATFORM_Facebook) {
        [self initializationFacebookRewardVideoAd:viewController];
      }else{
        [self initializationIronSourceRewardVideoAd:viewController];
      }
    
}


#pragma mark -- 拉起打点
- (void)pointEventPullUp:(NSString *)adType channel:(NSString *)channel{
    NSDictionary *param = @{@"ad_type":adType,@"ad_channel":channel};
    [[LEPointManager shared] adLogEventName:@"pull_up" withParameters:param complete:nil];
}

#pragma mark -- 初始化
/// 初始化Banner广告
- (void)initializationFacebookBannerRootViewController:(UIViewController *)viewController superView:(UIView *)superView {
     CGRect rect = CGRectZero;
     rect = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 60, [UIScreen mainScreen].bounds.size.width, 60);
    [[LEFacebookAdManager shared] initializationFacebookBannerRootViewController:viewController superView:superView frame:rect];
}

/// 初始化插屏广告
- (void)initializationFacebookInterstitialAd:(UIViewController *)viewController{
    [[LEFacebookAdManager shared] initializationFacebookInterstitialAd:viewController];
}


/// 初始化激励视频广告
- (void)initializationFacebookRewardVideoAd:(UIViewController *)viewController{
    [[LEFacebookAdManager shared] initializationFacebookRewardVideoAd:viewController];
}



/// 初始化Banner广告
- (void)initializationIronSourceBannerRootViewController:(UIViewController *)viewController superView:(UIView *)superView {
     CGRect rect = CGRectZero;
     rect = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 80, [UIScreen mainScreen].bounds.size.width, 80);
    [[LEIronSourceAdManager shared] initializationIronSourceBannerRootViewController:viewController superView:superView frame:rect];
}

/// 初始化插屏广告
- (void)initializationIronSourceInterstitialAd:(UIViewController *)viewController{
    [[LEIronSourceAdManager shared] initializationIronSourceInterstitialAd:viewController];
}


/// 初始化激励视频广告
- (void)initializationIronSourceRewardVideoAd:(UIViewController *)viewController{
    [[LEIronSourceAdManager shared] initializationIronSourceRewardVideoAd:viewController];
}




@end
