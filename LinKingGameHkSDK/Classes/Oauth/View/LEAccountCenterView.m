//
//  LEAccountCenterView.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/10.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEAccountCenterView.h"
#import "SDCycleScrollView.h"
#import "UIImage+LEAdditions.h"
#import "NSBundle+LEAdditions.h"
#import "LELanguage.h"
#import "LEUser.h"
@interface LEAccountCenterView ()<UIScrollViewDelegate,SDCycleScrollViewDelegate>{
    dispatch_source_t _timer;
}
@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;
@property (nonatomic, strong) LEUser *user;
@property (nonatomic, strong) NSMutableArray *imageViewArray;
@property (nonatomic, assign) CGFloat width;
@end

@implementation LEAccountCenterView


+ (instancetype)instanceAccountCenterView{
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"LinKingGameHkSDKBundle" withExtension:@"bundle"]];
    LEAccountCenterView *view = [[bundle loadNibNamed:@"LEAccountCenterView" owner:nil options:nil] firstObject];
    view.layer.cornerRadius = 15;
    view.clipsToBounds = YES;
    view.scrollView.showsVerticalScrollIndicator = NO;
    view.scrollView.pagingEnabled = YES;
    view.scrollView.showsHorizontalScrollIndicator = NO;
    if ([[LELanguage shared].preferredLanguage isEqualToString:@"ar"]) {
        view.imageView_arrow.image = [UIImage le_ImageNamed:@"leftArrow"];
    }else{
        view.imageView_arrow.image = [UIImage le_ImageNamed:@"rightArrow"];
    }
    view.label_or.text = [NSBundle le_localizedStringForKey:@"OR"];
    [view.button_change setTitle:[NSBundle le_localizedStringForKey:@"Change"] forState:UIControlStateNormal];
    [view.button_logout setTitle:[NSBundle le_localizedStringForKey:@"Log out"] forState:UIControlStateNormal];
    view.lable_title.text = [NSBundle le_localizedStringForKey:@"ACCOUNT SETTING"];
    return view;
}


- (IBAction)closeAlterViewAction:(id)sender {
    
    if (self.closeAlterViewCallBack) {
        self.closeAlterViewCallBack();
    }
}


- (IBAction)changeAccount:(UIButton *)sender {
    if (self.changeAccountCallBack) {
        self.changeAccountCallBack();
    }
}

- (IBAction)logoutAction:(id)sender {
    
    if (self.logoutCallBack) {
        self.logoutCallBack();
    }
    
}


@end
