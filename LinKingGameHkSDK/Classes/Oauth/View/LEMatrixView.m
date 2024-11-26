//
//  LEMatrixView.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/13.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEMatrixView.h"
#import "SDCycleScrollView.h"
#import "LESDKConfig.h"
#import "NSBundle+LEAdditions.h"
#import "UIImage+LEAdditions.h"
#import <StoreKit/StoreKit.h>
#import "LELanguage.h"
#import "LKLog.h"

@interface LEMatrixView ()
<SDCycleScrollViewDelegate,SKStoreProductViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *view_content;
@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;
@property (nonatomic, strong) NSMutableArray *items;
//@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, assign) NSInteger index;
@property (weak, nonatomic) IBOutlet UIButton *button_playGame;

@property (nonatomic, strong) NSDictionary *responseObj;
@property (nonatomic, strong)  SKStoreProductViewController *storeProductViewContorller;
@end

@implementation LEMatrixView

+ (instancetype)instanceMatrixViewWithViewController:(UIViewController *)viewController{
    
    // NSBundle *bundle  = [NSBundle bundleForClass:[self class]];
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"LinKingGameHkSDKBundle" withExtension:@"bundle"]];
    LKLogInfo(@"bundle----->%@",bundle);
    LEMatrixView *view = [bundle loadNibNamed:@"LEMatrixView" owner:self options:nil].firstObject;
    view.layer.cornerRadius = 10;
    view.items = [NSMutableArray array];
    view.layer.masksToBounds = YES;
    if ([[LELanguage shared].preferredLanguage isEqualToString:@"ar"]) {
         [view.button_playGame setTitleEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    }
    [view.button_playGame setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
    view.viewController = viewController;
    return view;
}
- (IBAction)startGameAction:(id)sender {
    
     [self loadAppstore:self.index];
    
}


- (void)setMatrixConfig:(NSDictionary *)matrixConfig withGroup:(NSInteger)group{

    NSDictionary *responseObj = matrixConfig;
    self.responseObj = responseObj;
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectZero delegate:self placeholderImage:[UIImage le_ImageNamed:@"placeholder" withCls:[LEMatrixView class]]];

       cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;

       cycleScrollView.autoScrollTimeInterval = 5;
       [self.view_content addSubview:cycleScrollView];
    
       self.cycleScrollView = cycleScrollView;

        NSArray *list = responseObj[@"index"];
    
            NSMutableArray *arrayGroup = [NSMutableArray arrayWithCapacity:0];
             for (NSDictionary* dict in list) {
                 NSString *group = dict[@"group"];
                 if ([group isEqualToString:group]) {
                     [arrayGroup addObject:dict];
                 }
             }

        NSMutableArray *banners = [NSMutableArray  array];
        for (NSDictionary *items_dic in arrayGroup) {
            [self.items addObject:items_dic];
            NSString *gifPath = items_dic[@"gif"];
            [banners addObject:gifPath];
      
        }
     cycleScrollView.showPageControl = NO;
     NSDictionary *item = self.items[0];

    [self setUIwithItem:matrixConfig withGroup:item];
    
    NSString *application_appid = item[@"ios_app_id"]; // 应用id
    self.cycleScrollView.imageURLStringsGroup = banners;
    
    // 展示打点
    [self adPoint:application_appid event:@"show"];
    
}
- (void)layoutSubviews{
    [super layoutSubviews];

    self.cycleScrollView.frame = CGRectMake(0, 0, self.view_content.frame.size.width, self.view_content.frame.size.height);

}

#pragma mark - SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    LKLogInfo(@"---点击了第%ld张图片", (long)index);
    [self loadAppstore:index];
}

- (void)loadAppstore:(NSInteger)index{
    NSDictionary *item = self.items[index];
    LKLogInfo(@"---点击了第%ld张图片", (long)index);
    NSString *appid = item[@"app_id"];
    
     NSString *ios_app_id = item[@"ios_app_id"];
    // 点击打点
    [self adPoint:ios_app_id event:@"click"];

    if (self.didSelectItemAtIndex) {
        self.didSelectItemAtIndex(appid);
    }
    
    
    self.storeProductViewContorller = [[SKStoreProductViewController alloc] init];
           self.storeProductViewContorller.delegate = self;
          //加载App Store视图展示
          [ self.storeProductViewContorller loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier:appid} completionBlock:^(BOOL result, NSError *error) {
                
               if(error) {
                   LKLogInfo(@"error:%@",error);
               } else {
                   
                   if (self.viewController.presentedViewController == nil) {
                       //模态弹出appstore
                         [self.viewController presentViewController:self.storeProductViewContorller animated:YES completion:^{
                              
                         }];
                   }

               }

          }];
    

}

