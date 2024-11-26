//
//  LEUserCenterView.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/10.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEUserCenterView.h"
#import "UIImage+LEAdditions.h"
#import "NSBundle+LEAdditions.h"
#import "LELanguage.h"
#import "LEUser.h"
#import "NSObject+LEAdditions.h"
@implementation LEUserCenterView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (instancetype)instanceUserCenterView{
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"LinKingGameHkSDKBundle" withExtension:@"bundle"]];
    LEUserCenterView *view = [[bundle loadNibNamed:@"LEUserCenterView" owner:nil options:nil] firstObject];
   view.layer.cornerRadius = 15;
   view.clipsToBounds = YES;
   [view.button_change setTitle:[NSBundle le_localizedStringForKey:@"Change"] forState:UIControlStateNormal];
    view.button_binding.layer.cornerRadius = 5;
    view.button_binding.clipsToBounds = YES;

    LEUser *user = [LEUser getUser];
    if (user.third_id.exceptNull != nil) { // 已经绑定
        view.button_binding.alpha = 0.5;
        view.button_binding.userInteractionEnabled = NO;
    }else{
        view.button_binding.userInteractionEnabled = YES;
        view.button_binding.alpha = 1;
        [view.button_binding setTitle:[NSBundle le_localizedStringForKey:@"Link your account"] forState:UIControlStateNormal];
    }
    

    
    
    view.label_title.text = [NSBundle le_localizedStringForKey:@"ACCOUNT SETTING"];
     [view.button_logout setTitle:[NSBundle le_localizedStringForKey:@"Log out"] forState:UIControlStateNormal];
    view.label_or.text = [NSBundle le_localizedStringForKey:@"OR"];
    if ([[LELanguage shared].preferredLanguage isEqualToString:@"ar"]) {
        view.imageView_rightArrow.image = [UIImage le_ImageNamed:@"leftArrow"];
    }else{
        view.imageView_rightArrow.image = [UIImage le_ImageNamed:@"rightArrow"];
    }
    
    return view;
}

- (IBAction)closerAlterViewAction:(id)sender {
    
    if (self.closeAlterViewCallBack) {
        self.closeAlterViewCallBack();
    }
    
}

- (IBAction)changeAccountAction:(id)sender {
    
    if (self.changeAccountCallBack) {
        self.changeAccountCallBack();
    }
}

- (IBAction)bindingAccountAction:(id)sender {
    
    if (self.bindingAccountCallBack) {
        self.bindingAccountCallBack();
    }
}

- (IBAction)logoutAction:(id)sender {
    
    if (self.logoutCallBack) {
        self.logoutCallBack();
    }
    
}

@end
