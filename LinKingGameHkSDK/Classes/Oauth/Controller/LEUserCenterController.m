//
//  LEUserCenterController.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/10.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEUserCenterController.h"
#import "LEUserCenterView.h"
#import "LEUser.h"
#import "NSBundle+LEAdditions.h"
#import "NSObject+LEAdditions.h"
@interface LEUserCenterController ()

@end

@implementation LEUserCenterController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self showUserCenterView];
}


- (void)showUserCenterView{
    LEUserCenterView *userCenterView = [LEUserCenterView instanceUserCenterView];

       [self.view insertSubview:userCenterView atIndex:self.view.subviews.count];
       CGFloat width = 292;
        CGFloat screen_width = [UIScreen mainScreen].bounds.size.width;
        if (width > screen_width) {
            width = screen_width - 40;
        }
       userCenterView.translatesAutoresizingMaskIntoConstraints = NO;

       [self setAlterContentView:userCenterView];
       [self setAlterHeight:327];
       [self setAlterWidth:width];
       [self layoutConstraint];

    
    LEUser *user = [LEUser getUser];
    

     userCenterView.label_id.adjustsFontSizeToFitWidth = YES;
     NSString *useridStr = [NSString stringWithFormat:@"%@",[NSBundle le_localizedStringForKey:@"User ID"]];
     
     userCenterView.label_id.text = [NSString stringWithFormat:@"%@: %@",useridStr,(user.userId == nil) ? @"":user.userId];
    
     
     if (user.third_id.exceptNull != nil) {
         userCenterView.labe_Account_Tip.hidden = NO;
         userCenterView.labe_Account_Tip.text = [NSBundle le_localizedStringForKey:@"The account is already bound"];
          
         
     }else{
         userCenterView.labe_Account_Tip.hidden = NO;
       userCenterView.labe_Account_Tip.text = [NSBundle le_localizedStringForKey:@"Bind with Facebook or Apple account to save your progress"];

     }
    

    
    userCenterView.closeAlterViewCallBack = ^{
        [self dismissViewControllerAnimated:NO completion:nil];
    };
    
    
    userCenterView.changeAccountCallBack = ^{
        [self changeAccount];
    };
    
    
    userCenterView.bindingAccountCallBack = ^{
        [self bindingAccount];
    };
    
    userCenterView.logoutCallBack = ^{
        [self logOut];
    };
    
    
}


- (void)changeAccount{
    
    [self dismissViewControllerAnimated:NO completion:^{
       [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeAccount" object:nil];
    }];
    
}

- (void)bindingAccount{
    [self dismissViewControllerAnimated:NO completion:^{
       [[NSNotificationCenter defaultCenter] postNotificationName:@"BinDingAccount" object:nil];
    }];
}


- (void)logOut{
    
    [LEUser removeUserInfo];
    [self dismissViewControllerAnimated:NO completion:^{
       [[NSNotificationCenter defaultCenter] postNotificationName:@"LougOut" object:nil];
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