- (void)adPoint:(NSString *)appid event:(NSString *)event{
    // 打点
    
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

/** 图片滚动回调 */
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index{
    self.index = index;
    NSDictionary *item = self.items[index];
    [self setUIwithItem:self.responseObj withGroup:item];
}



- (void)setUIwithItem:(NSDictionary *)item withGroup:(NSDictionary*)group{
    
    
    
       NSString *gameName = group[@"name"];
       NSNumber *font = item[@"font"];
//       NSArray *t_colors = (NSArray*)item[@"textcolor"];
//       CGFloat t_r = [t_colors[0] floatValue];
//       CGFloat t_g = [t_colors[1] floatValue];
//       CGFloat t_b = [t_colors[2] floatValue];
//       CGFloat t_a = [t_colors[3] floatValue];
    
         NSString *textcolor = item[@"textcolor"];
         NSString *bodercolor = item[@"bodercolor"];
         NSString *bg_color = item[@"bg_color"];
//       NSArray *b_colors = (NSArray*)item[@"bodercolor"];
//       CGFloat b_r = [b_colors[0] floatValue];
//       CGFloat b_g = [b_colors[1] floatValue];
//       CGFloat b_b = [b_colors[2] floatValue];
//       CGFloat b_a = [b_colors[3] floatValue];
    
     
    self.button_playGame.titleLabel.font = [UIFont systemFontOfSize:[font floatValue]];
    
    
    self.layer.cornerRadius = [item[@"bgradius"] floatValue];
    self.layer.masksToBounds = YES;
    
    self.view_content.layer.borderWidth = [item[@"borderWidth"] floatValue];
    self.view_content.layer.borderColor =  [self colorWithHexString:bodercolor alpha:1].CGColor;
    //[UIColor colorWithRed:b_r/255.0 green:b_g/255.0 blue:b_b/255.0 alpha:b_a].CGColor;
    
    self.view_content.layer.cornerRadius = [item[@"bdradius"] floatValue];
    self.view_content.layer.masksToBounds = YES;
    

    // [UIColor colorWithRed:t_r/255.0 green:t_g/255.0 blue:t_b/255.0 alpha:t_a]
    [self.button_playGame setTitleColor:[self colorWithHexString:textcolor alpha:1] forState:UIControlStateNormal];
    [self.button_playGame setTitle:gameName forState:UIControlStateNormal];
    self.button_playGame.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    
    self.backgroundColor = [self colorWithHexString:bg_color alpha:1];
    //[UIColor redColor];
    
//    NSArray *frames = ios_item[@"frame"];
//
//   self.frame = CGRectMake([frames[0] floatValue], [frames[1] floatValue], [frames[2] floatValue], [frames[3] floatValue]);

}

- (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha {
    hexString = [hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    hexString = [hexString stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    NSRegularExpression *RegEx = [NSRegularExpression regularExpressionWithPattern:@"^[a-fA-F|0-9]{6}$" options:0 error:nil];
    NSUInteger match = [RegEx numberOfMatchesInString:hexString options:NSMatchingReportCompletion range:NSMakeRange(0, hexString.length)];

    if (match == 0) {return [UIColor clearColor];}

    NSString *rString = [hexString substringWithRange:NSMakeRange(0, 2)];
    NSString *gString = [hexString substringWithRange:NSMakeRange(2, 2)];
    NSString *bString = [hexString substringWithRange:NSMakeRange(4, 2)];
    unsigned int r, g, b;
    BOOL rValue = [[NSScanner scannerWithString:rString] scanHexInt:&r];
    BOOL gValue = [[NSScanner scannerWithString:gString] scanHexInt:&g];
    BOOL bValue = [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    if (rValue && gValue && bValue) {
        return [UIColor colorWithRed:((float)r/255.0f) green:((float)g/255.0f) blue:((float)b/255.0f) alpha:alpha];
    } else {
        return [UIColor clearColor];
    }
}

@end
