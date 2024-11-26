//
//  LEPointViewController.m
//  LinKingGameHkSDK_Example
//
//  Created by admin on 2024/11/26.
//  Copyright © 2024 leon. All rights reserved.
//

#import "LEPointViewController.h"
#import <LinKingGameHkSDK/LinKingGameHkSDK.h>
@interface LEPointViewController ()

@end

@implementation LEPointViewController


- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)pointEvent_A:(id)sender {
    NSLog(@"==SDK内置打点==");
}

- (IBAction)pointEvent_B:(id)sender {
    
    [[LEPointManager shared] logEnterGame:@"110" roleId:@"100" roleName:@"唐三" enterGame:YES];
}

- (IBAction)pointEvent_C:(id)sender {
    NSLog(@"==SDK内置打点==");
}
- (IBAction)pointEvent_D:(id)sender {
    [[LEPointManager shared] logRoleCreate:@"10000" roleId:@"10000" roleName:@"小舞"];
}
- (IBAction)pointEvent_E:(id)sender {
    [[LEPointManager shared] logRoleLogin:@"10000" roleId:@"10000"];
}
- (IBAction)pointEvent_F:(id)sender {
    [[LEPointManager shared] logLevel:1 serverId:@"110" roleId:@"100" roleName:@"leon"];
}
- (IBAction)pointEvent_G:(id)sender {
    [[LEPointManager shared] logStage:1 serverId:@"10000" roleId:@"10000" roleName:@"竹青"];
}
- (IBAction)pointEvent_H:(id)sender {
    NSLog(@"==SDK内置打点==");
}
- (IBAction)pointEvent_I:(id)sender {
    [[LEPointManager shared] logTutorial:@"1" content:@"1" EventServerId:@"100" roleId:@"200" roleName:@"胖子"];
}
- (IBAction)pointEvent_J:(id)sender {
    
    NSArray *events = @[
        @"TapMonster",
        @"OpenRole",
        @"OpenBag",
        @"RecommendAddPoint",
        @"ShowEquipPos",
        @"WearEquip",
        @"DailyReward",
        @"EventSwich",
        @"EventSwichOpen",
        @"PassLevel1",
        @"PassLevel2",
        @"PassLevel3",
        @"PassLevel4",
        @"PassLevel5",
        @"PassLevel6",
        @"PassLevel7",
        @"D2",
        @"D3",
        @"D4",
        @"D5",
        @"D6",
        @"D7",
        @"D15",
        @"FistFinish8",
        @"FistFinish12",
        @"FistFinish16",
        @"ShowOfflineReward",
        @"Relife",
        @"OpenBlackmarket",
        @"OpenBlackmarket",
        @"UseSprite",
        @"UseTitle",
        
    
    ];
    
    
    
    srand((unsigned)time(0));
    int num = rand() % (events.count - 1);
    [[LEPointManager shared] logEvent:events[num] withValues:@{}];
}
- (IBAction)pointEvent_K:(id)sender {
    NSArray *events = @[
        @"TapMonster",
        @"OpenRole",
        @"OpenBag",
        @"RecommendAddPoint",
        @"ShowEquipPos",
        @"WearEquip",
        @"DailyReward",
        @"EventSwich",
        @"EventSwichOpen",
        @"PassLevel1",
        @"PassLevel2",
        @"PassLevel3",
        @"PassLevel4",
        @"PassLevel5",
        @"PassLevel6",
        @"PassLevel7",
        @"D2",
        @"D3",
        @"D4",
        @"D5",
        @"D6",
        @"D7",
        @"D15",
        @"FistFinish8",
        @"FistFinish12",
        @"FistFinish16",
        @"ShowOfflineReward",
        @"Relife",
        @"OpenBlackmarket",
        @"OpenBlackmarket",
        @"UseSprite",
        @"UseTitle",
        
    
    ];
    
    
    
    srand((unsigned)time(0));
    int num = rand() % (events.count - 1);
    
    [[LEPointManager shared] logEvent:events[num]];
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
