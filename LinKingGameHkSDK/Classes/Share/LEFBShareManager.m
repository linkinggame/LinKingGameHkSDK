//
//  LEFBShareManager.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/19.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEFBShareManager.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "LESDKConfig.h"
#import "NSObject+LEAdditions.h"
#import "LKLog.h"

@interface LEFBShareManager ()<FBSDKSharingDelegate>

@property (nonatomic, copy)void (^shareComplete)(NSDictionary <NSString *, id> * _Nullable results,BOOL isCancel,NSError  * _Nullable error);

@end

static LEFBShareManager *_instance = nil;

@implementation LEFBShareManager


+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LEFBShareManager alloc] init];
    });
    return _instance;
}

- (void)shareToFacebook:(UIViewController *)viewController omplete:(void(^)(NSDictionary <NSString *, id> * _Nullable results,BOOL isCancel,NSError  * _Nullable error))complete{
    LESDKConfig *config = [LESDKConfig getSDKConfig];
    NSNumber *isStart = config.share_info[@"switch"];
    if (isStart.exceptNull != nil) {
        BOOL start = [isStart boolValue];
        if (start == false) {
            return;
        }
        NSString * title = config.share_info[@"title"];
        NSString * content_url = config.share_info[@"content_url"];
        
        [self shareLink:content_url quote:title hashtag:nil viewController:viewController complete:complete];
    }
}





/// 分享链接 + 引文 + 标签
/// @param linkUrl 链接  https://developers.facebook.com
/// @param quote 引文
/// @param hashtag 标签
/// @param viewController viewController description
- (void)shareLink:(NSString * _Nullable)linkUrl quote:(NSString *_Nullable)quote hashtag:(NSString *_Nullable)hashtag viewController:(UIViewController *)viewController complete:(void(^)(NSDictionary <NSString *, id> * _Nullable results,BOOL isCancel,NSError  * _Nullable error))complete{
    
    self.shareComplete = complete;
    
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
       content.contentURL = [NSURL URLWithString:linkUrl];
       if (quote != nil) {
           content.quote = quote;
       }
       if (hashtag != nil) {
           // #MadeWithHackbook
           content.hashtag = [FBSDKHashtag hashtagWithString:[NSString stringWithFormat:@"#%@",hashtag]];
       }
       FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
    
    if ([dialog canShow]) {
//        dialog.fromViewController = viewController;
//        dialog.shareContent = content;
//        dialog.delegate = self;
//        dialog.mode = FBSDKShareDialogModeShareSheet;
//        [dialog show];
        [FBSDKShareDialog showFromViewController:viewController withContent:content delegate:self];
    }else{
        LKLogInfo(@"===不可以被分享===");
    }
      
    
 
}
///  分享单张图片
/// @param imageURL 单张图片URL
/// @param viewController viewController description
- (void)shareImageURL:(NSURL *)imageURL viewController:(UIViewController *)viewController complete:(void(^)(NSDictionary <NSString *, id> * _Nullable results,BOOL isCancel,NSError  * _Nullable error))complete{
     self.shareComplete = complete;
    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
    photo.imageURL = imageURL;
    photo.userGenerated = YES;
    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
    content.photos = @[photo];

    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
    dialog.fromViewController = viewController;
    dialog.shareContent = content;
    dialog.delegate = self;
    dialog.mode = FBSDKShareDialogModeShareSheet;
    [dialog show];
    
}
/// 分享多张图片
/// @param imageURLs imageURLs description
/// @param viewController viewController description
- (void)shareImageURLs:(NSArray<NSURL *>* _Nullable)imageURLs viewController:(UIViewController *)viewController complete:(void(^)(NSDictionary <NSString *, id> * _Nullable results,BOOL isCancel,NSError  * _Nullable error))complete{
    self.shareComplete = complete;
    NSMutableArray *photos = [NSMutableArray array];
    for (NSURL *imageURL in imageURLs) {
         FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
         photo.imageURL = imageURL;
         photo.userGenerated = YES;
        [photos addObject:photo];
    }
    
     FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
     content.photos = photos;
    
     FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
     dialog.fromViewController = viewController;
     dialog.shareContent = content;
     dialog.mode = FBSDKShareDialogModeAutomatic;
    dialog.delegate = self;
     [dialog show];
}

