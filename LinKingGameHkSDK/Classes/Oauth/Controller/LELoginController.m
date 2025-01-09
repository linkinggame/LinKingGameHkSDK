//
//  LELoginController.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/10.
//  Copyright © 2020 "". All rights reserved.
//

#import "LELoginController.h"
#import "LELoginView.h"
#import "LELoginApi.h"
#import "LEUser.h"
#import <Toast/Toast.h>
#import "LESignInApple.h"
#import "LESignInFacebook.h"
#import "LESignInGoogle.h"
#import "NSObject+LEAdditions.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "UIImage+LEAdditions.h"
#import "NSBundle+LEAdditions.h"
#import "LKLog.h"
@interface LELoginController ()
@property (nonatomic,weak) UIView *contentView;
@end

@implementation LELoginController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self showLoginView];
}

- (void)showLoginView{
   LELoginView *oauthView = [LELoginView instanceOauthView];

   [self.view insertSubview:oauthView atIndex:self.view.subviews.count];
   [oauthView setLESuperView:self.view];
   CGFloat width = 320;
    CGFloat screen_width = [UIScreen mainScreen].bounds.size.width;
    if (width > screen_width) {
        width = screen_width - 40;
    }
   oauthView.translatesAutoresizingMaskIntoConstraints = NO;
    
    oauthView.button_close.hidden = self.isHiddenCloseView;
    oauthView.imageView_close.hidden = self.isHiddenCloseView;
    
   [self setAlterContentView:oauthView];
   [self setAlterHeight:330];
   [self setAlterWidth:width];
   [self layoutConstraint];


    
    oauthView.imageView_close.hidden = self.isHiddenCloseView;
    oauthView.button_close.hidden = self.isHiddenCloseView;
    
    
    if (self.agreement == YES) {
         [oauthView.button_box setBackgroundImage:[UIImage le_ImageNamed:@"checkmark"] forState:UIControlStateNormal];
    }else{
         [oauthView.button_box setBackgroundImage:[UIImage le_ImageNamed:@"nocheckmark"] forState:UIControlStateNormal];
        
    }
     oauthView.button_box.selected = self.agreement;
    
    oauthView.startLoginCallBack = ^{
        [self startLogin];
    };
    
    oauthView.changeBoxCallBack = ^(UIButton * _Nonnull sender) {
        
    };
    
    oauthView.closeAlterViewCallBack = ^{
        
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
        
    };
    
    oauthView.thirdLoginCallBack = ^(UIButton * _Nonnull sender) {
        
        [self thirdLogin:sender.tag];
    };
    
    oauthView.useAgreemmentCallBack = ^(BOOL isAgreement, UIButton * _Nonnull sender) {
        [self useAgreementAction:isAgreement type:sender.tag];
    };

}


- (void)useAgreementAction:(BOOL)isAgreement type:(NSInteger)type {
    [self dismissViewControllerAnimated:NO completion:^{
        NSNumber *agreement = [NSNumber numberWithBool:isAgreement];
        NSNumber *typeNumber = [NSNumber numberWithInteger:type];
        
        NSDictionary *result = @{@"isAgreement":agreement,@"type":typeNumber};
        
       [[NSNotificationCenter defaultCenter] postNotificationName:@"USEAGREEMENT" object:result];
    }];
}


- (void)thirdLogin:(NSInteger)index{
    if (index == 10) {
        [self facebookLogin];
    }else if (index == 20){
        [self appleLogin];
    }else if (index == 30){
        [self googleLogin];
    }
    
}


