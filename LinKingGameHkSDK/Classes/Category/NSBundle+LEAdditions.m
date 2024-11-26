//
//  NSBundle+LEAdditions.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/10.
//  Copyright © 2020 "". All rights reserved.
//

#import "NSBundle+LEAdditions.h"
#import "LESDKManager.h"
@implementation NSBundle (LEAdditions)
+ (NSBundle *)le_loadBundleClass:(Class)aClass bundleName:(NSString *)bundleName{
    NSBundle *bundle = [NSBundle bundleForClass:[aClass class]];
    NSURL *url = [bundle URLForResource:bundleName withExtension:@"bundle"];
    bundle = [NSBundle bundleWithURL:url];
    return bundle;
}
+ (NSString *)le_localizedStringForKey:(NSString *)key {
    return [self le_localizedStringForKey:key value:@""];
}

+ (NSString *)le_localizedStringForKey:(NSString *)key value:(NSString *)value {
    NSBundle *bundle = [LESDKManager shared].languageBundle;
    NSString *value1 = [bundle localizedStringForKey:key value:value table:nil];
    return value1;
}
@end
