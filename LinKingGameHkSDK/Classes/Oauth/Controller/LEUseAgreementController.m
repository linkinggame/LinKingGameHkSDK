//
//  LEUseAgreementController.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/13.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEUseAgreementController.h"
#import "LEUseAgreementView.h"
#import "UIImage+LEAdditions.h"
#import <WebKit/WebKit.h>
#import "LESDKConfig.h"
#import "NSBundle+LEAdditions.h"
@interface LEUseAgreementController ()
@property (strong, nonatomic)  WKWebView *webView;
@end

@implementation LEUseAgreementController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showUseAgreementView];
}
- (void)showUseAgreementView{
    LEUseAgreementView *useAgreementView = [LEUseAgreementView instanceUseAgreementView];

       [self.view insertSubview:useAgreementView atIndex:self.view.subviews.count];
       CGFloat width = 320;
        CGFloat screen_width = [UIScreen mainScreen].bounds.size.width;
        if (width > screen_width) {
            width = screen_width - 40;
        }
       useAgreementView.translatesAutoresizingMaskIntoConstraints = NO;

       [self setAlterContentView:useAgreementView];
       [self setAlterHeight:358];
       [self setAlterWidth:width];
       [self layoutConstraint];
    
    useAgreementView.sureCallBack = ^(BOOL isSelect) {
        [self dismissViewControllerAnimated:NO completion:^{
               [[NSNotificationCenter defaultCenter] postNotificationName:@"BACKUSEAGREEMENT" object:[NSNumber numberWithBool:isSelect]];
           }];
          
    };
    
    if (self.agreement) {
         [useAgreementView.button_box setBackgroundImage:[UIImage le_ImageNamed:@"checkmark"] forState:UIControlStateNormal];
         useAgreementView.button_box.selected = YES;
    }else{
         [useAgreementView.button_box setBackgroundImage:[UIImage le_ImageNamed:@"nocheckmark"] forState:UIControlStateNormal];
         useAgreementView.button_box.selected = NO;
    }
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
         WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
         self.webView = webView;
         webView.backgroundColor = [UIColor colorWithRed:226/255.0 green:225/255.0 blue:228/255.0 alpha:1];
    
         [useAgreementView.view_content addSubview:webView];
      

          self.webView.frame = CGRectMake(0, 0, 320 - 20, useAgreementView.view_content.frame.size.height);
         
      
        LESDKConfig *sdkConfig = [LESDKConfig getSDKConfig];
    if (self.type == 10) {
          NSString *str = [NSBundle le_localizedStringForKey:@"User Agreement"];
          useAgreementView.label_title.text =  str;
          NSString *privacypolicy = sdkConfig.auth_config[@"licenseagreement"];
        
           [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:privacypolicy]]];
    }else{
         NSString *str = [NSBundle le_localizedStringForKey:@"Privacy Policy"];
         useAgreementView.label_title.text =  str;
          NSString *privacypolicy = sdkConfig.auth_config[@"privacypolicy"];
        
           [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:privacypolicy]]];
    }

    
 
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
