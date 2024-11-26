//
//  LEUseAgreementView.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/13.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEUseAgreementView.h"
#import "NSBundle+LEAdditions.h"
#import "UIImage+LEAdditions.h"
@implementation LEUseAgreementView


+ (instancetype)instanceUseAgreementView{
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"LinKingGameHkSDKBundle" withExtension:@"bundle"]];
    LEUseAgreementView *view = [[bundle loadNibNamed:@"LEUseAgreementView" owner:nil options:nil] firstObject];
   view.layer.cornerRadius = 15;
   view.clipsToBounds = YES;
    
    view.lable_agree.text =  [NSBundle le_localizedStringForKey:@"I have read and agree"];
    
    
    [view.button_ok setTitle:[NSBundle le_localizedStringForKey:@"OK"] forState:UIControlStateNormal];
    
    
    return view;
}

- (IBAction)checkBox:(UIButton *)sender {
    if (self.button_box.isSelected) {
       [self.button_box setBackgroundImage:[UIImage le_ImageNamed:@"nocheckmark"] forState:UIControlStateNormal];
     }else{
        [self.button_box setBackgroundImage:[UIImage le_ImageNamed:@"checkmark"] forState:UIControlStateNormal];
     }
    self.button_box.selected = !sender.selected;
}

- (IBAction)sureAction:(id)sender {
    
    if (self.sureCallBack) {
        self.sureCallBack(self.button_box.isSelected);
    }
}
- (IBAction)closeAlterViewAction:(id)sender {
}


@end
