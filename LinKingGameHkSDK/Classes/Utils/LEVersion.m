//
//  LEVersion.m
//  LinKingEnSDK
//https://itunes.apple.com/lookup?bundleId=com.tencent.xin
//http://itunes.apple.com/lookup?id=414478124
//  Created by leon on 2020/9/18.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEVersion.h"
#import <StoreKit/StoreKit.h>
#import "LESDKConfig.h"
#import "LKLog.h"
#define REQUEST_SUCCEED 200
#define CURRENT_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define BUNDLE_IDENTIFIER [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]
#define SYSTEM_VERSION_8_OR_ABOVE (([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)? (YES):(NO))
#define TRACK_ID @"TRACKID"
#define APP_LAST_VERSION @"APPLastVersion"
#define APP_RELEASE_NOTES @"APPReleaseNotes"
#define APP_TRACK_VIEW_URL @"APPTRACKVIEWURL"
#define SPECIAL_MODE_CHECK_URL @"https://itunes.apple.com/lookup?country=%@&bundleId=%@"
#define NORMAL_MODE_CHECK_URL @"https://itunes.apple.com/lookup?bundleId=%@"
#define SKIP_CURRENT_VERSION @"SKIPCURRENTVERSION"
#define SKIP_VERSION @"SKIPVERSION"

@interface LEVersion ()<SKStoreProductViewControllerDelegate>
@property (nonatomic, copy) NSString *nextTimeTitle;
@property (nonatomic, copy) NSString *confimTitle;
@property (nonatomic, copy) NSString *alertTitle;
@property (nonatomic, copy) NSString *skipVersionTitle;
@end

static LEVersion *_instance = nil;
@implementation LEVersion

+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LEVersion alloc] init];
        _instance.nextTimeTitle = @"下次提示";
        _instance.confimTitle = @"前往更新";
        _instance.alertTitle = @"发现新版本";
        _instance.skipVersionTitle = nil;
    });
    return _instance;
}
- (void)checkVersion {
    
    [self checkVersionWithAlertTitle:self.alertTitle nextTimeTitle:self.nextTimeTitle confimTitle:self.confimTitle];
}

- (void)checkVersionWithAlertTitle:(NSString *)alertTitle nextTimeTitle:(NSString *)nextTimeTitle confimTitle:(NSString *)confimTitle {
    
    [self checkVersionWithAlertTitle:alertTitle nextTimeTitle:nextTimeTitle confimTitle:confimTitle skipVersionTitle:nil];
}

- (void)checkVersionWithAlertTitle:(NSString *)alertTitle nextTimeTitle:(NSString *)nextTimeTitle confimTitle:(NSString *)confimTitle skipVersionTitle:(NSString *)skipVersionTitle {
    
    self.alertTitle = alertTitle;
    self.nextTimeTitle = nextTimeTitle;
    self.confimTitle = confimTitle;
    self.skipVersionTitle = skipVersionTitle;
    [_instance getInfoFromAppStore];
}

