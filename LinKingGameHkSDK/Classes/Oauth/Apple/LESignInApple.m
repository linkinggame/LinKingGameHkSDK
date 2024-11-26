//
//  LESignInApple.m
//  LinKingEnSDK
//
//  Created by MrDML on 2020/8/15.
//  Copyright © 2020 "". All rights reserved.
//

#import "LESignInApple.h"
#import "LEHandleKeychain.h"
#import <AuthenticationServices/AuthenticationServices.h>
#import "MF_Base64Additions.h"
#import "LEGlobalConf.h"
#import "LKLog.h"
#define KEYCHAIN_IDENTIFIER(a) ([NSString stringWithFormat:@"%@_%@",[[NSBundle mainBundle] bundleIdentifier],a])

@interface LESignInApple ()<ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding>

@end
static LESignInApple *_instance;
@implementation LESignInApple
+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LESignInApple alloc] init];
        
        
        if (@available(iOS 13.0, *)) {//判断授权是否失效
            [[NSNotificationCenter defaultCenter] addObserver:_instance selector:@selector(monitorSignInWithAppleStateChanged:) name:ASAuthorizationAppleIDProviderCredentialRevokedNotification object:nil];
        }
    });
    return _instance;
}

- (void)monitorSignInWithAppleStateChanged:(NSNotification *)notification {
    LKLogInfo(@"state CHANGE -  %@",notification);
}
- (void)loginAppleWithComplete:(void (^)(BOOL))complete{
    
   if (@available(iOS 13.0,*)) {
       // 基于用户的Apple ID授权用户，生成用户授权请求的一种机制
          ASAuthorizationAppleIDProvider *appleIDProvider = [[ASAuthorizationAppleIDProvider alloc] init];
          // 创建新的AppleID 授权请求
          ASAuthorizationAppleIDRequest *appleIDRequest = [appleIDProvider createRequest];
          // 在用户授权期间请求的联系信息
          appleIDRequest.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];
          
          //需要考虑已经登录过的用户，可以直接使用keychain密码来进行登录
          ASAuthorizationPasswordProvider *appleIDPasswordProvider = [ASAuthorizationPasswordProvider new];
          ASAuthorizationPasswordRequest *passwordRequest = appleIDPasswordProvider.createRequest;
          
          // 由ASAuthorizationAppleIDProvider创建的授权请求 管理授权请求的控制器
          ASAuthorizationController *authorizationController = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[appleIDRequest]];
          // 设置授权控制器通知授权请求的成功与失败的代理
          authorizationController.delegate = self;
          // 设置提供 展示上下文的代理，在这个上下文中 系统可以展示授权界面给用户
          authorizationController.presentationContextProvider = self;
          // 在控制器初始化期间启动授权流
          [authorizationController performRequests];
       
       if (complete) {
           complete(YES);
       }
       
   }else{

       if (complete) {
           complete(NO);
       }
       LKLogInfo(@"系统版本过低，请先升级，继续使用Sign In With Apple");
   }
    
}

