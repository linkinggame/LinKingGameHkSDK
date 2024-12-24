//
//  LESDKManager.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/7.
//  Copyright © 2020 "". All rights reserved.
//

#import "LESDKManager.h"
#import "LEOauthManager.h"
#import "LESystem.h"
#import "LESDKConfigApi.h"
#import "LESDKConfig.h"
#import "NSObject+LEAdditions.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <AppsFlyerLib/AppsFlyerLib.h>
#import "LELanguage.h"
#import "LESignInGoogle.h"
#import "LEPointManager.h"
#import "LEAFManager.h"
#import "LEAdManager.h"
#import "LEIronSourceAdManager.h"
#import "LEFacebookAdManager.h"
#import "LEPointManager.h"
#import "LEApplePayManager.h"
#import "LESFPointManager.h"
#import "LEVersion.h"
#import "LEFBShareManager.h"
#import "LEUser.h"
#import "LEGlobalConf.h"
#import "LKLog.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import "LEBundleUtil.h"
@interface LESDKManager ()<UIApplicationDelegate>
@property (nonatomic, strong) LEOauthManager *oauthManager;
@property (nonatomic, strong) LEAdManager *adManager;
@property (nonatomic, strong) LEIronSourceAdManager *ironsAdManager;
@property (nonatomic, strong) LEFacebookAdManager *facebookAdManager;
@property (nonatomic, strong) LEPointManager *pointManager;
@property (nonatomic, strong) LEApplePayManager *payManager;
@property (nonatomic, strong) LEFBShareManager *shareManager;

@property (nonatomic, copy) void(^registerSDKComplete)(LESDKManager *manager,NSError *error);
@end

static LESDKManager * _instance = nil;
@implementation LESDKManager
+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LESDKManager alloc] init];
    });
    return _instance;
}



- (NSBundle *)languageBundle{
    // 如果没有设置值返回默认的
    return [LELanguage shared].languageBundle;
}
#pragma mark -- 初始化SDK
- (void)loadSDKConfigJsonWithURL:(NSString *)url{
    
    [LESDKConfigApi fetchSDKConfigWithURL:url complete:^(NSError * _Nullable error) {
        if (error == nil) {
            
            // 初始化其他sdk
            [self initializeOtherManager];
            
            // 注册广告
            [self.adManager registerAd];
            
            
        }else{
            LKLogInfo(@"==SDK初始化失败==");
        }
        if (self.initializeSDKCallBack) {
            self.initializeSDKCallBack(self, error);
        }
        if (self.registerSDKComplete) {
            self.registerSDKComplete(self, error);
        }
    }];
    
}


- (void)loadSDKConfig:(NSString *)appId{

    NSLog(@"~~~~~~======");
    [LESDKConfigApi fetchSDKConfigURLWithAppId:appId complete:^(NSString * _Nullable url, NSError * _Nullable error) {

        if (url.exceptNull != nil && error == nil) {
            [self loadSDKConfigJsonWithURL:url];
        }else{
            LKLogError(@"error:%@",error);
        }
    }];
    

}


- (void)versionSDKUpdate{
    LEUser *user = [LEUser getUser];
    if (user != nil) {
        LESDKConfig *sdkConfig = [LESDKConfig getSDKConfig];
        BOOL flag =  [sdkConfig.updateGame[@"cancelFlag"] boolValue];
        if (flag == true) {
            [[LEVersion shared] checkVersion];
        }
    }
}

- (void)initializeOtherManager{
    self.oauthManager = [LEOauthManager shared];
    self.adManager = [LEAdManager shared];
    self.ironsAdManager = [LEIronSourceAdManager shared];
    self.facebookAdManager = [LEFacebookAdManager shared];
    self.pointManager = [LEPointManager shared];
    self.payManager = [LEApplePayManager shared];
    self.shareManager = [LEFBShareManager shared];
    [[LESFPointManager shared] activatePointWithComplete:^(NSError * _Nullable error) {
        LKLogInfo(@"==激活打点==");
    }];
    
}
- (void)verifyAppIdAndsecretKey{
    
    LESDKConfig *sdkConfig =[LESDKConfig getSDKConfig];
    NSDictionary *sdk_config = sdkConfig.sdk_config;
    
    NSString *key_ios = sdk_config[@"key_ios"];
    NSString *app_id_ios = sdk_config[@"app_id_ios"];
    
    LESystem *system = [LESystem getSystem];
    
    if (system.appId.exceptNull == nil) {
         NSAssert(system.appId.exceptNull != nil, @"appid Can not be empty");
    }
    if (system.secretkey.exceptNull == nil) {
         NSAssert(system.secretkey.exceptNull != nil, @"secretkey Can not be empty");
    }
    
     NSAssert([system.appId isEqualToString:app_id_ios], @"appId is incorrect");
     NSAssert([system.secretkey isEqualToString:key_ios], @"secretkey is incorrect");

}

