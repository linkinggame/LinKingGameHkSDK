//
//  LEOauthManager.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/7.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEOauthManager.h"
#import "LEBaseViewController.h"
#import "LEFloatView.h"
#import "LEUser.h"
#import "LELoginController.h"
#import "LEUserCenterController.h"
#import "LEUseAgreementController.h"
#import "LEMatrixController.h"
#import "LEAccountCenterController.h"
#import "LEBindingAccountController.h"
#import "LEMatrixController.h"
#import "NSObject+LEAdditions.h"
#import "LESystem.h"
#import "LELoginApi.h"
#import "LESDKConfigApi.h"
#import <Toast/Toast.h>
#import "LEMatrixApi.h"
#import "LEMatrixView.h"
#import "LESDKConfig.h"
#import "NSObject+LEAdditions.h"
#import <AppsFlyerLib/AppsFlyerLib.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "LEGlobalConf.h"
#import "NSBundle+LEAdditions.h"
#import "LEPointApi.h"
#import "LKLog.h"
@interface LEOauthManager ()
{
    dispatch_source_t _dispatchTimer;
    dispatch_source_t _dispatchRequestTimer;
}
@property (nonatomic, assign) int second;
@property (nonatomic, assign) int lastSecond;
@property (nonatomic, strong) LEBaseViewController *alterBaseViewController;
@property (nonatomic, assign) BOOL isEnterBackground;
@property (nonatomic, assign) BOOL isAuto;
@property (nonatomic,strong) LEFloatView *floatView;
@property (nonatomic, copy) void(^loginCompleteCallBack)(LEUser *user,NSError *error);
@property (nonatomic, assign) BOOL isChangeAccount;
@property (nonatomic, strong) LEMatrixView * matrixView;
@property (nonatomic, assign) BOOL isStopRequest;
@end


static LEOauthManager *_instance = nil;


@implementation LEOauthManager


+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LEOauthManager alloc] init];
        _instance.lastSecond = 0;
    });
    return _instance;
}

- (void)initializationAuthorizationRootViewController:(UIViewController *)viewController autoLogin:(BOOL)isAuto{
    self.viewController = viewController;
    self.isAuto = isAuto;

    [self addObserverNotification];
    
    // 启动打点
    [LEPointApi pointEventName:@"StartUp" withTp:@"StartUp" withValues:nil complete:^(NSError * _Nonnull error) {
        
        LKLogInfo(@"启动打点");
    }];

    
    if (self.isAuto == YES) {
         [self autoLogin];
    }else{
        [self showLoginAlterViewRootViewController:self.viewController withAgreement:YES withIshiddenCloseView:YES];
    }
}

#pragma mark -- 展示矩阵
-(void)showMatrixVieWithFrame:(CGRect)frame{
    //CGRect rect = CGRectMake(80, [UIScreen mainScreen].bounds.size.height - 200, 200, 160);
    [self showMatrixController:self.viewController withFrame:frame];
}

#pragma mark -- 添加监听
- (void)addObserverNotification{

    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LougOut" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logOutAction) name:@"LougOut" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BinDingAccount" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bindingAccountAction) name:@"BinDingAccount" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ChangeAccount" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAccountAction) name:@"ChangeAccount" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"USEAGREEMENT" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(useAgreementAction:) name:@"USEAGREEMENT" object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BACKUSEAGREEMENT" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backUseAgreementAction:) name:@"BACKUSEAGREEMENT" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoginSuccess" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessAction:) name:@"LoginSuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoginFail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailAction:) name:@"LoginFail" object:nil];
    
    // 监听程序进入前后台
    // app启动或者app从后台进入前台都会调用这个方法
    // app从后台进入前台都会调用这个方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    // 添加检测app进入后台的观察者
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameLaunch)
//    name:UIApplicationDidFinishLaunchingNotification object:nil];

}

/// Dashboard方式登录
/// @param viewController 根控制器
/// @param complete 完成登录回调
- (void)loginWithDashboardRootViewController:(UIViewController *)viewController complete:(void(^)(LEUser *user,NSError *error))complete{
    
    [self loginWithDashboardRootViewController:viewController autoLogin:YES complete:complete];
    
}



