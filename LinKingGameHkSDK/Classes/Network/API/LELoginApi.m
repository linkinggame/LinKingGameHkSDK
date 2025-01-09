//
//  LELoginApi.m
//  LinKingEnSDK
//
//  Created by MrDML on 2020/8/15.
//  Copyright © 2020 "". All rights reserved.
//

#import "LELoginApi.h"
#import "LENetWork.h"
#import "LEUser.h"
#import "LELanguage.h"
#import "LESystem.h"
#import "LKLog.h"
@implementation LELoginApi

/// 快速登录
+ (void)quickLoginComplete:(void(^)(NSError *error,LEUser *user))complete{

       NSString *url = [NSString stringWithFormat:@"%@%@",[self baseURL],@"login/direct_login"];
       NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[self defaultParames]];
    
      NSMutableDictionary *headers = [NSMutableDictionary dictionary];
        if ([LELanguage shared].preferredLanguage != nil) {
             [headers setObject:[LELanguage shared].preferredLanguage forKey:@"LK_LANGUAGE"];
        }
      [LENetWork postWithURLString:url parameters:parameters HTTPHeaderField:headers success:^(id  _Nonnull responseObject) {
           NSNumber *success = responseObject[@"success"];
           NSString *desc = responseObject[@"desc"];
           NSString *code = responseObject[@"code"];
           NSDictionary *data = responseObject[@"data"];
          if ([success boolValue] == YES) {
              LEUser *user = [[LEUser alloc] initWithDictionary:data[@"user"]];
              if (user != nil) {
                  // 将用户信息存储到本地
                  [LEUser setUser:user];
              }
              dispatch_async(dispatch_get_main_queue(), ^{
                  if (complete) {
                      complete(nil,user);
                  }
              });

          }else{
              dispatch_async(dispatch_get_main_queue(), ^{
                  if ([code intValue] == 2234) {
                      if ([code intValue]) {
                          NSDictionary *data = responseObject[@"data"];
                          if ([data isKindOfClass:[NSDictionary class]]) {
                             NSString *userId = data[@"user_id"];
                             if (userId != nil) {
                                 [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"LKUSERID"];
                                 [[NSUserDefaults standardUserDefaults] synchronize];
                             }
                          }
                      }
                  }

                  complete([self responserErrorMsg:desc code:[code intValue]],nil);
              });
          }
      } failure:^(NSError * _Nonnull error) {
          dispatch_async(dispatch_get_main_queue(), ^{
              complete(error,nil);
          });
      }];
}

/// 苹果登录
/// @param complete <#complete description#>
+ (void)appleLoginWithToken:(NSString *)token complete:(void(^)(NSError *error,LEUser *user))complete{

         NSString *url = [NSString stringWithFormat:@"%@%@",[self baseURL],@"login/ios_login"];
         NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[self defaultParames]];
      
        [parameters setObject:token forKey:@"id_token"];
        NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    
        if ([LELanguage shared].preferredLanguage != nil) {
             [headers setObject:[LELanguage shared].preferredLanguage forKey:@"LK_LANGUAGE"];
        }
               
        [LENetWork postWithURLString:url parameters:parameters HTTPHeaderField:headers success:^(id  _Nonnull responseObject) {
            NSNumber *success = responseObject[@"success"];
            NSString *desc = responseObject[@"desc"];
            NSDictionary *data = responseObject[@"data"];
             NSString *code = responseObject[@"code"];
            if ([success boolValue] == YES) {
                LEUser *user = [[LEUser alloc] initWithDictionary:data[@"user"]];
                if (user != nil) {
                    // 将用户信息存储到本地
                    [LEUser setUser:user];
                }
                
                // 记录登录方式
                 LESystem *systemOld =[LESystem getSystem];
                 systemOld.loginStyle = @"apple";
                 systemOld.token = token;
                 systemOld.userToken = token;
                 [LESystem setSystem:systemOld];
                 
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (complete) {
                        complete(nil,user);
                    }
                });

            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete([self responserErrorMsg:desc code:[code intValue]],nil);
                });
            }
        } failure:^(NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(error,nil);
            });
        }];
    
}