/// 注册SDK
/// @param appId  平台分发的appId
/// @param secretkey 平台分发的key
/// @param complete 完成注册的回调
- (void)registLinKingSDKAppID:(NSString * _Nonnull)appId withSecretkey:(NSString * _Nonnull)secretkey cmoplete:(void(^_Nonnull)(LESDKManager *manager,NSError *error))complete{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SYSTEMSDKKEY];
    LESystem *system = [LESystem getSystem];
    system.appId = appId;
    system.secretkey = secretkey;
    
    [[NSUserDefaults standardUserDefaults] setObject:appId forKey:@"SDK_APPID"];
    [[NSUserDefaults standardUserDefaults] setObject:secretkey forKey:@"SDK_SECRETKEY"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [LESystem setSystem:system];
    
  
    
    [_instance loadSDKConfig:appId];
    self.registerSDKComplete = complete;
}



- (void)requestIDFA {
    if (@available(iOS 14.0, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            
        }];
    }
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    // 初始化facebook 登录
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    //  Override point for customization after application launch.
    // FB 广告初始化
    [FBAudienceNetworkAds initializeWithSettings:nil completionHandler:nil];

    // Pass user's consent after acquiring it. For sample app purposes, this is set to YES.
    [FBAdSettings setAdvertiserTrackingEnabled:YES];
    // 开启支付监听
    [[LEApplePayManager shared] startManager];
    
    return YES;
}
- (void)applicationWillTerminate:(UIApplication *)application{
      [[LEApplePayManager shared] stopManager];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {

    return  YES;
}

- (BOOL)application:(nonnull UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *, id> *)options{
    
     [[AppsFlyerLib shared] handleOpenUrl:url options:options];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@",url];
       if ([urlStr rangeOfString:@"fb"].length > 0) {
        BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                                 openURL:url options:options]; // Add any custom logic here. return handled;
        return handled;
       }else{
//           return [[GIDSignIn sharedInstance] handleURL:url];
           return YES;
       }
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
     [[AppsFlyerLib shared] handleOpenURL:url sourceApplication:sourceApplication withAnnotation:annotation];
    
       NSString *urlStr = [NSString stringWithFormat:@"%@",url];
       if ([urlStr rangeOfString:@"fb"].length > 0) {
        BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation ];
        return handled;
       }else{
//           return [[GIDSignIn sharedInstance] handleURL:url];
           return YES;
       }
    
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    [[AppsFlyerLib shared] handlePushNotification:userInfo];
}


//========适配了SceneDelegate的App
- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts API_AVAILABLE(ios(13.0)){
    NSURL* url = [[URLContexts allObjects] objectAtIndex:0].URL;
   if(url){
       [[AppsFlyerLib shared] handleOpenUrl:url options:nil];
   }
}
// AppDelegate:
//  注意：适配了SceneDelegate的App，系统将会回调SceneDelegate的continueUserActivity方法，所以需要重写SceneDelegate的该方法。
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler {
    
    [[AppsFlyerLib shared] continueUserActivity:userActivity restorationHandler:restorationHandler];
   
    return YES;
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
     // 在iOS15的时候就需要在BecomeActive之后获取，在这之前就会有问题(不会显示出来)
    // 设置是否允许广告监听
    if ([LEBundleUtil getTracKing]) {
        [self requestIDFA];
    }
    // FB 激活
    [FBSDKAppEvents.shared activateApp];
    
    // AF 激活
    [[AppsFlyerLib shared] start];
}


// SceneDelegate:
- (void)scene:(UIScene *)scene continueUserActivity:(NSUserActivity *)userActivity  API_AVAILABLE(ios(13.0)) API_AVAILABLE(ios(13.0)){
    
}
@end
