//
//  LEFloatView.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/10.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEFloatView.h"
#import <objc/runtime.h>
#import "LEGlobalConf.h"
#import "NSObject+LEAdditions.h"
#import "UIImage+LEAdditions.h"
#import "NSBundle+LEAdditions.h"
#import "LKLog.h"
#define NavBarBottom 64
#define TabBarHeight 49
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
static char kActionHandlerTapBlockKey;
static char kActionHandlerTapGestureKey;

@interface LEFloatView (){
     BOOL mIsHalfInScreen;
     dispatch_source_t _dispatchTimer;
}

@end

@implementation LEFloatView


- (instancetype)initWithImage:(UIImage *)image
{
    if (self = [super initWithImage:image]) {
        self.userInteractionEnabled = YES;
        self.stayEdgeDistance = 5;
        self.stayAnimateTime = 0.3;
        [self initStayLocation];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self = [[LEFloatView alloc] initWithImage:[UIImage le_ImageNamed:@"float"]];
        self.userInteractionEnabled = YES;
        self.stayEdgeDistance = 5;
        self.stayAnimateTime = 0.3;
        [self initStayLocation];
    }
    return self;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 先让悬浮图片的alpha为1
    self.alpha = 1;
    // 获取手指当前的点
    UITouch * touch = [touches anyObject];
    CGPoint  curPoint = [touch locationInView:self];
    
    CGPoint prePoint = [touch previousLocationInView:self];
    
    // x方向移动的距离
    CGFloat deltaX = curPoint.x - prePoint.x;
    CGFloat deltaY = curPoint.y - prePoint.y;
    CGRect frame = self.frame;
    frame.origin.x += deltaX;
    frame.origin.y += deltaY;
    self.frame = frame;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self moveStay];
}


- (void)initStayLocation
{
    CGRect frame = self.frame;
    CGFloat stayWidth = self.image.size.width;
    CGFloat initX = kScreenWidth - self.stayEdgeDistance - stayWidth;
    CGFloat initY = (kScreenHeight - NavBarBottom - TabBarHeight) * (2.0 / 3.0) + NavBarBottom;
    frame.origin.x = initX;
    frame.origin.y = initY;
    frame.size.width = stayWidth;
    frame.size.height = self.image.size.height;
    self.frame = frame;
    mIsHalfInScreen = YES;
}


- (void)moveStay
{
    bool isLeft = [self judgeLocationIsLeft];
    switch (_stayMode) {
        case STAYMODE_LEFTANDRIGHT:
        {
             [self moveStayToMiddleInScreenBorder:isLeft];
        }
            break;
        case STAYMODE_LEFT:
        {
            [self moveToBorder:YES];
        }
            break;
        case STAYMODE_RIGHT:
        {
            [self moveToBorder:NO];
        }
            break;
        default:
            break;
    }
}


- (void)moveToBorder:(BOOL)isLeft
{
    CGRect frame = self.frame;
    CGFloat destinationX;
    if (isLeft) {
       // 横屏适配
       // destinationX =  kStatusBarHeight - 20 + self.stayEdgeDistance;
        
        destinationX = self.stayEdgeDistance;
    }
    else {
        CGFloat stayWidth = frame.size.width;
        destinationX = kScreenWidth - self.stayEdgeDistance - stayWidth;
    }
    frame.origin.x = destinationX;
    frame.origin.y = [self moveSafeLocationY];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:_stayAnimateTime animations:^{
        __strong typeof(self) pThis = weakSelf;
        pThis.frame = frame;
        LKLogInfo(@"frame:----->%@",NSStringFromCGRect(pThis.frame));
    }];
    mIsHalfInScreen = NO;
}


- (CGFloat)moveSafeLocationY
{
    CGRect frame = self.frame;
    CGFloat stayHeight = frame.size.height;

    CGFloat curY = self.frame.origin.y;
    CGFloat destinationY = frame.origin.y;

    CGFloat stayMostTopY = NavBarBottom + _stayEdgeDistance;
    if (curY <= stayMostTopY) {
        destinationY = stayMostTopY;
    }
    CGFloat stayMostBottomY = kScreenHeight - TabBarHeight - _stayEdgeDistance - stayHeight;
    if (curY >= stayMostBottomY) {
        destinationY = stayMostBottomY;
    }
    return destinationY;
}