+ (void)facebookLoginWithToken:(NSString *)token complete:(void(^)(NSError *error,LEUser *user))complete{
         NSString *url = [NSString stringWithFormat:@"%@%@",[self baseURL],@"login/fb_login"];
        /*NSString *url = [NSString stringWithFormat:@"%@%@", @"https://lk-sdk-hk.chiji-h5.com/server/s/SoccerClubTycoon_ios/",@"login/fb_login"];
         */
         NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[self defaultParames]];
      
    LKLogInfo(@"====facebookLoginWithToken======2222== %@", url);
        [parameters setObject:token forKey:@"access_token"];
        NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    
        if ([LELanguage shared].preferredLanguage != nil) {
             [headers setObject:[LELanguage shared].preferredLanguage forKey:@"LK_LANGUAGE"];
        }
               
        [LENetWork postWithURLString:url parameters:parameters HTTPHeaderField:headers success:^(id  _Nonnull responseObject) {
            NSNumber *success = responseObject[@"success"];
            NSString *desc = responseObject[@"desc"];
            NSDictionary *data = responseObject[@"data"];
             NSString *code = responseObject[@"code"];
            if ([success boolValue] == YES) {
                LEUser *user = [[LEUser alloc] initWithDictionary:data[@"user"]];
                if (user != nil) {
                    // 将用户信息存储到本地
                    [LEUser setUser:user];
                }
                
               
               // 记录登录方式
                LESystem *systemOld =[LESystem getSystem];
                systemOld.loginStyle = @"facebook";
                systemOld.token = token;
                systemOld.userToken = token;
                [LESystem setSystem:systemOld];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (complete) {
                        complete(nil,user);
                    }
                });

            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete([self responserErrorMsg:desc code:[code intValue]],nil);
                });
            }
        } failure:^(NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(error,nil);
            });
        }];
}



/// 谷歌登录
/// @param complete <#complete description#>
+ (void)googleLoginWithToken:(NSString *)token complete:(void(^)(NSError *error,LEUser *user))complete{

         NSString *url = [NSString stringWithFormat:@"%@%@",[self baseURL],@"login/gg_fb_login"];
         NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[self defaultParames]];
      
        [parameters setObject:token forKey:@"id_token"];
        NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    
        if ([LELanguage shared].preferredLanguage != nil) {
             [headers setObject:[LELanguage shared].preferredLanguage forKey:@"LK_LANGUAGE"];
        }
               
        [LENetWork postWithURLString:url parameters:parameters HTTPHeaderField:headers success:^(id  _Nonnull responseObject) {
            NSNumber *success = responseObject[@"success"];
            NSString *desc = responseObject[@"desc"];
            NSDictionary *data = responseObject[@"data"];
             NSString *code = responseObject[@"code"];
            if ([success boolValue] == YES) {
                LEUser *user = [[LEUser alloc] initWithDictionary:data[@"user"]];
                if (user != nil) {
                    // 将用户信息存储到本地
                    [LEUser setUser:user];
                }
                // 记录登录方式
                 LESystem *systemOld =[LESystem getSystem];
                 systemOld.loginStyle = @"google";
                 systemOld.token = token;
                 systemOld.userToken = token;
                 [LESystem setSystem:systemOld];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (complete) {
                        complete(nil,user);
                    }
                });

            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete([self responserErrorMsg:desc code:[code intValue]],nil);
                });
            }
        } failure:^(NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(error,nil);
            });
        }];
    
}

/// 自动登录
/// @param complete complete description
+ (void)autoLoginComplete:(void(^)(LEUser *user,NSError *error))complete{
    LEUser *userTmp = [LEUser getUser];
    if (userTmp != nil && userTmp.token != nil && userTmp.token.length >0) {
            NSString *url = [NSString stringWithFormat:@"%@%@",[self baseURL],@"login/auto_login"];
            NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[self defaultParames]];
            NSMutableDictionary *headers = [NSMutableDictionary dictionary];
            [headers setObject:userTmp.token forKey:@"LK_TOKEN"];
            [LENetWork postWithURLString:url parameters:parameters HTTPHeaderField:headers success:^(id  _Nonnull responseObject) {
                 NSNumber *success = responseObject[@"success"];
                 NSString *desc = responseObject[@"desc"];
                NSString *code = responseObject[@"code"];
                NSDictionary *data = responseObject[@"data"];
                 if ([success boolValue] == YES) {
                     LEUser *user = [[LEUser alloc] initWithDictionary:data[@"user"]];
                     if (user != nil) {
                         // 将用户信息存储到本地
                         [LEUser setUser:user];
                     }
                     dispatch_async(dispatch_get_main_queue(), ^{
                         if (complete) {
                             complete(user,nil);
                         }
                     });

                 }else{
                     dispatch_async(dispatch_get_main_queue(), ^{
                         complete(nil,[self responserErrorMsg:desc code:[code intValue]]);
                     });
                 }
             } failure:^(NSError * _Nonnull error) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     complete(nil,error);
                 });
             }];
    }else{
        LKLogInfo(@"⚠️用户信息不存在⚠️%s",__func__);
        dispatch_async(dispatch_get_main_queue(), ^{
           complete(nil,[self responserErrorMsg:@"用户信息不存在"]);
        });
    }
}



@end
