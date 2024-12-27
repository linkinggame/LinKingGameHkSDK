//
//  LEIronSourceAdManager.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/17.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEIronSourceAdManager.h"
#import <IronSource/IronSource.h>
#import "NSObject+LEAdditions.h"
#import "LEAdConfInfo.h"
#import "LESDKConfig.h"
#import "LKLog.h"
@interface LEIronSourceAdManager ()<LevelPlayBannerDelegate,LevelPlayInterstitialDelegate,LevelPlayRewardedVideoDelegate>
@property (nonatomic, copy) NSString *appKey;

@property (nonatomic, strong) ISBannerView *bannerView;

@property (nonatomic, strong) UIView *superView;

@property (nonatomic, assign) CGRect frame;

@property (nonatomic, strong) UIViewController *viewController;

@property (nonatomic, copy) NSString * interstitial_id;

@property (nonatomic, copy) NSString * rewardedVideo_id;

@property (nonatomic, copy) NSString * banner_id;

@property (nonatomic, assign) BOOL isReady;

@end
static LEIronSourceAdManager *_intance = nil;
@implementation LEIronSourceAdManager
+ (instancetype)shared{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _intance = [[LEIronSourceAdManager alloc] init];
        [_intance getDefaultParames];
        [IronSource setConsent:YES];

    });
    return _intance;
}
# pragma mark - 获取配置信息
- (void)getDefaultParames{
    NSDictionary *ironSrcDict =  [[LEAdConfInfo shared] getAdConfInfo:@"ironsrc"];
    if ([ironSrcDict isKindOfClass:[NSDictionary class]]) {
        self.appKey = ironSrcDict[@"appid"];
        
        NSArray *rewardvideos = ironSrcDict[@"rewardvideo"];
        if (rewardvideos.count >= 1) {
            self.rewardedVideo_id = rewardvideos.firstObject;
        }
        
        NSArray *interstitials = ironSrcDict[@"interstitial"];
        if (interstitials.count >= 1) {
             self.interstitial_id = interstitials.firstObject;
        }

        NSArray *banners = ironSrcDict[@"banner"];
        if (banners.count >= 1) {
            self.banner_id = interstitials.firstObject;
        }
    }
    LKLogInfo(@"=====");
}


/// 初始化广告
- (void)registerIronSourceAd{
    [IronSource initWithAppKey:self.appKey];
}
#pragma mark - Orientation delegate
- (void)orientationChanged:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.bannerView) {
            self.bannerView.frame = self.frame;
        }
    });
    
}

/// 初始化Banner广告
- (void)initializationIronSourceBannerRootViewController:(UIViewController *)viewController superView:(UIView *)superView frame:(CGRect)frame{
    if (self.bannerView != nil) {
      [self.bannerView removeFromSuperview];
      [self destroyBanner];
    }
    self.frame = frame;
    self.superView = superView;
    self.viewController = viewController;
    if (self.appKey.exceptNull == nil) {
       NSAssert(self.appKey.exceptNull != nil, @"appKey id cannot be empty");
    }

    [IronSource initWithAppKey:self.appKey adUnits:@[IS_BANNER]];

    //[IronSource setBannerDelegate:self];
    [IronSource setLevelPlayBannerDelegate:self];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:@"UIDeviceOrientationDidChangeNotification"
                                               object:nil];

     // 加载广告
    [IronSource loadBannerWithViewController:viewController size:ISBannerSize_BANNER];
}
// 销毁广告品
- (void)destroyBanner{
    if (self.bannerView != nil) {
        [IronSource destroyBanner:self.bannerView];
    }
    
}
/// 展示Banner广告
- (void)showIronSourceBanner{
      self.bannerView.frame = self.frame;
      [self.superView addSubview:self.bannerView];
}
/// 移除Banner
- (void)removeBannerViewFromSuperView{
    if (self.bannerView) {
         [self.bannerView removeFromSuperview];
    }
}


/// 初始化插屏广告
- (void)initializationIronSourceInterstitialAd:(UIViewController *)viewController{

    self.viewController  = viewController;

    if (self.appKey.exceptNull == nil) {
        NSAssert(self.appKey.exceptNull != nil, @"appKey id cannot be empty");
    }

    [IronSource initWithAppKey:self.appKey adUnits:@[IS_INTERSTITIAL]];

    //[IronSource setInterstitialDelegate:self];
    [IronSource setLevelPlayInterstitialDelegate:self];

    //  加载非页内广告
    [IronSource loadInterstitial];
}
/// 展现插屏
- (void)showIronSourceInterstitialAd{
    
    if ([IronSource hasInterstitial]) {
        LKLogInfo(@"当前广告可用");
        [IronSource showInterstitialWithViewController:self.viewController placement:self.interstitial_id];
    }else{
        LKLogInfo(@"当前广告不可用");
        if (self.interstitialAdDidLoadFailCallBack) {
            self.interstitialAdDidLoadFailCallBack([self responserErrorMsg:@"当前广告不可用" code:-1]);
        }
    }
}