/// 分享视频
/// @param videoURL videoURL description
/// @param viewController viewController description
- (void)shareVideoURL:(NSURL * _Nullable)videoURL viewController:(UIViewController *)viewController complete:(void(^)(NSDictionary <NSString *, id> * _Nullable results,BOOL isCancel,NSError  * _Nullable error))complete{
    self.shareComplete = complete;
      FBSDKShareVideo *video = [[FBSDKShareVideo alloc] init];
    
      video.videoURL = videoURL;

      FBSDKShareVideoContent *content = [[FBSDKShareVideoContent alloc] init];
      content.video = video;

     FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
     dialog.fromViewController = viewController;
     dialog.shareContent = content;
     dialog.delegate = self;
     dialog.mode = FBSDKShareDialogModeAutomatic;
     [dialog show];
}

/// 分享多媒体
/// @param imageURL 图片资源
/// @param videoURL 视频资源
/// @param viewController viewController description
- (void)shareMediaImageURL:(NSURL * _Nullable)imageURL videoURL:(NSURL * _Nullable)videoURL viewController:(UIViewController *)viewController complete:(void(^)(NSDictionary <NSString *, id> * _Nullable results,BOOL isCancel,NSError  * _Nullable error))complete{
     self.shareComplete = complete;
    FBSDKSharePhoto *photo = [FBSDKSharePhoto photoWithImageURL:imageURL userGenerated:YES];
    FBSDKShareVideo *video = [FBSDKShareVideo videoWithVideoURL:videoURL];
    FBSDKShareMediaContent *content = [FBSDKShareMediaContent new];
    content.media = @[photo, video];
    
    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
    dialog.fromViewController = viewController;
    dialog.shareContent = content;
    dialog.delegate = self;
    dialog.mode = FBSDKShareDialogModeAutomatic;
    [dialog show];
}

#pragma mark - FBSDKSharingDelegate
/**
  Sent to the delegate when the share completes without error or cancellation.
 @param sharer The FBSDKSharing that completed.
 @param results The results from the sharer.  This may be nil or empty.
 */
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary<NSString *, id> *)results{
    
    LKLogInfo(@"%s",__FUNCTION__);
    
    if (self.shareComplete) {
        self.shareComplete(results, NO, nil);
    }
}

/**
  Sent to the delegate when the sharer encounters an error.
 @param sharer The FBSDKSharing that completed.
 @param error The error.
 */
- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error{
    LKLogInfo(@"%s",__FUNCTION__);
    LKLogError(@"error:%@",error);
    if (self.shareComplete) {
        self.shareComplete(nil, NO, error);
    }
}

/**
  Sent to the delegate when the sharer is cancelled.
 @param sharer The FBSDKSharing that completed.
 */
- (void)sharerDidCancel:(id<FBSDKSharing>)sharer{
    LKLogInfo(@"%s",__FUNCTION__);
    if (self.shareComplete) {
        self.shareComplete(nil, YES, nil);
    }
}


- (void)openAppStoreApplication{
    
    LESDKConfig *sdkConfig = [LESDKConfig getSDKConfig];
    NSString *appId_ios = sdkConfig.share_info[@"appId_ios"];
    //@"1477780172";
    if (appId_ios.exceptNull != nil) {
        NSString *urlStr = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appId_ios];
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
             BOOL success = [[UIApplication sharedApplication] openURL:url];
             if (success) {
                 LKLogInfo(@"open success");
             }else{
                 LKLogInfo(@"open fail");
             }
         }
    }
}


