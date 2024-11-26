//
//  LEBaseViewController.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/10.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEBaseViewController.h"
#import "MMMaterialDesignSpinner.h"
#import "LEGlobalConf.h"
#import "LKLog.h"
@interface LEBaseViewController (){
    dispatch_source_t timer;
}
@property (nonatomic, strong)  NSArray *constraints;
@property (nonatomic) UIDeviceOrientation orientation;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) CGFloat width_cache;
@property (nonatomic, assign) CGFloat height_cache;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) MMMaterialDesignSpinner *spinnerView;
@property (nonatomic, strong) UIView *maskView;
@end

@implementation LEBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 13.0, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    } else {
        // Fallback on earlier versions
    }
    self.view.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.6];
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationDidChange)
                             name:UIDeviceOrientationDidChangeNotification
                                                       object:nil];
    
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    //
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
        if (self.orientation == UIDeviceOrientationUnknown) {
            self.orientation = (UIDeviceOrientation)orientation;
        }

}
- (UIView *)maskView{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,kScreen_LE_Width, kScreen_LE_Height)];
        _maskView.backgroundColor =[UIColor colorWithWhite:0.2 alpha:0.6];
        self.spinnerView = [[MMMaterialDesignSpinner alloc] init];
        self.spinnerView.center = CGPointMake(kScreen_LE_Width * 0.5, kScreen_LE_Height * 0.5);
        self.spinnerView.bounds = CGRectMake(0, 0, 60, 60);
        self.spinnerView.lineWidth = 4.0f;
        self.spinnerView.tintColor = [UIColor colorWithRed:220/255.0 green:92/255.0 blue:89/255.0 alpha:1];
        [_maskView addSubview:self.spinnerView];
    }
    return _maskView;
}


- (void)showMaskView{
    [self.view addSubview:self.maskView];
    [self startTime];
    [self.spinnerView startAnimating];
}

- (void)hiddenMaskView{
    [self.maskView removeFromSuperview];
    _maskView = nil;
    [self stopTime];
    [self.spinnerView stopAnimating];
    _spinnerView = nil;
    
}

////#pragma mark - 控制屏幕旋转方法
////是否自动旋转,返回YES可以自动旋转,返回NO禁止旋转
//- (BOOL)shouldAutorotate{
//  return NO;
//}
//
////返回支持的方向
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
//  return UIInterfaceOrientationMaskPortrait;
//}
//
////由模态推出的视图控制器 优先支持的屏幕方向
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
//  return UIInterfaceOrientationPortrait;
//}
- (void)startTime{
    
   __block int second = 0;
     timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        if (second >= 60) {
            dispatch_cancel(self->timer);
            self->timer = nil;
            [self hiddenMaskView];
        }
        second += 1;
        
    });
    dispatch_resume(timer);
}

- (void)stopTime{
    
    if (timer != nil) {
        dispatch_cancel(timer);
        timer = nil;
    }
}

- (NSError *)responserErrorMsg:(NSString *)msg code:(int)code{
    NSString *domain = @"com.linking.sdk.ErrorDomain";
        NSString *errorDesc = NSLocalizedString(msg, @"");
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : errorDesc };
        NSError *error = [NSError errorWithDomain:domain code:code userInfo:userInfo];
    return error;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    //[self dismissViewControllerAnimated:NO completion:nil];
}


- (void)setAlterWidth:(CGFloat)width{
    self.width = width;
    self.width_cache = width;
    [self layoutConstraint];
    [self.view layoutIfNeeded];
}

- (void)setAlterHeight:(CGFloat)height{
    self.height = height;
    self.height_cache = height;
    [self layoutConstraint];
    [self.view layoutIfNeeded];

}


- (void)setAlterContentView:(UIView *)contentView{
    self.contentView = contentView;
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
     [self layoutConstraint];
}

- (BOOL)onDeviceOrientationDidChange{
   
   //获取当前设备Device
   UIDevice *device = [UIDevice currentDevice] ;
   //识别当前设备的旋转方向
    
    [self.view layoutIfNeeded];
 
   switch (device.orientation) {
       case UIDeviceOrientationFaceUp:
         //  LKLogInfo(@"屏幕幕朝上平躺");
           break;

       case UIDeviceOrientationFaceDown:
         //  LKLogInfo(@"屏幕朝下平躺");
           
           break;

       case UIDeviceOrientationUnknown:
           //系统当前无法识别设备朝向，可能是倾斜
         //  LKLogInfo(@"未知方向");
           break;

       case UIDeviceOrientationLandscapeLeft:
          // LKLogInfo(@"屏幕向左橫置");
         
           break;

       case UIDeviceOrientationLandscapeRight:
        //   LKLogInfo(@"屏幕向右橫置");
           
           break;

       case UIDeviceOrientationPortrait:
         // LKLogInfo(@"屏幕直立");
           
           break;

       case UIDeviceOrientationPortraitUpsideDown:
          // LKLogInfo(@"屏幕直立，上下顛倒");
           
           break;

       default:
         // LKLogInfo(@"无法识别");
           break;
   }
    
      self.orientation = device.orientation;
      if (self.deviceOrientationHander) {
          self.deviceOrientationHander(device.orientation);
      }
     [self layoutConstraint];
    
   return YES;
}


- (void)layoutConstraint{
    
    if (self.contentView == nil) {
        return;
    }
    
    
    if(self.orientation == UIDeviceOrientationFaceUp || self.orientation == UIDeviceOrientationFaceDown || self.orientation == UIDeviceOrientationPortraitUpsideDown){
        
       // LKLogInfo(@"======不做处理========");
        return;
    }
    self.width = self.width_cache;
    self.height = self.height_cache;
    [self.view removeConstraints:self.constraints];
 
     NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    
      NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
      
    NSLayoutConstraint *constraint3 = nil;
    NSLayoutConstraint *constraint4 = nil;
    NSLayoutConstraint *constraint5  = nil;
 
    CGFloat constant = 20;
    if (self.width + 20 + 20 >= [UIScreen mainScreen].bounds.size.width) {
        constant = 20;
    }
    if (self.width >= 20) {
        if ([UIScreen mainScreen].bounds.size.width > self.width + 20 + 20) {
            constant = 20 +  ([UIScreen mainScreen].bounds.size.width - (self.width + 20 + 20))  * 0.5;
        }
    }else{
        constant = 20;
    }

    constraint3 = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:constant];
      
    constraint4 = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-constant];
    
    constraint5 = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:self.height];
    
    self.constraints = [NSArray arrayWithObjects:constraint1, constraint2, constraint3, constraint4,constraint5 ,nil];
    
    [self.view addConstraints:self.constraints];
    
    [self.view setNeedsUpdateConstraints];
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