/// 初始化激励视频广告
- (void)initializationIronSourceRewardVideoAd:(UIViewController *)viewController{
    self.isReady = NO;
//    if ([IronSource hasRewardedVideo]){
//        if (self.rewardAdHasChangedCallBack) {
//            self.isReady = YES;
//            self.rewardAdHasChangedCallBack();
//        }
//    }else{
//        self.viewController = viewController;
//        if (self.appKey.exceptNull == nil) {
//            NSAssert(self.appKey.exceptNull != nil, @"appKey id cannot be empty");
//        }
//
//        [IronSource setRewardedVideoDelegate:self];
//
//        [IronSource initWithAppKey:self.appKey adUnits:@[IS_REWARDED_VIDEO]];
//    }
    
    self.viewController = viewController;
    if (self.appKey.exceptNull == nil) {
        NSAssert(self.appKey.exceptNull != nil, @"appKey id cannot be empty");
    }

    //[IronSource setRewardedVideoDelegate:self];
    [IronSource setLevelPlayRewardedVideoDelegate:self];

    [IronSource initWithAppKey:self.appKey adUnits:@[IS_REWARDED_VIDEO]];
        if (self.rewardADidOpenCallBack) {
            self.isReady = YES;
            self.rewardADidOpenCallBack();
        }

}
/// 展示激励视频广告
- (void)showIronSourceRewardVideoAd{
    if ([IronSource hasRewardedVideo]) {

        if (self.rewardedVideo_id.exceptNull == nil) {
            self.rewardedVideo_id = nil;
        }
        
     [IronSource showRewardedVideoWithViewController:self.viewController placement:self.rewardedVideo_id];
    }else{
        LKLogInfo(@"广告不可用...");
        if (self.rewardADidShowFailCallBack) {
           self.rewardADidShowFailCallBack([self responserErrorMsg:@"当前广告不可用" code:-1]);
       }
    }
}

- (BOOL)getRewardVideoAdIsValid {
    return [IronSource hasRewardedVideo];
}
#pragma mark - ISRewardedVideoDelegate
//Called after a rewarded video has changed its availability. 在奖励视频更改其可用性后调用。
//@param available The new rewarded video availability. YES if available //and ready to be shown, NO otherwise. 新的奖励视频可用性。 是，如果可用//并准备显示，否则，否。 加载成功
- (void)rewardedVideoHasChangedAvailability:(BOOL)available {

    if ([IronSource hasRewardedVideo]) {
        if (self.rewardAdHasChangedCallBack && self.isReady == NO) {
            self.isReady = YES;
            self.rewardAdHasChangedCallBack();
        }
    }else{
        LKLogInfo(@"广告不可用");
//        if (self.rewardADidShowFailCallBack) {
//            self.rewardADidShowFailCallBack([self responserErrorMsg:@"当前广告不可用" code:-1]);
//        }
    }


     //Change the in-app 'Traffic Driver' state according to availability.
}
// Invoked when the user completed the video and should be rewarded.
// If using server-to-server callbacks you may ignore this events and wait *for the callback from the ironSource server.
//
// @param placementInfo An object that contains the placement's reward name and amount.
/*
 //当用户观看完视频时调用，应予以奖励。
 //如果使用服务器到服务器的回调，则可以忽略此事件，并等待*来自ironSource服务器的回调。
 //
 // @param placementInfo一个对象，其中包含展示位置的奖励名称和金额。
 */
- (void)didReceiveRewardForPlacement:(ISPlacementInfo *)placementInfo {

    // 可以奖励用户了
//    NSNumber *rewardAmount = [placementInfo rewardAmount];
//    NSString *rewardName = [placementInfo rewardName];
    
    if (self.rewardADidReceiveCallBack) {
        self.rewardADidReceiveCallBack();
    }

    
}
//Called after a rewarded video has attempted to show but failed.
//@param error The reason for the error
/*
 //在奖励视频尝试播放但失败后调用。
 // @ param error错误原因
 **/
