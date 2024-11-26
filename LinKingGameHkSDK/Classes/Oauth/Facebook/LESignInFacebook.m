//
//  LESignInFacebook.m
//  LinKingEnSDK
//
//  Created by MrDML on 2020/8/15.
//  Copyright © 2020 "". All rights reserved.
//

#import "LESignInFacebook.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
@interface LESignInFacebook ()
@property(nonatomic, strong)FBSDKLoginManager *loginManager;
@end

static LESignInFacebook *_instance = nil;
@implementation LESignInFacebook


+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LESignInFacebook alloc] init];
        _instance.loginManager = [[FBSDKLoginManager alloc] init];
    });
    return _instance;;
}

- (void)loginRootViewController:(UIViewController * _Nonnull)viewController complete:(void(^_Nullable)(FBSDKLoginManagerLoginResult* _Nullable result, NSError * _Nonnull error))complete{
    
     [self.loginManager logInWithPermissions:@[@"public_profile",@"email"] fromViewController:viewController handler:^(FBSDKLoginManagerLoginResult * _Nullable result, NSError * _Nullable error) {
           
         if (complete) {
             complete(result,error);
         }
       }];
    
    
}

- (void)logOut{
    [self.loginManager logOut];
}





@end
