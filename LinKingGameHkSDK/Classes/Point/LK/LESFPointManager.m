//
//  LESFPointManager.m
//  LinKingEnSDK
//
//  Created by MrDML on 2020/8/16.
//  Copyright © 2020 "". All rights reserved.
//

#import "LESFPointManager.h"
#import "LEPointApi.h"
#import "LESDKConfig.h"
static LESFPointManager *_instance = nil;
@implementation LESFPointManager
+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LESFPointManager alloc] init];
    });
    return _instance;
}
- (void)activatePointWithComplete:(void (^)(NSError * _Nullable))complete{
    
    [LEPointApi pointEventName:@"Activation" withTp:@"Activation" withValues:nil complete:^(NSError * _Nonnull error) {
        if (complete) {
           complete(error);
        }
    }];
    

}
- (void)adstandardPointEventName:(NSString *)eventName withParameters:(NSDictionary *)params complete:(void(^)(NSError *error))complete{

    [LEPointApi adPointEventName:eventName withValues:params complete:^(NSError * _Nonnull error) {
        if (complete) {
            complete(error);
        }
    }];
    
}
/// 标准事件 -
- (void)standardPointEventName:(NSString *)eventName withParameters:(NSDictionary *)params complete:(void(^)(NSError *error))complete{

    [LEPointApi pointEventName:eventName withTp:eventName withValues:params complete:complete];
    
}

/// 自定义事件 -
- (void)customePointEventName:(NSString *)eventName withParameters:(NSDictionary *)params complete:(void(^)(NSError *error))complete{

    [LEPointApi pointEventName:eventName withTp:@"event" withValues:params complete:complete];
    
   
    
    
}

/**
 RoleInfo 公用四个事件
 等级 关卡 新手引导 进入游戏
        
 */

/// 等级
/// @param level 等级
- (void)logAchieveLevelEvent:(int)level serverId:(NSString *)serverId roleId:(NSString *)roleId roleName:(NSString *)roleName complete:(void(^_Nullable)(NSError * _Nullable error))complete{
    
    NSDictionary *params = @{
        @"server_id":serverId,
         @"role_id":roleId,
        @"role_name":roleName,
        @"level":[NSString stringWithFormat:@"%ld",(long)level]
    };
    
    // tag: repelace sls
    [LEPointApi pointEventName:@"level" withTp:@"RoleInfo" withValues:params complete:complete];
    
   
    
}

/// 关卡
- (void)logAchieveStageEvent:(int)stage serverId:(NSString *)serverId roleId:(NSString *)roleId roleName:(NSString *)roleName complete:(void(^_Nullable)(NSError * _Nullable error))complete{
    NSDictionary *params = @{
        @"server_id":serverId,
         @"role_id":roleId,
        @"role_name":roleName,
        @"stage":[NSString stringWithFormat:@"%ld",(long)stage]
    };

   [LEPointApi pointEventName:@"stage" withTp:@"RoleInfo" withValues:params complete:complete];
   
}

/// 新手引导
- (void)logAchieveCompleteTutorialId:(NSString *)contentId eventServerId:(NSString *)serverId roleId:(NSString *)roleId roleName:(NSString *)roleName complete:(void(^_Nullable)(NSError * _Nullable error))complete{
    NSDictionary *params = @{
        @"server_id":serverId,
         @"role_id":roleId,
        @"role_name":roleName,
        @"guide_step":contentId
    };

   [LEPointApi pointEventName:@"guide_step" withTp:@"RoleInfo" withValues:params complete:complete];
    
}

/// 进入游戏
- (void)logEnterGameServerId:(NSString *)serverId roleId:(NSString *)roleId roleName:(NSString *)roleName enterGame:(BOOL)enterGame complete:(void(^_Nullable)(NSError * _Nullable error))complete{
    
    NSString *enterGameStr = nil;
    if (enterGame == YES) {
        enterGameStr = @"true";
    }else{
        enterGameStr = @"false";
    }
    
    NSDictionary *params = @{
        @"server_id":serverId,
         @"role_id":roleId,
        @"role_name":roleName,
        @"enter_game":enterGameStr
    };

   [LEPointApi pointEventName:@"enter_game" withTp:@"RoleInfo" withValues:params complete:complete];
    
    
}

/// 创建角色
- (void)logRoleCreate:(NSString *)serverId roleId:(NSString *)roleId roleName:(NSString *)roleName{
    
    NSDictionary *params = @{
        @"server_id":serverId,
         @"role_id":roleId,
        @"role_name":roleName,
    };
    [LEPointApi pointEventName:@"RoleCreate" withTp:@"RoleCreate" withValues:params complete:nil];
}

///  角色登录
- (void)logRoleLogin:(NSString *)serverId roleId:(NSString *)roleId{
    NSDictionary *params = @{
        @"server_id":serverId,
         @"role_id":roleId,
    };
    
    [LEPointApi pointEventName:@"RoleLogin" withTp:@"RoleLogin" withValues:params complete:nil];
}

@end