- (void)jumpYouTuBe{
    LESDKConfig *sdkConfig = [LESDKConfig getSDKConfig];
    NSString *channelname =  sdkConfig.share_info[@"ytb_page_link"];
    // https://www.youtube.com/channel/UCTwmvv2aEI611RRwdZwdmgA/featured
    //NSString *channelname = @"UCTwmvv2aEI611RRwdZwdmgA";
    if (channelname.exceptNull != nil) {
        NSString *appURL = [NSString stringWithFormat:@"youtube://www.youtube.com/channel/%@",channelname];
        NSString *webURL = [NSString stringWithFormat:@"https://www.youtube.com/channel/%@",channelname];

       // 直接跳转到app里面指定的用户主页。
       if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:appURL]]) {
           
           if (@available(iOS 10.0, *)){
               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appURL] options:@{UIApplicationOpenURLOptionsSourceApplicationKey:@YES} completionHandler:^(BOOL success) {
                                  
               }];
           }else{
               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appURL]];
           }

       } else {
           // 用浏览器打开指定的用户主页网页地址。
           if (@available(iOS 10.0, *)){
               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:webURL] options:@{UIApplicationOpenURLOptionsSourceApplicationKey:@YES} completionHandler:^(BOOL success) {
                                  
               }];
           }else{
               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:webURL]];
           }
       }
        
    }

}


- (void)jumpDiscord{
    // https://discord.gg/bETQBsg
    LESDKConfig *sdkConfig = [LESDKConfig getSDKConfig];
    NSString *discord_page_link =  sdkConfig.share_info[@"discord_page_link"];
    if(discord_page_link.exceptNull != nil){
        NSString *appURL =discord_page_link;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appURL]];
    }
   
}

- (void)test{
    
    // https://www.youtube.com/channel/UCTwmvv2aEI611RRwdZwdmgA/featured
    
    // http://www.youtube.com/user/klauskkpm
//    NSString *username = @"klauskkpm";
//
//    NSString *channelname = @"UCTwmvv2aEI611RRwdZwdmgA";
//
//    NSString *appURL = [NSString stringWithFormat:@"youtube://www.youtube.com/user/%@",username];
//
//    NSString *webURL = [NSString stringWithFormat:@"https://www.youtube.com/channel/%@",channelname];

//    NSString *appURL = [NSString stringWithFormat:@"youtube://www.youtube.com"];
    
//    NSString *webURL = [NSString stringWithFormat:@"https://www.youtube.com/user/%@",user];
    
   // 直接跳转到app里面指定的用户主页。
//   if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:appURL]]) {
//       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appURL]];
//   } else {
//       // 用浏览器打开指定的用户主页网页地址。
//       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:webURL]];
//   }
    
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:webURL]];
}
- (void)showFacebookFansPage{
    // 查询 facebookId http://cn.piliapp.com/facebook/id/
    // 小小勇者 https://www.facebook.com/Littlewarriors2020/
    LESDKConfig *config = [LESDKConfig getSDKConfig];
    NSNumber *isStart = config.share_info[@"switch"];
    if (isStart.exceptNull != nil) {
        BOOL start = [isStart boolValue];
        if (start == false) {
            return;
        }
        NSString *facebookId = config.share_info[@"fb_page_link"];
        if (facebookId.exceptNull != nil) {
               //NSURL *facebookURL = [NSURL URLWithString:@"fb://profile/107833580931096"];
                NSURL *facebookURL = [NSURL URLWithString:@"fb://"];
               // 直接跳转到app里面指定的用户主页。
               if ([[UIApplication sharedApplication] canOpenURL:facebookURL]) {
                    NSString *url = [NSString stringWithFormat:@"fb://profile/%@",facebookId];
                   if (@available(iOS 10.0, *)){
                       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{UIApplicationOpenURLOptionsSourceApplicationKey:@YES} completionHandler:^(BOOL success) {
                                              
                       }];
                   }else{
                       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                   }

               } else {
                   // 用浏览器打开指定的用户主页网页地址。
                   NSString *url = [NSString stringWithFormat:@"https://www.facebook.com/%@",facebookId];
                   if (@available(iOS 10.0, *)){
                       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{UIApplicationOpenURLOptionsSourceApplicationKey:@YES} completionHandler:^(BOOL success) {
                                              
                       }];
                   }else{
                       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                   }
                   
               }
        }
 
    }

}
@end
