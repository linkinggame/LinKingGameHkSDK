//
//  LELoginView.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/10.
//  Copyright © 2020 "". All rights reserved.
//

#import "LELoginView.h"
#import <Toast/Toast.h>
#import "UIImage+LEAdditions.h"
#import "NSBundle+LEAdditions.h"
#import "LELanguage.h"
#import <AuthenticationServices/AuthenticationServices.h>
#import "NSBundle+LEAdditions.h"
@interface LELoginView ()
@property (nonatomic,weak) UIView *contentView;
@end

@implementation LELoginView

+ (instancetype)instanceOauthView{
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"LinKingGameHkSDKBundle" withExtension:@"bundle"]];
    LELoginView *view = [[bundle loadNibNamed:@"LELoginView" owner:nil options:nil] firstObject];
   view.layer.cornerRadius = 15;
   view.clipsToBounds = YES;
     view.label_or.text = [NSBundle le_localizedStringForKey:@"Other Login"];
     view.label_oneTip.text = [NSBundle le_localizedStringForKey:@"agree"];
     [view.button_PrivacyPolicy setTitle:[NSBundle le_localizedStringForKey:@"Privacy Policy"] forState:UIControlStateNormal];
     [view.button_UserAgreement setTitle:[NSBundle le_localizedStringForKey:@"User Agreement"] forState:UIControlStateNormal];
    
    [view.button_visitors_login setTitle:[NSBundle le_localizedStringForKey:@"Guest Login"] forState:UIControlStateNormal];
    

    NSLog(@"==%@",[NSBundle le_localizedStringForKey:@"Sign in with Apple"]);
    view.button_fb_login.layer.cornerRadius = 5;
    view.button_fb_login.clipsToBounds = YES;
    view.button_apple_login.layer.cornerRadius = 5;
    view.button_apple_login.clipsToBounds = YES;
    
    [view.button_apple_login setTitle:[NSBundle le_localizedStringForKey:@"Sign in with Apple"] forState:UIControlStateNormal];
    
    [view.button_fb_login setTitle:[NSBundle le_localizedStringForKey:@"Sign in with Facebook"] forState:UIControlStateNormal];
    
//    if (@available(iOS 13.0, *)) {
//        view.view_apple.layer.cornerRadius = 5;
//        view.view_apple.clipsToBounds = YES;
//
//        view.view_apple.hidden = NO;
//        view.layout_fb_top.constant = 15;
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
//        view.layout_fb_top.constant = 30;
//    }
    
    return view;
}
- (void)setLESuperView:(UIView *)superView{
    self.contentView = superView;
}

- (IBAction)closeAlterViewAction:(id)sender {
    
    if (self.closeAlterViewCallBack) {
        self.closeAlterViewCallBack();
    }
    
}


- (void)appleLoginAction{
    
    if (self.button_box.selected == NO) {
        NSString *tip = [NSBundle le_localizedStringForKey:@"Agreement not checked"];
        [self.contentView makeToast:tip duration:2 position:CSToastPositionCenter];
        return;
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = 20;
    if(self.thirdLoginCallBack){
        self.thirdLoginCallBack(button);
    }

}

- (IBAction)startAction:(id)sender {
    if (self.button_box.selected == NO) {
          [self endEditing:YES];
        NSString *tip = [NSBundle le_localizedStringForKey:@"Agreement not checked"];
        [self.contentView makeToast:tip duration:2 position:CSToastPositionCenter];
        return;
    }
    if (self.startLoginCallBack) {
        self.startLoginCallBack();
    }
}

- (IBAction)thirdLoginAction:(UIButton *)sender {
    if (self.button_box.selected == NO) {
          [self endEditing:YES];
        NSString *tip = [NSBundle le_localizedStringForKey:@"Agreement not checked"];
         [self.contentView makeToast:tip duration:2 position:CSToastPositionCenter];
        return;
    }
    if (self.thirdLoginCallBack) {
        self.thirdLoginCallBack(sender);
    }
}
- (IBAction)useAgreementAction:(UIButton *)sender {
    
    if (self.useAgreemmentCallBack) {
        self.useAgreemmentCallBack(self.button_box.isSelected,sender);
    }
    

}

- (IBAction)changeBoxStatusAction:(UIButton *)sender {
    if (self.button_box.isSelected) {
        [self.button_box setBackgroundImage:[UIImage le_ImageNamed:@"nocheckmark"] forState:UIControlStateNormal];
        
    }else{
        [self.button_box setBackgroundImage:[UIImage le_ImageNamed:@"checkmark"] forState:UIControlStateNormal];
    }

    self.button_box.selected = !sender.selected;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
