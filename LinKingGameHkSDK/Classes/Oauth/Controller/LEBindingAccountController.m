//
//  LEBindingAccountController.m
//  LinKingEnSDK
//
//  Created by MrDML on 2020/8/15.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEBindingAccountController.h"
#import "LEBindingView.h"
#import <Toast/Toast.h>
#import "LESignInApple.h"
#import "LESignInFacebook.h"
#import "LESignInGoogle.h"
#import "NSObject+LEAdditions.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "UIImage+LEAdditions.h"
#import "LEBindingApi.h"
#import "NSBundle+LEAdditions.h"
#import "LKLog.h"
@interface LEBindingAccountController ()

@end

@implementation LEBindingAccountController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    
    [self showBindingAccountView];
}


- (void)showBindingAccountView{
    LEBindingView *bindingView = [LEBindingView instanceBindingView];

       [self.view insertSubview:bindingView atIndex:self.view.subviews.count];
       CGFloat width = 320;
        CGFloat screen_width = [UIScreen mainScreen].bounds.size.width;
        if (width > screen_width) {
            width = screen_width - 40;
        }
       bindingView.translatesAutoresizingMaskIntoConstraints = NO;

       [self setAlterContentView:bindingView];
       [self setAlterHeight:280];
       [self setAlterWidth:width];
       [self layoutConstraint];
    
    
    bindingView.thirdBindingCallBack = ^(UIButton * _Nonnull sender) {
        
        [self thirdBindingAccount:sender.tag];
    };
    
    bindingView.closeAlterViewCallBack = ^{
        [self dismissViewControllerAnimated:NO completion:nil];
    };
}


- (void)thirdBindingAccount:(NSInteger)index{

    switch (index) {
        case 10:
            [self facebookSignIn];
            break;
        case 20:
            [self appleSignIn];
            break;
        case 30:
             [self appleSignIn];
            break;
            
        default:
            break;
    }
    
    
}

- (void)appleSignIn{
    
    // 登录失败
    [LESignInApple shared].didCompleteWithError = ^(NSError * _Nonnull error) {
        NSError *errorRes =nil;
        if (@available(iOS 13.0, *)) {
            if (error.code == 1001) { // 用户取消了登录
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginCancel" object:@"apple"];
                errorRes = [self responserErrorMsg:[NSBundle le_localizedStringForKey:@"Cancel login"] code:1001];
         
                
            }else{
                 errorRes = [self responserErrorMsg:error.localizedDescription code:1004];
          
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFail" object:error];
            }

            if (self.bindingCompleteCallBack) {
                self.bindingCompleteCallBack(nil, errorRes);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:errorRes.localizedDescription duration:2 position:CSToastPositionCenter];
            });
           
        } else {
            // Fallback on earlier versions
           
        }
    };
    
    // 登录成功
    [LESignInApple shared].didCompleteWithAuthorization = ^(NSInteger type, NSString * _Nullable user, NSString * _Nullable token, NSString * _Nullable code, NSString * _Nullable password) {
        if (type == 1) { //appID 登录
            
            [LEBindingApi appleBindingAccountWithToken:token complete:^(NSError * _Nonnull inError, LEUser * _Nonnull user) {
                if (inError ==nil) {
                         [self.presentingViewController dismissViewControllerAnimated:NO completion:^{
                         
                         if (user != nil ) {
                              if (self.bindingCompleteCallBack) {
                                  self.bindingCompleteCallBack(user, inError);
                              }
                         }else{
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [self.view makeToast:inError.localizedDescription duration:2 position:CSToastPositionCenter];
                             });
                             if (self.bindingCompleteCallBack) {
                                  self.bindingCompleteCallBack(user, inError);
                             }
                         }
                     }];
              }else{
                  
                   NSError *errorRes = [self responserErrorMsg:inError.localizedDescription code:1004];
                    if (self.bindingCompleteCallBack) {
                        self.bindingCompleteCallBack(nil, errorRes);
                    }
                  LKLogInfo(@"=====%@",[NSThread currentThread]);
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [self.view makeToast:inError.localizedDescription duration:2 position:CSToastPositionCenter];
                  });

              }
            }];
           
     
        
        }else{// 账号密码登录
        }
        
        
    };

    [[LESignInApple shared] loginAppleWithComplete:^(BOOL success) {
        if (success == NO) {
            NSString *str = [NSBundle le_localizedStringForKey:@"The system version is too low, please upgrade first, continue to use Sign In With Apple"];
            [self.view makeToast:str duration:2 position:CSToastPositionCenter];
        }
    }];
    
}