- (bool)judgeLocationIsLeft
{
    // 手机屏幕中间位置x值
    CGFloat middleX = [UIScreen mainScreen].bounds.size.width / 2.0;
    // 当前view的x值
    CGFloat curX = self.frame.origin.x + self.bounds.size.width/2;
    if (curX <= middleX) {
        return YES;
    } else {
        return NO;
    }
}


- (void)moveTohalfInScreenWhenScrolling
{
    bool isLeft = [self judgeLocationIsLeft];
    [self moveStayToMiddleInScreenBorder:isLeft];
    mIsHalfInScreen = YES;
}

// 悬浮图片居中在屏幕边缘
- (void)moveStayToMiddleInScreenBorder:(BOOL)isLeft
{
    CGRect frame = self.frame;
    CGFloat stayWidth = frame.size.width;
    CGFloat destinationX;
    if (isLeft == YES) {
       // 横屏适配
       // destinationX =  kStatusBarHeight - 20 - stayWidth/2;
        destinationX = - stayWidth/2;
    }
    else {
        destinationX = kScreenWidth - stayWidth + stayWidth/2;
    }
    frame.origin.x = destinationX;
    frame.origin.y = [self moveSafeLocationY];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        __strong typeof(self) pThis = weakSelf;
        pThis.frame = frame;
        
    }];
    mIsHalfInScreen = YES;
    
    
    
}

- (void)setCurrentAlpha:(CGFloat)stayAlpha
{
    if (stayAlpha <= 0) {
        stayAlpha = 1;
    }
    self.alpha = stayAlpha;
}


- (void)setTapActionWithBlock:(void (^)(void))block
{
    // 为gesture添加关联是为了gesture只创建一次，objc_getAssociatedObject如果返回nil就创建一次
    UITapGestureRecognizer *gesture = objc_getAssociatedObject(self, &kActionHandlerTapGestureKey);
    
    if (!gesture)
    {
        gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleActionForTapGesture:)];
        [self addGestureRecognizer:gesture];
        objc_setAssociatedObject(self, &kActionHandlerTapGestureKey, gesture, OBJC_ASSOCIATION_RETAIN);
    }
    
    objc_setAssociatedObject(self, &kActionHandlerTapBlockKey, block, OBJC_ASSOCIATION_COPY);
}

- (void)handleActionForTapGesture:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateRecognized)
    {
        void(^action)(void) = objc_getAssociatedObject(self, &kActionHandlerTapBlockKey);
        if (action)
        {
            self.alpha = 1;
            if (mIsHalfInScreen == NO) {
                 bool isLeft = [self judgeLocationIsLeft];
                action();
                [self moveToBorder:isLeft];
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [self moveStay];
//                });

            }
            else {
                 bool isLeft = [self judgeLocationIsLeft];
                [self moveToBorder:isLeft];
                //[self moveStay];
            }
           
            [self startTime];
        }
    }
}

- (void)startTime{
  
    if (_dispatchTimer) {
        dispatch_source_cancel(_dispatchTimer);
        _dispatchTimer = nil;
    }

    // 队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    // 创建 dispatch_source
    _dispatchTimer  = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    // 设置触发时间
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC);
    // 设置下次触发事件为 DISPATCH_TIME_FOREVER
    dispatch_time_t nextTime = DISPATCH_TIME_FOREVER;
    // 设置精确度
    dispatch_time_t leeway = 0.1 * NSEC_PER_SEC;
    // 配置时间
    dispatch_source_set_timer(_dispatchTimer, startTime, nextTime, leeway);
    // 回调
     __weak typeof(self)weakSelf = self;
    dispatch_source_set_event_handler(_dispatchTimer, ^{
        __strong typeof(self)strongSelf = weakSelf;
        [strongSelf moveStay];
        dispatch_source_cancel(strongSelf->_dispatchTimer);
        strongSelf->_dispatchTimer = nil;
    });
    // 激活
    dispatch_resume(_dispatchTimer);
}

- (void)setImageWithName:(NSString *)imageName
{
    self.image = [UIImage le_ImageNamed:imageName];
}

@end
