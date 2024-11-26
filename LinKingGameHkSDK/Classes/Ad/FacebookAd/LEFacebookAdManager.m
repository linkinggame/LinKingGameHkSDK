//
//  LEFacebookAdManager.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/17.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEFacebookAdManager.h"
#import "NSObject+LEAdditions.h"
#import "LEAdConfInfo.h"
#import "LESDKConfig.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import "LKLog.h"
#import "LEUser.h"
@interface LEFacebookAdManager ()<FBAdViewDelegate,FBInterstitialAdDelegate,FBRewardedVideoAdDelegate>
@property (nonatomic, strong) FBAdView *adView; // 横屏广告
@property (nonatomic, strong) FBInterstitialAd *interstitialAd;    // 插屏广告
@property (nonatomic, strong) FBRewardedVideoAd *rewardedVideoAd; // 视频激励广告

@property (nonatomic, copy) NSString *interstitial_id; // 插屏
@property (nonatomic, copy) NSString *banner_id; // banner
@property (nonatomic, copy) NSString *rewardvideo_id; // 激励视频
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) UIView *superView;
@end
static LEFacebookAdManager *_instance = nil;
@implementation LEFacebookAdManager
+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LEFacebookAdManager alloc] init];
        [_instance getFacebookDefaultParames];
    });
    return _instance;
}


/// 初始化广告
- (void)registerFacebookAd{
   LESDKConfig *sdkConf = [LESDKConfig getSDKConfig];

    if ([sdkConf.mode_debug boolValue] == YES) {
        // 获取模拟测试的 device 符号
        LKLogInfo(@"==testdeviceid:%@===",[FBAdSettings testDeviceHash]);
         
         NSDictionary *ad_config_ios = sdkConf.ad_config_ios;
        
        NSDictionary *facebook = ad_config_ios[@"audience"];
        NSString *testdeviceid = facebook[@"testdeviceid"];
        if (testdeviceid.exceptNull == nil || [testdeviceid isEqualToString:@""]) {
            testdeviceid = [FBAdSettings testDeviceHash];
        }
    
        NSMutableArray *testDevices = [NSMutableArray array];
        if ([testdeviceid rangeOfString:@","].location != NSNotFound) {
            
            NSArray *array = [testdeviceid componentsSeparatedByString:@","];
            
            for (NSString *deviced in array) {
                [testDevices addObject:deviced];
            }
        }else{
            [testDevices addObject:testdeviceid];
        }
        
        LKLogInfo(@"testdeviceid : %@",testdeviceid);
        [FBAdSettings addTestDevices:testDevices];
//        [FBAdSettings addTestDevice:@"b602d594afd2b0b327e07a06f36ca6a7e42546d0"];
    }else{
        LKLogInfo(@"上线不需要要使用测试设备");
      }
    
     
}
# pragma mark - 获取配置信息
- (void)getFacebookDefaultParames{
    
    NSDictionary *facebookInfo = [[LEAdConfInfo shared] getAdConfInfo:@"audience"];
    
    if ([facebookInfo isKindOfClass:[NSDictionary class]]) {
        NSArray *banners = facebookInfo[@"banner"];
        self.banner_id = banners.firstObject;
        
        NSArray *interstitials = facebookInfo[@"interstitial"];
        self.interstitial_id = interstitials.firstObject;
        
        NSArray * rewardvideos = facebookInfo[@"rewardvideo"];
        self.rewardvideo_id = rewardvideos.firstObject;
    }
    
}


- (FBAdSize)fbAdSize
{
    BOOL isIPAD = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
    return isIPAD ? kFBAdSizeHeight90Banner : kFBAdSizeHeight50Banner;
}
/// 初始化Banner广告
- (void)initializationFacebookBannerRootViewController:(UIViewController *)viewController superView:(UIView *)superView frame:(CGRect)frame{
    self.viewController = viewController;
    self.superView = superView;
     if (self.banner_id.exceptNull == nil) {
          NSAssert(self.banner_id.exceptNull != nil, @"banner placement id Can not be empty");
     }
     
       [self.adView removeFromSuperview];
      
       FBAdSize adSize = [self fbAdSize];
      // self.banner_Placement_ID = @"195517985148594_217866132913779";
        self.adView = [[FBAdView alloc] initWithPlacementID:self.banner_id
                                                     adSize:adSize
                                         rootViewController:viewController];
        // 高度最大250
        self.adView.frame = frame;
        // CGRectMake(0, 0, 300, 250);
        self.adView.delegate = self;

        [self.adView loadAd];
}
/// 展示Banner广告
- (void)showFacebookBanner{

    [self.superView addSubview:self.adView];
}
/// 移除Banner
- (void)removeBannerViewFromSuperView{
    [self.adView removeFromSuperview];
}


