//
//  LESignInGoogle.m
//  LinKingEnSDK
//
//  Created by MrDML on 2020/8/15.
//  Copyright © 2020 "". All rights reserved.
//

#import "LESignInGoogle.h"
#import "LKLog.h"
//#import <FirebaseCore/FirebaseCore.h>
//#import <FirebaseAuth/FirebaseAuth.h>
//#import <GoogleSignIn/GoogleSignIn.h>

@interface LESignInGoogle ()
//<GIDSignInDelegate>
//
//@property (nonatomic, copy) void(^loginComplete)(GIDGoogleUser * _Nullable user, NSError *error);
@end

static LESignInGoogle * _instance = nil;

@implementation LESignInGoogle

+ (instancetype)shared{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LESignInGoogle alloc] init];
        
       
    });
    return _instance;
}



- (void)initializationFireBaseSDK
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [FIRApp configure];
//        [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
//        [GIDSignIn sharedInstance].delegate = self;
//    });
    
}
- (void)loginGoogleRootViewController:(UIViewController *)rootViewController complete:(void(^)(GIDGoogleUser * _Nullable user,NSError *_Nullable error))complete{
    
//    [GIDSignIn sharedInstance].presentingViewController = rootViewController;
//    [[GIDSignIn sharedInstance] signIn];
//    self.loginComplete = complete;
    
}
/// 推出谷歌登录
- (void)logoutGoogle{
//    NSError *signOutError;
//    BOOL status = [[FIRAuth auth] signOut:&signOutError];
//    if (!status) {
//      LKLogInfo(@"Error signing out: %@", signOutError);
//      return;
//    }
}
//实现您的应用委托中的 application:openURL:options: 方法。此方法应该调用 GIDSignIn 实例的 handleURL 方法，该方法将对您的应用在身份验证过程结束时收到的网址进行适当处理。
- (BOOL)handleURL:(NSURL *)url{
//    return [[GIDSignIn sharedInstance] handleURL:url];
    return YES;
}


// 实现您的应用委托中的 application:openURL:options: 方法。此方法应该调用 GIDSignIn 实例的 handleURL 方法，该方法将对您的应用在身份验证过程结束时收到的网址进行适当处理。
//- (BOOL)application:(nonnull UIApplication *)application
//            openURL:(nonnull NSURL *)url
//            options:(nonnull NSDictionary<NSString *, id> *)options {
//
//    return [[GIDSignIn sharedInstance] handleURL:url];
//}

// 要让您的应用在 iOS 8 及更早版本上也能运行，还需要实现已弃用的 application:openURL:sourceApplication:annotation: 方法。
//- (BOOL)application:(UIApplication *)application
//            openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication
//         annotation:(id)annotation {
//    return [[GIDSignIn sharedInstance] handleURL:url];
//}


//
//- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error{
//    if (error == nil) {
//      GIDAuthentication *authentication = user.authentication;
//      FIRAuthCredential *credential = [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
//                                       accessToken:authentication.accessToken];
//
//        LKLogInfo(@"---->%@",credential);
//      // ...
//    } else {
//      // ...
//    }
//
//
//    if (self.loginComplete) {
//        self.loginComplete(user, error);
//    }
//}
//
//- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
//    //  user.userID; 111052780984513320797
//
//    // user.authentication.idToken eyJhbGciOiJSUzI1NiIsImtpZCI6IjI1N2Y2YTU4MjhkMWU0YTNhNmEwM2ZjZDFhMjQ2MWRiOTU5M2U2MjQiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI4MTQxMTI1NTk2NDEtYzYyZWNnN3JkNHBkbnNwNnNkMGFlYWVoZXRzdDZpMG8uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI4MTQxMTI1NTk2NDEtYzYyZWNnN3JkNHBkbnNwNnNkMGFlYWVoZXRzdDZpMG8uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMTEwNTI3ODA5ODQ1MTMzMjA3OTciLCJlbWFpbCI6InN3aWZ0LmRldmVsb3Blci5kYWlAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImF0X2hhc2giOiI5Wl95N2VLVC1iN291YnpjOXlGY0RRIiwibm9uY2UiOiI5LVQ5REdNeDFEc3ZSaGRGSVVnb05JcElHOXNpY2h3S1pLbU9iMjV1OFVFIiwibmFtZSI6IlN3aWZ0IEFsYW4iLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tLy1uNm1xd1pIVkNVMC9BQUFBQUFBQUFBSS9BQUFBQUFBQUFBQS9BQUtXSkpOaVFlektRYXp2RVJ3WjJtUFJjczRkQm1IVXlRL3M5Ni1jL3Bob3RvLmpwZyIsImdpdmVuX25hbWUiOiJTd2lmdCIsImZhbWlseV9uYW1lIjoiQWxhbiIsImxvY2FsZSI6InpoLUNOIiwiaWF0IjoxNTg1ODI5MjEzLCJleHAiOjE1ODU4MzI4MTN9.Uo6fhGTD9csNd55XgkHysswaL8r8Cz3JiLWja8kxHVCLCjXRp1uQpm43J3OLZfrerk-mHud-r_W44iKaiDgcFrfkSStLzm3NvwFzTWksGd1coNYtRI6bC5g1faWcnyVFnxS8THZWX2f9QsReF6Y0YA-FEqmEhJYFEGj08F7bPuug1Ttw0eL8gsqrRDpv86HoK6hTpNf6M4_IUg7KI-o8n2GF5BvzHf7cIY0gSFQGHgFlZn2u3MR34XppfNkhe4XsrW8lQ5jJaOLj-3WlNeUFg7uoP9ym_NVR0XQYk79j8YEkaxx6LTrC2UQaW-ruzqfPOBitznkBCRtY49YfNXsMRw
//
//    //user.profile.name; Swift Alan
//
//    //user.profile.givenName; Swift
//
//    // user.profile.familyName; Alan
//
//    //user.profile.email;  swift.developer.dai@gmail.com
//
//   // error.code == kGIDSignInErrorCodeCanceled
//    if (self.loginComplete) {
//        self.loginComplete(user, error);
//    }
//
//
////     NSString *userId = user.userID;                  // For client-side use only!
////     NSString *idToken = user.authentication.idToken; // Safe to send to the server
////     NSString *fullName = user.profile.name;
////     NSString *givenName = user.profile.givenName;
////     NSString *familyName = user.profile.familyName;
////     NSString *email = user.profile.email;
//
////    LKLogInfo(@"userId = %@",userId);
////    LKLogInfo(@"idToken = %@",idToken);
////    LKLogInfo(@"fullName = %@",fullName);
////    LKLogInfo(@"givenName = %@",givenName);
////    LKLogInfo(@"familyName = %@",familyName);
////    LKLogInfo(@"email = %@",email);
//}
//


@end

