//
//  LEMatrixController.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/14.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEMatrixController.h"
#import "LEMatrixApi.h"
#import "LEMatrixView.h"
@interface LEMatrixController ()
@property (nonatomic, strong) LEMatrixView *matrixView;
@end

@implementation LEMatrixController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self showMatrixView];
}

- (void)showMatrixView{
      LEMatrixView *matrixView = [LEMatrixView instanceMatrixViewWithViewController:self];
    self.matrixView = matrixView;
//       [self.view insertSubview:matrixView atIndex:self.view.subviews.count];
//       CGFloat width = 200;
//        CGFloat screen_width = [UIScreen mainScreen].bounds.size.width;
//        if (width > screen_width) {
//            width = screen_width - 40;
//        }
//       matrixView.translatesAutoresizingMaskIntoConstraints = NO;
//
//       [self setAlterContentView:matrixView];
//       [self setAlterHeight:150];
//       [self setAlterWidth:width];
//       [self layoutConstraint];
    
//[self.admanager showMatrixWithViewController:vc withGroup:1 withFrame:CGRectMake(80, [UIScreen mainScreen].bounds.size.height - 200, 200, 150)];
    
//    [self loadShowMatrix];
    
}

//- (void)loadShowMatrix{
//     LEMatrixView *matrixView = [LEMatrixView instanceMatrixViewWithViewController:self];
//    [LEMatrixApi fetchMatrixConfigComplete:^(NSError * _Nullable error, id  _Nullable responseObject) {
//        if ([responseObject isKindOfClass:[NSDictionary class]]) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//        
//                self.matrixView = [LEMatrixView instanceMatrixViewWithViewController:self];
//                self.matrixView.frame =CGRectMake(80, [UIScreen mainScreen].bounds.size.height - 200, 200, 160);
//                [self.matrixView setMatrixConfig:responseObject withGroup:1];
//                UIView *superView =  self.view;
//                [superView insertSubview:self.matrixView atIndex:superView.subviews.count];
//            });
//
//        }
//    }];
//}
@end