- (void)getInfoFromAppStore {
    
    NSURL *requestURL;
    if (self.countryAbbreviation == nil) {
        requestURL = [NSURL URLWithString:[NSString stringWithFormat:NORMAL_MODE_CHECK_URL,BUNDLE_IDENTIFIER]];
    } else {
        requestURL = [NSURL URLWithString:[NSString stringWithFormat:SPECIAL_MODE_CHECK_URL,self.countryAbbreviation,BUNDLE_IDENTIFIER]];
    }
    LKLogInfo(@"___________> %@",requestURL);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        
        if (urlResponse.statusCode == REQUEST_SUCCEED) {
            NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            LKLogInfo(@"responseDic ===%@",response);

            LKLogInfo(@"responseDic_____>> %@",responseDic);
            
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            if ([responseDic[@"resultCount"] intValue] == 1) {
                
                NSArray *results = responseDic[@"results"];
                NSDictionary *resultDic = [results firstObject];
                [userDefault setObject:resultDic[@"version"] forKey:APP_LAST_VERSION];
                [userDefault setObject:resultDic[@"releaseNotes"] forKey:APP_RELEASE_NOTES];
                [userDefault setObject:resultDic[@"trackViewUrl"] forKey:APP_TRACK_VIEW_URL];
                [userDefault setObject:[resultDic[@"trackId"] stringValue] forKey:TRACK_ID];
                if ([resultDic[@"version"] isEqualToString:CURRENT_VERSION] || ![[userDefault objectForKey:SKIP_VERSION] isEqualToString:resultDic[@"version"]]) {
                    [userDefault setBool:NO forKey:SKIP_CURRENT_VERSION];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (![[userDefault objectForKey:SKIP_CURRENT_VERSION] boolValue]) {
                        NSArray *AppStoreVersionArray = [resultDic[@"version"] componentsSeparatedByString:@"."];
                        NSArray *localVersionArray = [CURRENT_VERSION componentsSeparatedByString:@"."];
                        for (int index = 0; index < AppStoreVersionArray.count; index ++) {
                            if ([AppStoreVersionArray[index] intValue] > [localVersionArray[index] intValue]) {
                                [self compareWithCurrentVersion];
                                break;
                            }
                        }
                    }
                });
            }else{
                LESDKConfig *sdkConfig = [LESDKConfig getSDKConfig];
                BOOL flag =  [sdkConfig.updateGame[@"cancelFlag"] boolValue];
                NSString *serviceVersion = [NSString stringWithFormat:@"%@",sdkConfig.updateGame[@"apkVer"]];
                if (serviceVersion.length < 5) {
                    return;
                }
                NSString *updateMsg = [NSString stringWithFormat:@"%@",sdkConfig.updateGame[@"updateMsg"]];
                NSString *apkUrl =  [NSString stringWithFormat:@"%@",sdkConfig.updateGame[@"apkUrl"]];
                NSString *trackid =  [NSString stringWithFormat:@"%@",sdkConfig.updateGame[@"trackid"]];
                if (serviceVersion == nil || updateMsg == nil || apkUrl == nil || trackid == nil) {
                    return;
                }
                [userDefault setObject:serviceVersion forKey:APP_LAST_VERSION];
                [userDefault setObject:updateMsg forKey:APP_RELEASE_NOTES];
                [userDefault setObject:apkUrl forKey:APP_TRACK_VIEW_URL];
                if (trackid != nil) {
                    [userDefault setObject:trackid forKey:TRACK_ID];
                }
                
                if ([serviceVersion isEqualToString:CURRENT_VERSION] || ![[userDefault objectForKey:SKIP_VERSION] isEqualToString:serviceVersion]) {
                    [userDefault setBool:NO forKey:SKIP_CURRENT_VERSION];
                }

                if (flag == true) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (![[userDefault objectForKey:SKIP_CURRENT_VERSION] boolValue]) {
                            NSArray *ServiceVersionArray = [serviceVersion componentsSeparatedByString:@"."];
                            NSArray *localVersionArray = [CURRENT_VERSION componentsSeparatedByString:@"."];
                            LKLogInfo(@"local-version:%@",CURRENT_VERSION);
                            LKLogInfo(@"server-version:%@",ServiceVersionArray);
                            if (ServiceVersionArray.count == localVersionArray.count) {
                                for (int index = 0; index < ServiceVersionArray.count; index ++) {
                                    if ([ServiceVersionArray[index] intValue] > [localVersionArray[index] intValue]) {
                                        [self compareWithCurrentVersion];
                                        break;
                                    }
                                }
                            }
                        }
                    });
                }
            }
            //LKLogInfo(@"%@   %@",[userDefault objectForKey:APP_LAST_VERSION],[userDefault objectForKey:APP_RELEASE_NOTES]);
        }
    }];
    [dataTask resume];
}

- (void)compareWithCurrentVersion {
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *updateMessage = [userDefault objectForKey:APP_RELEASE_NOTES];
    if (![[userDefault objectForKey:APP_LAST_VERSION] isEqualToString:CURRENT_VERSION]) {
        if (SYSTEM_VERSION_8_OR_ABOVE) {
            __weak typeof(self) weakSelf = self;
            UIAlertController *alertControler = [UIAlertController alertControllerWithTitle:self.alertTitle message:updateMessage preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:self.nextTimeTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//            }];
            UIAlertAction *confimAction = [UIAlertAction actionWithTitle:self.confimTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [weakSelf openAPPStore];
            }];
            [alertControler addAction:confimAction];
//            [alertControler addAction:cancelAction];
            if (self.skipVersionTitle != nil) {
                UIAlertAction *skipVersionAction = [UIAlertAction actionWithTitle:self.skipVersionTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                    [userDefault setBool:YES forKey:SKIP_CURRENT_VERSION];
                    [userDefault setObject:[userDefault objectForKey:APP_LAST_VERSION] forKey:SKIP_VERSION];
                }];
                [alertControler addAction:skipVersionAction];
            }
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertControler animated:YES completion:^{
                
            }];
        } else {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:self.alertTitle message:updateMessage delegate:self cancelButtonTitle:self.nextTimeTitle otherButtonTitles:self.confimTitle, self.skipVersionTitle,nil];
            [alertView show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        
    } else {
        
        [self openAPPStore];
    }
}

- (void)openAPPStore {
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (!self.openAPPStoreInsideAPP) {
        
        LKLogInfo(@"——-------> %@",[userDefault objectForKey:APP_TRACK_VIEW_URL]);
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[userDefault objectForKey:APP_TRACK_VIEW_URL]]];
    } else {
        SKStoreProductViewController *storeViewController = [[SKStoreProductViewController alloc] init];
        storeViewController.delegate = self;
        
        NSDictionary *parametersDic = @{SKStoreProductParameterITunesItemIdentifier:[userDefault objectForKey:TRACK_ID]};
        [storeViewController loadProductWithParameters:parametersDic completionBlock:^(BOOL result, NSError * _Nullable error) {
            
            if (result) {
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:storeViewController animated:YES completion:^{
                    
                }];
            }
        }];
    }
    
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    
    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}


@end