/// 登录接口
/// @param rootViewController 根控制器
/// @param complete complete description
- (void)login:(UIViewController*)rootViewController onFinished:(void(^)(LEUser *user,NSError *error))complete{
    [self loginWithDashboardRootViewController:rootViewController autoLogin:YES complete:complete];
}
/// 登出
- (void)logout{
    [self logOutSDKPrivate:YES];
}



/// API方式登录
/// @param viewController 根控制器
/// @param complete 完成登录回调
- (void)loginApiWithRootViewController:(UIViewController *_Nullable)viewController complete:(void(^)(LEUser *user,NSError *error))complete{
    
    self.viewController = viewController;
    [self addObserverNotification];
    LEUser *user = [LEUser getUser];
    if (self.isChangeAccount == NO) {
        if (user != nil && user.userId.exceptNull != nil && user.third_id.exceptNull != nil) { // 用户已经登录展示用户中心
            [self autoLogin];
        }else if (user != nil && user.userId.exceptNull != nil){
             [self autoLogin];
        }else{ // 未登录展示登录界面
             [self showLoginAlterViewRootViewController:viewController withAgreement:YES withIshiddenCloseView:YES];
         }
        self.loginCompleteCallBack = complete;
    }else{
    }
    
}
/// 显示仪表盘
/// @param viewController 根控制器
- (void)showFloatViewDashboard:(UIViewController *)viewController{
       CGRect rect = CGRectZero;
       rect = CGRectMake(-23, [UIScreen mainScreen].bounds.size.height * 0.5, 46, 46);
       [self floatViewDashboard:viewController withFrame:rect];
}
// 隐藏仪表盘
- (void)hiddenFloatViewDashboard{
    self.floatView.hidden = YES;
    [self.floatView removeFromSuperview];
}
/// 退出登录
- (void)logOutSDK{
    
    [self logOutSDKPrivate:YES];
}


- (void)autoLogin{

    LEUser *user = [LEUser getUser];

    
    NSLog(@"1================== %@",user.token);
    if (user != nil) {

        [LELoginApi autoLoginComplete:^(LEUser * _Nonnull user, NSError * _Nonnull error) {
            if (error !=nil) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFail" object:error];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccess" object:user];
            }
              if (self.loginCompleteCallBack) {
                  if (error == nil) {
                      [self showFloatViewDashboard:self.viewController];
                  }
                  LEUser *userNew = [LEUser getUser];
                  NSLog(@"2================== %@",userNew.token);
                  self.loginCompleteCallBack(userNew, error);
                
              }
        }];
        
    }else{
      
        [self showLoginAlterViewRootViewController:self.viewController withAgreement:YES withIshiddenCloseView:YES];
    }
 
}


- (void)applicationBecomeActive{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isEnterBackground = NO;
        self.isStopRequest = NO;
        LEUser *user = [LEUser getUser];
       if (user != nil) {
           // 开始轮询请求接口
           if (self->_dispatchRequestTimer == nil) {
               [self startRequestTime];
           }
       }
    });
}

- (void)applicationEnterBackground{
    self.isEnterBackground = YES;
    [self stopRequestTime];
}

- (void)requestCheckUserInfoTime:(int)time withComplete:(void(^_Nullable)(BOOL success))complete{
    
    if (time < 0) {
        time = 1;
    }
    
    [LESDKConfigApi checkUserInfoWithTime:time complete:^(NSDictionary * _Nonnull result, NSError * _Nonnull error) {

         if (error == nil) {
    
             if (complete) {
                 complete(YES);
             }
         }else{
             self.isStopRequest = YES;

             // 2234 游客模式时间到 提示去实名
             // 2235 未成年模式休息时间  禁止游戏
             // 2236 未成年模式游玩是游戏时间到 禁止游戏
             // 2101 用户不存在
             if (error.code == 2101) {
                 self.isStopRequest = NO;
                 dispatch_async(dispatch_get_main_queue(), ^{

                    NSString *tipStr = [NSBundle le_localizedStringForKey:@"Tips"];

                     NSString *infoStr = [NSBundle le_localizedStringForKey:@"Invalid login or account login on other devices"];

                     NSString *reloginStr = [NSBundle le_localizedStringForKey:@"Again login"];

                     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:tipStr message:infoStr preferredStyle:UIAlertControllerStyleAlert];

                      [alertController addAction:[UIAlertAction actionWithTitle:reloginStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

                          [self showLoginAlterViewRootViewController:self.viewController withAgreement:YES withIshiddenCloseView:YES];
                      }]];
                      [self.viewController presentViewController:alertController animated:YES completion:nil];
                 });
             }

               if (complete) {
                   complete(NO);
               }
         }
    }];
    
    
    

}
#pragma mark -- 通知回调

