//
//  LEAccountCenterController.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/10.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEAccountCenterController.h"
#import "LEAccountCenterView.h"
#import "LEUser.h"
#import "SDCycleScrollView.h"
#import "UIImage+LEAdditions.h"
#import "NSBundle+LEAdditions.h"
#import "LESDKConfig.h"
#import "LKLog.h"
@interface LEAccountCenterController ()<UIScrollViewDelegate,SDCycleScrollViewDelegate>{
    dispatch_source_t _timer;
}
@property (nonatomic, strong)  LEAccountCenterView *accountCenterView;
@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;
@property (nonatomic, strong) NSMutableArray *imageViewArray;
@property (nonatomic, assign) CGFloat width;
@end

@implementation LEAccountCenterController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showAccountCenterView];
}
- (void)showAccountCenterView{
    LEAccountCenterView *accountCenterView = [LEAccountCenterView instanceAccountCenterView];
    self.accountCenterView = accountCenterView;
       [self.view insertSubview:accountCenterView atIndex:self.view.subviews.count];
       CGFloat width = 320;
        CGFloat screen_width = [UIScreen mainScreen].bounds.size.width;
        if (width > screen_width) {
            width = screen_width - 40;
        }
       accountCenterView.translatesAutoresizingMaskIntoConstraints = NO;

       [self setAlterContentView:accountCenterView];
       [self setAlterHeight:321];
       [self setAlterWidth:width];
       [self layoutConstraint];
    
    accountCenterView.closeAlterViewCallBack = ^{
        [self dismissViewControllerAnimated:NO completion:nil];
    };
    accountCenterView.changeAccountCallBack = ^{
        [self changeAccountEvent];
    };
    accountCenterView.logoutCallBack = ^{
        [self logOutEvent];
    };
    
    
    [self renderView];
}


- (void)renderView{

    LEUser *user =  [LEUser getUser];

    self.accountCenterView.label_id.adjustsFontSizeToFitWidth = YES;

    NSString *useridStr = [NSString stringWithFormat:@"%@",[NSBundle le_localizedStringForKey:@"User ID"]];

    self.accountCenterView.label_id.text = [NSString stringWithFormat:@"%@: %@",useridStr,(user.userId == nil) ? @"":user.userId];


    LESDKConfig *config = [LESDKConfig getSDKConfig];
    NSDictionary *authConf_Dict = config.auth_config;
    NSArray *banners = authConf_Dict[@"account_center_banner"];

    NSMutableArray *images = [NSMutableArray array];

    for (NSDictionary *dict in banners) {
      
      NSString *urlStr = dict[@"img_url"];
      [images addObject:urlStr];
    }
    [self loadCycleRollingScrollView:images];
}

- (void)loadCycleRollingScrollView:(NSArray *)banners{
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectZero delegate:self placeholderImage:[UIImage le_ImageNamed:@"placeholder" withCls:[LEAccountCenterController class]]];

    cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
    //cycleScrollView2.titlesGroup = titles;
    cycleScrollView.currentPageDotColor = [UIColor whiteColor]; // 自定义分页控件小圆标颜色

    cycleScrollView.autoScrollTimeInterval = 4;
    [self.accountCenterView.view_content addSubview:cycleScrollView];

    self.cycleScrollView = cycleScrollView;
    //         --- 模拟加载延迟
    self.cycleScrollView.imageURLStringsGroup = banners;
    self.cycleScrollView.frame = CGRectMake(0, 0, 300, self.accountCenterView.view_content.frame.size.height);
}
#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    LKLogInfo(@"---点击了第%ld张图片", (long)index);
    if (self.selectBannerAtIndex) {
        self.selectBannerAtIndex(index);
    }
    LESDKConfig *sdkConfig = [LESDKConfig getSDKConfig];
   NSArray *account_center_banner = sdkConfig.auth_config[@"account_center_banner"];
   
   if (account_center_banner.count > 0) {
       NSDictionary *dict = account_center_banner[index];
       NSString *appId = dict[@"link_ios"];
       
       NSString *urlStr = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appId];
       NSURL *url = [NSURL URLWithString:urlStr];
       if (@available(iOS 10.0, *)){
            [[UIApplication sharedApplication]openURL:url options:@{UIApplicationOpenURLOptionsSourceApplicationKey:@YES} completionHandler:^(BOOL success) {
                if (success) {
                    LKLogInfo(@"open success");
                }else{
                    LKLogInfo(@"open fail");
                }
            }];
        }else{
            BOOL success = [[UIApplication sharedApplication]openURL:url];
            if (success) {
                LKLogInfo(@"open success");
            }else{
                LKLogInfo(@"open fail");
            }
        }
   }
}



- (void)changeAccountEvent{
    
    [self dismissViewControllerAnimated:NO completion:^{
       [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeAccount" object:nil];
    }];
    
}


- (void)logOutEvent{
    
    [LEUser removeUserInfo];
    [self dismissViewControllerAnimated:NO completion:^{
       [[NSNotificationCenter defaultCenter] postNotificationName:@"LougOut" object:nil];
    }];
}


@end