/// 初始化插屏广告
- (void)initializationFacebookInterstitialAd:(UIViewController *)viewController{

    self.viewController = viewController;
     if (self.interstitial_id.exceptNull == nil) {
         NSAssert(self.interstitial_id.exceptNull != nil, @"interstitial placement id Can not be empty");
     }
     
     
    // self.interstitial_Placement_ID = @"195517985148594_217866646247061";
     self.interstitialAd = [[FBInterstitialAd alloc] initWithPlacementID:self.interstitial_id];
     self.interstitialAd.delegate = self;
        LEUser *user =  [LEUser getUser];
        if (user.userId.exceptNull != nil) {
            [self.rewardedVideoAd setRewardDataWithUserID:user.userId withCurrency:@"USD"];
        }
           // For auto play video ads, it's recommended to load the ad
           // at least 30 seconds before it is shown
     [self.interstitialAd loadAd];
}
/// 展现插屏
- (void)showFacebookInterstitialAd{
    
         if (self.interstitialAd != nil && self.interstitialAd.isAdValid) {
       // You can now display the full screen ad using this code:
       [self.interstitialAd showAdFromRootViewController:self.viewController];
     }
}


/// 初始化激励视频广告
- (void)initializationFacebookRewardVideoAd:(UIViewController *)viewController{
     if (self.rewardvideo_id.exceptNull == nil) {
         NSAssert(self.rewardvideo_id.exceptNull != nil, @"rewardVideo placement id Can not be empty");
     }
     
    // self.rewardvideo_Placement_ID = @"195517985148594_217865809580478";
     self.viewController = viewController;
     self.rewardedVideoAd = [[FBRewardedVideoAd alloc] initWithPlacementID:self.rewardvideo_id];
     self.rewardedVideoAd.delegate = self;
     [self.rewardedVideoAd loadAd];
}
/// 展示激励视频广告
- (void)showFacebookRewardVideoAd{
    if (self.rewardedVideoAd && self.rewardedVideoAd.isAdValid) {
           // 默认展现有动画
        [self.rewardedVideoAd showAdFromRootViewController:self.viewController];

          // 不适用动画展现
          // [self.rewardedVideoAd showAdFromRootViewController:self animated:NO];
    }else {
//        if (self.rewardAdDidFailCallBack) {
//           self.rewardAdDidFailCallBack([self responserErrorMsg:@"当前广告还未准备好,请再次调用showRewardVideoAdPayuser" code:300]);
//       }
    }
}