- (void)loginSuccessAction:(NSNotification *)noti{
    self.isStopRequest = NO;
    LEUser *user = (LEUser  *)noti.object;
    
    [self loginPoint:user];
    
    if (user.exceptNull !=nil) {
        // 开始轮询请求接口
        if (_dispatchRequestTimer == nil) {
            [self startRequestTime];
        }
    }

}


- (void)loginPoint:(LEUser *)user{
    
    if (user.is_new_user.exceptNull != nil) {
        // 判断是否是新用户
        if ([user.is_new_user boolValue]) { // 注册
            // 注册成功后AF打点
            [[AppsFlyerLib shared] logEvent:AFEventCompleteRegistration withValues:@{
                @"af_registration_method":(user.login_type.exceptNull != nil) ?user.login_type:@""
            }];
       
            // 注册成功后FB打点
            [FBSDKAppEvents logEvent:FBSDKAppEventNameCompletedRegistration parameters:@{
                FBSDKAppEventParameterNameRegistrationMethod : (user.login_type.exceptNull != nil) ?user.login_type:@""
            }];
            
        }else{ // 登录
            // 登录成功后AF打点
            [[AppsFlyerLib shared] logEvent:AFEventLogin withValues:@{
              @"af_registration_method":(user.login_type.exceptNull != nil) ?user.login_type:@""
            }];
            // 登录成功后FB打点
            // NO
            
        }
    }else{
        
    }
    
  
}


- (void)startTime{
   // LKLogInfo(@"======开始计时=====");
    if (_dispatchTimer) {
        dispatch_source_cancel(_dispatchTimer);
        _dispatchTimer = nil;
    }
    // 读取存入的时间
    LEUser *user = [LEUser getUser];
    if (user == nil) {
        return;
    }
   
//    NSString *second =  [self readUserPlayTime];
//    if (second != nil) {
//        self.second = [second intValue];
//    }
    
     _dispatchTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0,0));
    dispatch_source_set_timer(_dispatchTimer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_dispatchTimer, ^{
//        self.second += 1;
//        LKLogInfo(@"======================>%d(秒)",self.second);
//        if (self.second % 4 == 0) {
//            LKLogInfo(@"==保存一次== %d",self.second);
//            [self saveUserPlayTime];
//        }
    });
    dispatch_resume(_dispatchTimer);
}
- (NSString *)readUserPlayTime{
    LEUser *user = [LEUser getUser];
    if (user.userId.exceptNull != nil) {
        NSString *key = [NSString stringWithFormat:@"userSecond_%@",user.userId];
        NSString *second =  [[NSUserDefaults standardUserDefaults] objectForKey:key];
        return  second;
    }
    return nil;
   
}

- (void)saveUserPlayTime{
    
    LEUser *user = [LEUser getUser];
    if (user.userId.exceptNull != nil) {
        NSString *key = [NSString stringWithFormat:@"userSecond_%@",user.userId];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",self.second] forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
// 每个20秒请求一次
- (void)startRequestTime{
//     LKLogInfo(@"======开始请求计时=====");
    if (_dispatchRequestTimer) {
        dispatch_source_cancel(_dispatchRequestTimer);
        _dispatchRequestTimer = nil;
    }
    
    int time = 30;
    LESDKConfig *sdkConfig = [LESDKConfig getSDKConfig];
    if (sdkConfig != nil) {
        NSString *timeStr = sdkConfig.auth_config[@"check_time"];
        if (timeStr.exceptNull != nil) {
            int num = [timeStr intValue];
            if (num <= 30) {
                time = 30;
            }else if(num > 30){
                time = num;
            }
        }
    }
    
    // 设置多少秒之后触发
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC);
    
    _dispatchRequestTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0,0));
    dispatch_source_set_timer(_dispatchRequestTimer, startTime, time * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_dispatchRequestTimer, ^{
//        LKLogInfo(@"每隔20s请求一次");
        [self requestCheckUserInfoTime:time withComplete:nil];
    });
    dispatch_resume(_dispatchRequestTimer);
}