#pragma mark -ASAuthorizationControllerPresentationContextProviding
// 告诉代理应该在哪个window 展示内容给用户
- (ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller API_AVAILABLE(ios(13.0)){

  // 返回window
    return [UIApplication sharedApplication].windows.lastObject;
}

#pragma mark - ASAuthorizationControllerDelegate

/// 授权登录失败
/// @param controller <#controller description#>
/// @param error <#error description#>
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error API_AVAILABLE(ios(13.0)){
    
    
    if (self.didCompleteWithError) {
        self.didCompleteWithError(error);
    }
     
    LKLogInfo(@"错误信息：%@", error);
     NSString *errorMsg;
    switch (error.code) {
        case ASAuthorizationErrorCanceled:
            errorMsg = @"用户取消了授权请求";
            LKLogInfo(@"errorMsg -   %@",errorMsg);
            break;
            
        case ASAuthorizationErrorFailed:
            errorMsg = @"授权请求失败";
            LKLogInfo(@"errorMsg -   %@",errorMsg);
            break;
            
        case ASAuthorizationErrorInvalidResponse:
            errorMsg = @"授权请求响应无效";
            LKLogInfo(@"errorMsg -   %@",errorMsg);
            break;
            
        case ASAuthorizationErrorNotHandled:
            errorMsg = @"未能处理授权请求";
            LKLogInfo(@"errorMsg -   %@",errorMsg);
            break;
            
        case ASAuthorizationErrorUnknown:
            errorMsg = @"授权请求失败未知原因";
            LKLogInfo(@"errorMsg -   %@",errorMsg);
            break;
                        
        default:
            break;
    }

    
}


/// 授权成功的回调
/// @param controller <#controller description#>
/// @param authorization <#authorization description#>
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization API_AVAILABLE(ios(13.0)){
    
    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
     ASAuthorizationAppleIDCredential *credential  = authorization.credential;

        NSString *user = credential.user;
        NSData *identityToken = credential.identityToken;
        NSData *code = credential.authorizationCode;
        NSString *token  = [[NSString alloc] initWithData:identityToken encoding:NSUTF8StringEncoding];
        NSString *code_str  = [[NSString alloc] initWithData:code encoding:NSUTF8StringEncoding];

        if (token != nil) {
               NSArray *tokens = [token componentsSeparatedByString:@"."];

               // 授权成功后将一下信息提交给后台
            LKLogInfo(@"user = %@, token = %@, code = %@",user,token,code_str);
               
               // 解析 token 获取 playload 中的sub 和user 进行对比如果一致提交给我后台

               NSString *header = tokens[0];
               NSString *playload = tokens[1];

               NSData *headerData = [NSData dataWithBase64String:header];
               NSString *decoderHeader = [[NSString alloc] initWithData:headerData encoding:NSUTF8StringEncoding];
               
               NSData *playloadData = [NSData dataWithBase64String:playload];
               NSString *decoderplayload = [[NSString alloc] initWithData:playloadData encoding:NSUTF8StringEncoding];
               
            LKLogInfo(@"=====================");
            LKLogInfo(@"decoderHeader:%@",decoderHeader);
            LKLogInfo(@"decoderplayload:%@",decoderplayload);
            LKLogInfo(@"=====================");
            //  需要使用钥匙串的方式保存用户的唯一信息
            [LEHandleKeychain save:KEYCHAIN_IDENTIFIER(@"SignInWithApple") data:user];
            self.didCompleteWithAuthorization(1,user,token,code_str,nil);
            
//            if (decoderplayload != nil) {
//                NSDictionary *playload_dict =  [self jsonStringCovertDictionary:decoderplayload];
//
//                   NSString *sub = playload_dict[@"sub"];
//                   if ([sub isEqualToString:user]) { // 验证是否相等
//                       if (self.didCompleteWithAuthorization) {
//                           self.didCompleteWithAuthorization(1,user,token,code_str,nil);
//                       }
//                   }else{
//                       LKLogInfo(@"验证失败。。。");
//                   }
//            }else{
//                LKLogInfo(@"验证失败。。。");
//            }
  
        }else{
            LKLogInfo(@"验证失败。。。");
            self.didCompleteWithAuthorization(3,nil,nil,nil,nil);
        }
        
        /*
         user = 002001.ba52389ea3ca412b8a834bb5a7d84b54.0524, token = {length = 832, bytes = 0x65794a72 61575169 4f694a6c 57474631 ... 33333753 37783977 }
         **/
        
    }else if ([authorization.credential isKindOfClass:[ASPasswordCredential class]]){
        // 用户登录使用现有的密码凭证
        ASPasswordCredential *psdCredential = authorization.credential;
        // 密码凭证对象的用户标识 用户唯一标识
        NSString *user = psdCredential.user;
        
        NSString *psd = psdCredential.password;
        
        LKLogInfo(@"user = %@, psd = %@",user,psd);
        
        if (user != nil && psd != nil) {
            if (self.didCompleteWithAuthorization) {
                   self.didCompleteWithAuthorization(2,user,nil,nil,psd);
               }
        }
        
    }else{
        LKLogInfo(@"授权信息不符");
    }
}



- (NSDictionary *)jsonStringCovertDictionary:(NSString *)jsonString{
    
   NSData *data =  [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
   id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
  
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = (NSDictionary *)object;
        return dictionary;
    }
    return nil;
}
@end