- (void)googleLogin{
    
    
//    [[LESignInGoogle shared] loginGoogleRootViewController:self complete:^(GIDGoogleUser * _Nullable user, NSError * _Nullable error) {
//       
//        if (error.code == -5) {
//            NSError *errorRes =nil;
//           [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginCancel" object:@"apple"];
//            errorRes = [self responserErrorMsg:[NSBundle le_localizedStringForKey:@"Cancel login"] code:1001];
////           [self.view makeToast:@"取消登录"];
//            [self.view makeToast:[NSBundle le_localizedStringForKey:@"Cancel login"] duration:2 position:CSToastPositionBottom];
//        }
//        if (error == nil) {
//                 
//                NSString *token = user.authentication.idToken;
//            [LELoginApi googleLoginWithToken:token complete:^(NSError * _Nonnull inError,LEUser *user) {
//                
//                if (self.isHiddenCloseView == NO) { // 切换账号
//                    if (self.changeAccountSuccessCallBack) {
//                        self.changeAccountSuccessCallBack();
//                    }
//                }
//                
//                if (user != nil && error == nil) {
//                    
////                    LKLogInfo(@"-->%@",self.presentedViewController);
////                    LKLogInfo(@"-->%@",self.presentingViewController);
////                    LKLogInfo(@"-->%@",self.presentationController);
//            
//                    
//                    [self.presentingViewController dismissViewControllerAnimated:NO completion:^{
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccess" object:user];
//                        if (self.loginCompleteCallBack) {
//                         
//                            self.loginCompleteCallBack(user, inError);
//                        }
//                    }];
//                }else{
//                    NSError *errorRes = [self responserErrorMsg:error.localizedDescription code:1004];
//                                   
//                      [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFail" object:errorRes];
//                     if (self.loginCompleteCallBack) {
//                         self.loginCompleteCallBack(nil, errorRes);
//                     }
//                     [self.view makeToast:error.localizedDescription duration:2 position:CSToastPositionBottom];
//                }
//                
//         
//                
//            }];
//                 
//             }else{
//                 if (self.loginCompleteCallBack) {
//                     self.loginCompleteCallBack(nil, error);
//                 }
//             }
//        
//        
//    }];
//    
}

- (void)facebookLogin{
    [[LESignInFacebook shared] loginRootViewController:self complete:^(FBSDKLoginManagerLoginResult * _Nullable result, NSError * _Nonnull error) {
       
        
        if (result.isCancelled) {
            NSError *errorRes =nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginCancel" object:@"apple"];
            errorRes = [self responserErrorMsg:[NSBundle le_localizedStringForKey:@"Cancel login"] code:1001];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:[NSBundle le_localizedStringForKey:@"Cancel login"] duration:2 position:CSToastPositionCenter];
            });
//            [self.view makeToast:@"取消登录"];
           
            self.loginCompleteCallBack(nil, errorRes);
            
            
            
        }else if (result.token.exceptNull != nil && error == nil) {
            
            NSString *token = result.token.tokenString;
            //NSString *token = [[FBSDKAccessToken currentAccessToken] tokenString];
            LKLogInfo(@"====facebookLoginWithToken===token== %@", token);
            //LKLogInfo(@"====facebookLoginWithToken===expired1== %@", [FBSDKAccessToken currentAccessToken].expirationDate );
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showMaskView];
            });
            [LELoginApi facebookLoginWithToken:token complete:^(NSError * _Nonnull inError,LEUser *user) {
            
                if (self.isHiddenCloseView == NO) { // 切换账号
                    if (self.changeAccountSuccessCallBack) {
                        self.changeAccountSuccessCallBack();
                    }
                }
                
                if (user != nil && inError == nil) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSString *str = [NSBundle le_localizedStringForKey:@"Login Successful"];
                        [self.view makeToast:str duration:2 position:CSToastPositionCenter];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self.presentingViewController dismissViewControllerAnimated:NO completion:^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccess" object:user];
                                if (self.loginCompleteCallBack) {
                                   
                                     self.loginCompleteCallBack(user, inError);
                                 }
                                [self hiddenMaskView];
                            }];
                        });
                        
                    });
                    
          
                }else{
                    
                    [self hiddenMaskView];
                    
                    NSError *errorRes = [self responserErrorMsg:error.localizedDescription code:1004];
                                   
                      [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFail" object:errorRes];
                     if (self.loginCompleteCallBack) {
                         self.loginCompleteCallBack(nil, errorRes);
                     }
                     [self.view makeToast:error.localizedDescription duration:2 position:CSToastPositionCenter];
                }

    
            }];
            
        }else{
            if (self.loginCompleteCallBack) {
                self.loginCompleteCallBack(nil, error);
            }
        }
        
        
    }];
}