- (void)stopRequestTime{
    if (_dispatchRequestTimer) {
        dispatch_source_cancel(_dispatchRequestTimer);
        _dispatchRequestTimer = nil;
    }
}
- (void)stopTime{
    if (_dispatchTimer) {
        dispatch_source_cancel(_dispatchTimer);
        _dispatchTimer = nil;
    }
}

- (void)loginFailAction:(NSNotification *)noti{
    [self showLoginAlterViewRootViewController:self.viewController withAgreement:YES withIshiddenCloseView:YES];
}


- (void)logOutAction{
    [LEUser removeUserInfo];
    [self hiddenFloatViewDashboard];
    
    if ([self.delegate respondsToSelector:@selector(logoutSDKCallBack)]) {
        [self.delegate logoutSDKCallBack];
    }
    
}
- (void)bindingAccountAction{
    [self showBindingAccountCenterController:self.viewController];
}

- (void)changeAccountAction{
    
    [self logOutSDKPrivate:NO];
    if ([self.delegate respondsToSelector:@selector(changeAccountCallBack)]) {
        [self.delegate changeAccountCallBack];
    }
    
}
- (void)logOutSDKPrivate:(BOOL)isDelegate{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopRequestTime];
    self.isStopRequest = YES;
    [self hiddenFloatViewDashboard];

    // 移除用户信息
    [LEUser removeUserInfo];
    
    if (isDelegate) {
        if ([self.delegate respondsToSelector:@selector(logoutSDKCallBack)]) {
            [self.delegate logoutSDKCallBack];
        }
    }

}

// 使用协议
- (void)useAgreementAction:(NSNotification *)noti{
    
    NSDictionary *result = noti.object;
    if ([result isKindOfClass:[NSDictionary class]]) {
        NSNumber *isAgreement = result[@"isAgreement"];
        NSNumber *type = result[@"type"];
         [self showUseAgreementViewRootViewController:self.viewController withAgreement:[isAgreement boolValue] withType:[type intValue]];
    }
}



- (void)backUseAgreementAction:(NSNotification *)noti{
    NSNumber *number = noti.object;
    
   LEUser *user =  [LEUser getUser];
    
    if (user != nil) {
        [self showLoginAlterViewRootViewController:self.viewController withAgreement:[number boolValue] withIshiddenCloseView:NO];
    }else{
        [self showLoginAlterViewRootViewController:self.viewController withAgreement:[number boolValue] withIshiddenCloseView:YES];
    }
    
    
    
}

#pragma mark -- private
- (void)loginWithDashboardRootViewController:(UIViewController *)viewController autoLogin:(BOOL)isAuto complete:(void(^)(LEUser *user,NSError *error))complete{
    [self initializationAuthorizationRootViewController:viewController autoLogin:isAuto];
//    CGRect rect = CGRectZero;
//    rect = CGRectMake(-23, [UIScreen mainScreen].bounds.size.height * 0.5, 46, 46);
//    [self floatViewDashboard:viewController withFrame:rect];
    self.loginCompleteCallBack = complete;
}

- (void)floatViewDashboard:(UIViewController *_Nullable)viewController withFrame:(CGRect)frame{
    if (self.floatView != nil) {
        [self.floatView removeFromSuperview];
    }
      self.viewController = viewController;
      LEFloatView *floatView = [[LEFloatView alloc] initWithFrame:CGRectZero];
      self.floatView  = floatView;
      [floatView setImageWithName:@"float"];
      floatView.stayMode = STAYMODE_LEFTANDRIGHT;
     __weak typeof(self)weakSelf = self;

      [floatView setTapActionWithBlock:^{
           LEUser *user = [LEUser getUser];
          if (user != nil && user.userId.exceptNull != nil && user.third_id.exceptNull != nil) { // 用户已经登录且已绑定展示用户中心
              [weakSelf showAccountCenterController:viewController];
          }else if (user != nil && user.userId.exceptNull != nil){
              [weakSelf showUserCenterViewRootViewController:viewController];
//              [weakSelf showAccountCenterController:viewController];
          }else{ // 未登录展示登录界面
              [weakSelf showLoginAlterViewRootViewController:viewController withAgreement:YES withIshiddenCloseView:YES];
          }

      }];
    UIViewController *rootViewController  = nil;
    if (viewController == nil) {
        rootViewController = [UIApplication sharedApplication].windows.lastObject.rootViewController;
    }else{
        rootViewController = viewController;
    }
      

      [rootViewController.view addSubview:floatView];
//       self.floatView.frame =frame;
    floatView.translatesAutoresizingMaskIntoConstraints = NO;
   
    NSLayoutConstraint *centY = [NSLayoutConstraint constraintWithItem:floatView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:rootViewController.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
   
    // 适配横屏
//    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:floatView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:rootViewController.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant: kStatusBarHeight -20 -23];
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:floatView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:rootViewController.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-23];
      
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:floatView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:46];
    
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:floatView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:46];
    
    [rootViewController.view addConstraints:@[centY,left,width,height]];
}


