//
//  LEBindingApi.m
//  LinKingEnSDK
//
//  Created by MrDML on 2020/8/16.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEBindingApi.h"
#import "LENetWork.h"
#import "LEUser.h"
#import "LELanguage.h"
#import "LESystem.h"
@implementation LEBindingApi

+ (void)bindingAccountWithToken:(NSString *)token withType:(NSString *)type complete:(void(^)(NSError *error,LEUser *user))complete{
    
    
        NSString *url = [NSString stringWithFormat:@"%@%@",[self baseURL],@"user/bind"];
       NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[self defaultParamesSimple]];
    
      [parameters setObject:token forKey:@"token"];
      [parameters setValue:type forKey:@"type"];
      NSMutableDictionary *headers = [NSMutableDictionary dictionary];

      LEUser *user = [LEUser getUser];
      [headers setObject:user.token forKey:@"LK_TOKEN"];
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

+ (void)appleBindingAccountWithToken:(NSString *)token complete:(void(^)(NSError *error,LEUser *user))complete{

    [self bindingAccountWithToken:token withType:@"Ios" complete:complete];
    
}

+ (void)googleBindingAccountWithToken:(NSString *)token complete:(void(^)(NSError *error,LEUser *user))complete{
   [self bindingAccountWithToken:token withType:@"Google" complete:complete];
}

+ (void)facebookBindingAccountWithToken:(NSString *)token complete:(void(^)(NSError *error,LEUser *user))complete{
   [self bindingAccountWithToken:token withType:@"Facebook" complete:complete];
}

@end