- (void)appleLogin{
     /**
     ASAuthorizationErrorUnknown = 1000,
     ASAuthorizationErrorCanceled = 1001,
     ASAuthorizationErrorInvalidResponse = 1002,
     ASAuthorizationErrorNotHandled = 1003,
     ASAuthorizationErrorFailed = 1004,
     */
      // 登录失败
      [LESignInApple shared].didCompleteWithError = ^(NSError * _Nonnull error) {
          NSError *errorRes =nil;
          if (@available(iOS 13.0, *)) {
              if (error.code == 1001) { // 用户取消了登录
                  [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginCancel" object:@"apple"];
                  errorRes = [self responserErrorMsg:[NSBundle le_localizedStringForKey:@"Cancel login"] code:1001];
//                  [self.view makeToast:@"取消登录"];
                  [self.view makeToast:[NSBundle le_localizedStringForKey:@"Cancel login"] duration:2 position:CSToastPositionCenter];
                  
              }else{
                   errorRes = [self responserErrorMsg:error.localizedDescription code:1004];
            
                   [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFail" object:error];
              }

              if (self.loginCompleteCallBack) {
                  self.loginCompleteCallBack(nil, errorRes);
              }
          } else {
              // Fallback on earlier versions
             
          }
      };
      
      // 登录成功
      [LESignInApple shared].didCompleteWithAuthorization = ^(NSInteger type, NSString * _Nullable user, NSString * _Nullable token, NSString * _Nullable code, NSString * _Nullable password) {
          if (type == 1) { //appID 登录
              dispatch_async(dispatch_get_main_queue(), ^{
                  [self showMaskView];
              });
            
              // 发起请求
              [LELoginApi appleLoginWithToken:token complete:^(NSError * _Nonnull error,LEUser *user) {
                
                 if (error ==nil) {
                         if (self.isHiddenCloseView == NO) { // 切换账号
                             if (self.changeAccountSuccessCallBack) {
                                 self.changeAccountSuccessCallBack();
                             }
                         }
                     
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         NSString *str = [NSBundle le_localizedStringForKey:@"Login Successful"];
                         [self.view makeToast:str duration:2 position:CSToastPositionCenter];
                         
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccess" object:user];
                              [self.presentingViewController dismissViewControllerAnimated:NO completion:^{
                              
                              if (user != nil ) {
                                  if (self.loginCompleteCallBack) {
                                       self.loginCompleteCallBack(user, error);
                                   }
                                  [self hiddenMaskView];
                              }else{
                                  [self hiddenMaskView];
                                  [self.view makeToast:error.localizedDescription duration:2 position:CSToastPositionCenter];
                                  if (self.loginCompleteCallBack) {
                                       self.loginCompleteCallBack(user, error);
                                  }
                                
                              }
                          }];
                         });
                     });
                     

                  }else{
                      [self hiddenMaskView];
                      
                       NSError *errorRes = [self responserErrorMsg:error.localizedDescription code:1004];
                                      
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFail" object:errorRes];
                        if (self.loginCompleteCallBack) {
                            self.loginCompleteCallBack(nil, errorRes);
                        }
                        [self.view makeToast:error.localizedDescription duration:2 position:CSToastPositionCenter];
                      

                  }
                  
                 
                  
              }];
          
          }else{// 账号密码登录
          }
          
          
      };

     
      [[LESignInApple shared] loginAppleWithComplete:^(BOOL success) {
          if (success == NO) {
//              [self.view makeToast:@"系统版本过低，请先升级，继续使用Sign In With Apple"];
              NSString *str = [NSBundle le_localizedStringForKey:@"The system version is too low, please upgrade first, continue to use Sign In With Apple"];
              [self.view makeToast:str duration:2 position:CSToastPositionCenter];
          }
      }];
}

- (void)startLogin{
    
    [self showMaskView];
    [LELoginApi quickLoginComplete:^(NSError * _Nonnull error,LEUser *user) {
     
              if (error ==nil) {
                    
                  if (self.isHiddenCloseView == NO) { // 切换账号
                      if (self.changeAccountSuccessCallBack) {
                          self.changeAccountSuccessCallBack();
                      }
                  }
                  NSString *str = [NSBundle le_localizedStringForKey:@"Login Successful"];
                  [self.view makeToast:str duration:2 position:CSToastPositionCenter];
                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                      [self hiddenMaskView];
                      [self dismissViewControllerAnimated:NO completion:^{
                          [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccess" object:user];
                      }];
                  });

              }else{
                  [self hiddenMaskView];
                  [self.view makeToast:error.localizedDescription duration:2 position:CSToastPositionCenter];
                  [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFail" object:error];
                  
              }
              if (self.loginCompleteCallBack) {
                  self.loginCompleteCallBack(user, error);
              }
    }];
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