- (void)googleSignIn{
//    [[LESignInGoogle shared] loginGoogleRootViewController:self complete:^(GIDGoogleUser * _Nullable user, NSError * _Nullable error) {
//       
//        if (error.code == -5) {
//            NSError *errorRes =nil;
//           [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginCancel" object:@"apple"];
//           errorRes = [self responserErrorMsg:[NSBundle le_localizedStringForKey:@"Cancel login"] code:1001];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.view makeToast:[NSBundle le_localizedStringForKey:@"Cancel login"] duration:2 position:CSToastPositionBottom];
//            });
//         
//        }
//        if (error == nil) {
//                 
//                NSString *token = user.authentication.idToken;
//            
//            [LEBindingApi googleBindingAccountWithToken:token complete:^(NSError * _Nonnull inError, LEUser * _Nonnull user) {
//                
//                if (user != nil && inError == nil) {
//                    [self.presentingViewController dismissViewControllerAnimated:NO completion:^{
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [self.view makeToast:[NSBundle le_localizedStringForKey:@"Bind successfully"]];
//                        });
//                        if (self.bindingCompleteCallBack) {
//                                        
//                            self.bindingCompleteCallBack(user, inError);
//                        }
//                    }];
//                }else{
//                    
//                    NSError *errorRes = [self responserErrorMsg:inError.localizedDescription code:1004];
//                    if (self.bindingCompleteCallBack) {
//                        self.bindingCompleteCallBack(nil, errorRes);
//                    }
//                   LKLogInfo(@"=====%@",[NSThread currentThread]);
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self.view makeToast:inError.localizedDescription duration:2 position:CSToastPositionBottom];
//                    });
//
//                }
//
//            }];
//
//             }else{
//                 if (self.bindingCompleteCallBack) {
//                     self.bindingCompleteCallBack(nil, error);
//                 }
//             }
//        
//        
//    }];
}

- (void)facebookSignIn{
    [[LESignInFacebook shared] loginRootViewController:self complete:^(FBSDKLoginManagerLoginResult * _Nullable result, NSError * _Nonnull error) {
       
        
        if (result.isCancelled) {
            NSError *errorRes =nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginCancel" object:@"apple"];
            errorRes = [self responserErrorMsg:[NSBundle le_localizedStringForKey:@"Cancel login"] code:1001];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:[NSBundle le_localizedStringForKey:@"Cancel login"] duration:2 position:CSToastPositionCenter];
            });
          
        }else if (result.token.exceptNull != nil && error == nil) {
            
            NSString *token = result.token.tokenString;
            
            [LEBindingApi facebookBindingAccountWithToken:token complete:^(NSError * _Nonnull inError, LEUser * _Nonnull user) {
                if (user != nil && inError == nil) {
                    [self.presentingViewController dismissViewControllerAnimated:NO completion:^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccess" object:user];
                        if (self.bindingCompleteCallBack) {
                            self.bindingCompleteCallBack(user, inError);
                        }
                    }];
                }else{
                    NSError *errorRes = [self responserErrorMsg:inError.localizedDescription code:1004];
                     if (self.bindingCompleteCallBack) {
                         self.bindingCompleteCallBack(nil, errorRes);
                     }
                    LKLogInfo(@"=====%@",[NSThread currentThread]);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.view makeToast:inError.localizedDescription duration:2 position:CSToastPositionCenter];
                    });
                }
    
            }];
 
            
        }else{
            if (self.bindingCompleteCallBack) {
                self.bindingCompleteCallBack(nil, error);
            }
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