- (BOOL)getRewardVideoAdIsValid {
    if (self.rewardedVideoAd == nil) {
        return false;
    }
    return self.rewardedVideoAd.isAdValid;
}
#pragma mark -- FBRewardedVideoAdDelegate
- (void)rewardedVideoAd:(FBRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error
{
    //奖励视频广告无法加载
    LKLogInfo(@"Rewarded video ad failed to load");

    LKLogInfo(@"Ad failed to load with error: %@", error);
    
    if (self.rewardAdDidFailCallBack) {
        self.rewardAdDidFailCallBack(error);
    }

}

- (void)rewardedVideoAdDidLoad:(FBRewardedVideoAd *)rewardedVideoAd
{
    // 视频广告已加载并可以显示
    // - (void)showRewardedVideoAd:(UIViewController *)viewController
    // 展示视频
    LKLogInfo(@"Video ad is loaded and ready to be displayed");

    if (self.rewardAdDidLoadCallBack) {
        self.rewardAdDidLoadCallBack();
    }

}

- (void)rewardedVideoAdDidClick:(FBRewardedVideoAd *)rewardedVideoAd
{
    // 点击了视频广告
    LKLogInfo(@"Video ad clicked");

    if (self.rewardAdDidClickCallBack) {
        self.rewardAdDidClickCallBack();
    }

}

- (void)rewardedVideoAdVideoComplete:(FBRewardedVideoAd *)rewardedVideoAd;
{

    // 奖励视频广告视频已完成-在完整视频观看后调用，然后显示广告结束卡。 您可以使用此事件来初始化您的奖励
    LKLogInfo(@"Rewarded Video ad video complete - this is called after a fullvideo view, before the ad end card is shown. You can use this event to initialize your reward");
    if (self.rewardAdVideoCompleteCallBack) {
        self.rewardAdVideoCompleteCallBack();
    }

}

- (void)rewardedVideoAdDidClose:(FBRewardedVideoAd *)rewardedVideoAd
{
    
    if (self.rewardAdDidCloseCallBack) {
        self.rewardAdDidCloseCallBack();
    }

    // 奖励视频广告已关闭-可以通过关闭应用程序或关闭视频结束卡来触发
    LKLogInfo(@"Rewarded Video ad closed - this can be triggered by closing the application, or closing the video end card");

}

// （可选）您可以添加以下附加功能来处理奖励视频广告将关闭或捕获奖励视频印象的情况：

- (void)rewardedVideoAdWillClose:(FBRewardedVideoAd *)rewardedVideoAd
{

    if (self.rewardAdWillCloseCallBack) {
        self.rewardAdWillCloseCallBack();
    }
    // 用户点击关闭按钮，广告即将关闭
    LKLogInfo(@"The user clicked on the close button, the ad is just about to close");

}

- (void)rewardedVideoAdWillLogImpression:(FBRewardedVideoAd *)rewardedVideoAd
{
    
    if (self.rewardAdWillLogImpressionCallBack) {
        self.rewardAdWillLogImpressionCallBack();
    }
    // 奖励视频展示已被捕获
    LKLogInfo(@"Rewarded Video impression is being captured");

}


#pragma mark -- FBInterstitialAdDelegate
- (void)interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd
{
    LKLogInfo(@"Ad is loaded and ready to be displayed");

    if (self.interstitialAdDidLoadCallBack) {
        self.interstitialAdDidLoadCallBack();
    }
  
}
// 验证展示次数和点击量记录
- (void)interstitialAdWillLogImpression:(FBInterstitialAd *)interstitialAd
{

    if (self.interstitialAdWillLogImpressionCallBack) {
        self.interstitialAdWillLogImpressionCallBack();
    }
    // 将此功能用作用户对广告印象的指示。
    LKLogInfo(@"The user sees the add");
  // Use this function as indication for a user's impression on the ad.

}

- (void)interstitialAdDidClick:(FBInterstitialAd *)interstitialAd
{
    
    if (self.interstitialAdDidClickCallBack) {
        self.interstitialAdDidClickCallBack();
    }

   // 用户点击了广告，将被带到目的地
    LKLogInfo(@"The user clicked on the ad and will be taken to its destination");
    // 将此功能用作用户点击广告的指示。
  // Use this function as indication for a user's click on the ad.

}

- (void)interstitialAdWillClose:(FBInterstitialAd *)interstitialAd
{

    if (self.interstitialAdWillCloseCallBack) {
        self.interstitialAdWillCloseCallBack();
    }
    LKLogInfo(@"The user clicked on the close button, the ad is just about to close");

}

- (void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd
{
    if (self.interstitialAdDidCloseCallBack) {
        self.interstitialAdDidCloseCallBack();
    }

    LKLogInfo(@"Interstitial had been closed");


}


// 在不展示广告时执行调试
- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
    
   
    if (self.interstitialAdDidFailCallBack) {
        self.interstitialAdDidFailCallBack(error);
    }
 
    LKLogInfo(@"Ad failed to load");

    LKLogInfo(@"Ad failed to load with error: %@", error);
}



#pragma mark -- FBAdViewDelegate

// 验证展示次数和点击量记录
- (void)adViewDidClick:(FBAdView *)adView
{
    //点击了横幅广告。
    LKLogInfo(@"Banner ad was clicked.");
    if (self.bannerAdViewDidClickCallBack) {
        self.bannerAdViewDidClickCallBack();
    }

}

- (void)adViewDidFinishHandlingClick:(FBAdView *)adView
{
    // 横幅广告确实完成了点击处理
    LKLogInfo(@"Banner ad did finish click handling.");
    if (self.bannerAdViewDidFinishHandlingClickCallBack) {
        self.bannerAdViewDidFinishHandlingClickCallBack();
    }

}

- (void)adViewWillLogImpression:(FBAdView *)adView
{
    // 正在捕获横幅广告展示。
    LKLogInfo(@"Banner ad impression is being captured.");
    if (self.bannerAdViewWillLogImpressionCallBack) {
        self.bannerAdViewWillLogImpressionCallBack();
    }

}

// 广告不显示时如何调试
- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error
{
    if (error.code == 1001) {
        LKLogInfo(@"暂时没有广告投放");
    }

    if (self.bannerAdViewDidLoadFailCallBack) {
        self.bannerAdViewDidLoadFailCallBack(error);
    }
    LKLogInfo(@"Ad failed to load with error: %@", error);
    
    LKLogInfo(@"Ad failed to load");
}

- (void)adViewDidLoad:(FBAdView *)adView
{
  // 广告已加载并可以显示
    LKLogInfo(@"Ad was loaded and ready to be displayed");
    if (self.bannerAdViewDidLoadCallBack) {
        self.bannerAdViewDidLoadCallBack();
    }

}

@end
