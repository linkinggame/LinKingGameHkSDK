//
//  LELanguage.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/14.
//  Copyright © 2020 "". All rights reserved.
//

#import "LELanguage.h"
#import "NSBundle+LEAdditions.h"
static LELanguage *_instance = nil;
@implementation LELanguage
+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LELanguage alloc] init];
        _instance.preferredLanguage = nil;
    });
    return _instance;
}



- (void)setPreferredLanguage:(NSString *)preferredLanguage {
    _preferredLanguage = preferredLanguage;
    
    if (!_preferredLanguage || !_preferredLanguage.length) {
        _preferredLanguage = [NSLocale preferredLanguages].firstObject;
    }
    if ([_preferredLanguage rangeOfString:@"zh-Hans"].location != NSNotFound) {
        _preferredLanguage = @"zh-Hans";
    } else if ([_preferredLanguage rangeOfString:@"zh-Hant"].location != NSNotFound) {
        _preferredLanguage = @"zh-Hant";
    } else if ([_preferredLanguage rangeOfString:@"ar"].location != NSNotFound) {
        _preferredLanguage = @"ar";
    } else {
        _preferredLanguage = @"en";
    }
    self.languageBundle = [NSBundle bundleWithPath:[[NSBundle le_loadBundleClass:[LELanguage class] bundleName:@"LinKingGameHkSDKBundle"] pathForResource:_preferredLanguage ofType:@"lproj"]];
}

@end