- (void)rewardedVideoDidFailToShowWithError:(NSError *)error {

    if (self.rewardADidShowFailCallBack) {
        self.rewardADidShowFailCallBack(error);
    }
    
}
//Called after a rewarded video has been opened. 在打开奖励视频后调用。
- (void)rewardedVideoDidOpen {

    LKLogInfo(@"=====111111111111=====");
//    if (self.rewardADidOpenCallBack) {
//        self.rewardADidOpenCallBack();
//    }
}
//Called after a rewarded video has been dismissed.
- (void)rewardedVideoDidClose {

    if (self.rewardADidCloseCallBack) {
        self.rewardADidCloseCallBack();
    }
}
//Invoked when the end user clicked on the RewardedVideo ad 当最终用户点击RewardedVideo广告时调用
- (void)didClickRewardedVideo:(ISPlacementInfo *)placementInfo{

    if (self.rewardADidClickCallBack) {
        self.rewardADidClickCallBack();
    }
}

/*
 ///注意：以下事件DidStart和DidEnd事件不适用于所有受支持的奖励视频广告网络。 检查您选择//包含在构建中的每个广告网络可用的事件。
 ///我们建议仅使用注册到您构建中所有广告网络的事件。
   //在奖励视频开始播放后调用。
 **/
- (void)rewardedVideoDidStart {

    if (self.rewardADidStartCallBack) {
        self.rewardADidStartCallBack();
    }
}
//Called after a rewarded video has finished playing. 在奖励视频播放完毕后调用。
- (void)rewardedVideoDidEnd {

    if (self.rewardADidEndCallBack) {
        self.rewardADidEndCallBack();
    }
}
#pragma mark - ISInterstitialDelegate
//Invoked when Interstitial Ad is ready to be shown after load function was //called.
-(void)interstitialDidLoad {


    if (self.interstitialAdDidLoadCallBack) {
        self.interstitialAdDidLoadCallBack();
    }

}
//Called each time the Interstitial window has opened successfully.
-(void)interstitialDidShow {

    if (self.interstitialAdDidShowCallBack) {
        self.interstitialAdDidShowCallBack();
    }
}
// Called if showing the Interstitial for the user has failed.
//You can learn about the reason by examining the ‘error’ value
-(void)interstitialDidFailToShowWithError:(NSError *)error {

    if (self.interstitialAdDidShowFailCallBack) {
        self.interstitialAdDidShowFailCallBack(error);
    }
}
//Called each time the end user has clicked on the Interstitial ad.
-(void)didClickInterstitial {

    if (self.interstitialAdDidClickCallBack) {
        self.interstitialAdDidClickCallBack();
    }
}
//Called each time the Interstitial window is about to close
-(void)interstitialDidClose {

    if (self.interstitialAdDidCloseCallBack) {
        self.interstitialAdDidCloseCallBack();
    }
}
//Called each time the Interstitial window is about to open
-(void)interstitialDidOpen {

    if (self.interstitialAdDidOpenCallBack) {
        self.interstitialAdDidOpenCallBack();
    }
}
//Invoked when there is no Interstitial Ad available after calling load //function. @param error - will contain the failure code and description.
-(void)interstitialDidFailToLoadWithError:(NSError *)error {
 
    if (self.interstitialAdDidShowFailCallBack) {
        self.interstitialAdDidShowFailCallBack(error);
    }
}

#pragma mark - Banner ISBannerDelegate
/** Called after a banner ad has been successfully loaded
 */
- (void)bannerDidLoad:(ISBannerView *)bannerView {
     dispatch_async(dispatch_get_main_queue(), ^{
        self.bannerView = bannerView;
         if (self.bannerAdDidLoadCallBack) {
             self.bannerAdDidLoadCallBack();
         }
    });

    
}
/**
 Called after a banner has attempted to load an ad but failed.
 
 @param error The reason for the error
 */
- (void)bannerDidFailToLoadWithError:(NSError *)error {
    

    LKLogInfo(@"error = %@",error);
    if (self.bannerAdDidLoadFailCallBack) {
        self.bannerAdDidLoadFailCallBack(error);
    }
    
}
/**
 Called after a banner has been clicked.
 */
- (void)didClickBanner {

    if (self.bannerAdDidClickCallBack) {
        self.bannerAdDidClickCallBack();
    }
    
}
/**
 Called when a banner is about to present a full screen content.
 */
- (void)bannerWillPresentScreen {

    if (self.bannerAdWillPresentCallBack) {
        self.bannerAdWillPresentCallBack();
    }
    
}
/**
 Called after a full screen content has been dismissed.
 */
- (void)bannerDidDismissScreen {

    if (self.bannerAdDidDismissCallBack) {
        self.bannerAdDidDismissCallBack();
    }
}
/**
 Called when a user would be taken out of the application context.
 */
- (void)bannerWillLeaveApplication {
    
    if (self.bannerAdWillLeaveCallBack) {
        self.bannerAdWillLeaveCallBack();
    }
}

- (void)bannerDidShow{
    
}


@end