#pragma mark -- 展现控制器

- (void)showLoginAlterViewRootViewController:(UIViewController *)viewController withAgreement:(BOOL)agreement withIshiddenCloseView:(BOOL)isHiddenClose{
    LELoginController *alterBaseViewController = [[LELoginController alloc] init];
    alterBaseViewController.modalPresentationStyle = UIModalPresentationCustom;
    alterBaseViewController.isHiddenCloseView = isHiddenClose;
    alterBaseViewController.agreement = agreement;
    alterBaseViewController.loginCompleteCallBack = ^(LEUser * _Nonnull user, NSError * _Nonnull error) {
        if (self.loginCompleteCallBack) {
            if (error == nil) {
                [self showFloatViewDashboard:self.viewController];
            }
           
            self.loginCompleteCallBack(user, error);
        }
    };
    [viewController presentViewController:alterBaseViewController animated:NO completion:nil];
}


- (void)showUserCenterViewRootViewController:(UIViewController *)viewController{
    LEUserCenterController *alterBaseViewController = [[LEUserCenterController alloc] init];
    alterBaseViewController.modalPresentationStyle = UIModalPresentationCustom;
    [viewController presentViewController:alterBaseViewController animated:NO completion:nil];
}

- (void)showUseAgreementViewRootViewController:(UIViewController *)viewController withAgreement:(BOOL)agreement withType:(NSInteger)type{
    LEUseAgreementController *alterBaseViewController = [[LEUseAgreementController alloc] init];
    alterBaseViewController.modalPresentationStyle = UIModalPresentationCustom;
    alterBaseViewController.agreement = agreement;
    alterBaseViewController.type = type;
    [viewController presentViewController:alterBaseViewController animated:NO completion:nil];
}


- (void)showMatrixController:(UIViewController *)viewController withFrame:(CGRect)frame{
//    LEMatrixController *alterBaseViewController = [[LEMatrixController alloc] init];
//    alterBaseViewController.modalPresentationStyle = UIModalPresentationCustom;
//    [viewController presentViewController:alterBaseViewController animated:NO completion:nil];
    
          self.matrixView = [LEMatrixView instanceMatrixViewWithViewController:viewController];
    
          [LEMatrixApi fetchMatrixConfigComplete:^(NSError * _Nullable error, id  _Nullable responseObject) {
              if ([responseObject isKindOfClass:[NSDictionary class]]) {
                  NSNumber *total_control_switch = responseObject[@"total_control_switch"];
                  if ([total_control_switch boolValue]) {
                      self.matrixView.frame = frame;
                      [ self.matrixView setMatrixConfig:responseObject withGroup:1];
                      UIView *superView =  viewController.view;
                      [superView insertSubview: self.matrixView atIndex:superView.subviews.count];
                  }

              }
          }];
    
}

- (void)hiddenMatrixView{
    [self.matrixView removeFromSuperview];
}

- (void)showAccountCenterController:(UIViewController *)viewController{
    LEAccountCenterController *alterBaseViewController = [[LEAccountCenterController alloc] init];
    alterBaseViewController.modalPresentationStyle = UIModalPresentationCustom;
    [viewController presentViewController:alterBaseViewController animated:NO completion:nil];
}


- (void)showBindingAccountCenterController:(UIViewController *)viewController{
    LEBindingAccountController *alterBaseViewController = [[LEBindingAccountController alloc] init];
      alterBaseViewController.modalPresentationStyle = UIModalPresentationCustom;
      [viewController presentViewController:alterBaseViewController animated:NO completion:nil];
}



@end
