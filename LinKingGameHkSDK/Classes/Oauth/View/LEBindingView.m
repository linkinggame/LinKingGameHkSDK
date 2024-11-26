//
//  LEBindingView.m
//  LinKingEnSDK
//
//  Created by MrDML on 2020/8/15.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEBindingView.h"
#import <AuthenticationServices/AuthenticationServices.h>
#import "NSBundle+LEAdditions.h"
@implementation LEBindingView


+ (instancetype)instanceBindingView{
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"LinKingGameHkSDKBundle" withExtension:@"bundle"]];
    LEBindingView *view = [[bundle loadNibNamed:@"LEBindingView" owner:nil options:nil] firstObject];
   view.layer.cornerRadius = 15;
   view.clipsToBounds = YES;
    view.contentView.layer.cornerRadius = 15;
    view.contentView.clipsToBounds = YES;
    
    
    view.button_fb.layer.cornerRadius = 5;
    view.button_fb.clipsToBounds = YES;
    view.appleBtn.layer.cornerRadius = 5;
    view.appleBtn.clipsToBounds = YES;
    
    NSLog(@"==%@",[NSBundle le_localizedStringForKey:@"Sign in with Apple"]);
    
    [view.appleBtn setTitle:[NSBundle le_localizedStringForKey:@"Sign in with Apple"] forState:UIControlStateNormal];
    
    [view.faceBookBtn setTitle:[NSBundle le_localizedStringForKey:@"Sign in with Facebook"] forState:UIControlStateNormal];
    
    view.label_info.text =  [NSBundle le_localizedStringForKey:@"Bind with Facebook or Apple account to save your progress"];

//    if (@available(iOS 13.0, *)) {
//
//        view.view_apple.hidden = NO;
//        view.layout_fb_top.constant = 30;
//
//        ASAuthorizationAppleIDButton *button = [ASAuthorizationAppleIDButton buttonWithType:ASAuthorizationAppleIDButtonTypeSignIn style:ASAuthorizationAppleIDButtonStyleBlack];
//        [button addTarget:view action:@selector(appleLoginAction) forControlEvents:UIControlEventTouchUpInside];
//        button.layer.cornerRadius = 5;
//        button.clipsToBounds = YES;
//        [view.view_apple addSubview:button];
//
//        button.translatesAutoresizingMaskIntoConstraints = NO;
//        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view.view_apple attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
//
//        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:view.view_apple attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
//
//        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view.view_apple attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
//
//        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view.view_apple attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
//
//        [view.view_apple addConstraints:@[left,right,top,bottom]];
//
//    }else{
//        view.view_apple.hidden = YES;
//        view.layout_fb_top.constant = 50;
//    }
    
    
    
    return view;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)appleLoginAction{
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = 20;
    if(self.thirdBindingCallBack){
        self.thirdBindingCallBack(button);
    }

}

- (IBAction)thirdBindingAction:(UIButton *)sender {
    
    if (self.thirdBindingCallBack) {
        self.thirdBindingCallBack(sender);
    }
}

- (IBAction)closeAlterViewAction:(id)sender {
    if (self.closeAlterViewCallBack) {
        self.closeAlterViewCallBack();
    }
}


@end
