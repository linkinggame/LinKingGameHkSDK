//
//  UIImage+LEAdditions.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/10.
//  Copyright © 2020 "". All rights reserved.
//

#import "UIImage+LEAdditions.h"
#import "NSBundle+LEAdditions.h"
#import "LESDKManager.h"
@implementation UIImage (LEAdditions)
+ (UIImage *)le_ImageNamed:(NSString *)name{
    
    // bundle
   NSBundle *bundle = [NSBundle le_loadBundleClass:[LESDKManager class] bundleName:@"LinKingGameHkSDKBundle"];
    
    name = [name stringByAppendingFormat:@"@2x"];
    // path
   NSString *imagePath = [bundle pathForResource:name ofType:@"png"];
    
    // image
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    if (!image) {
        
        // 去除@2x 使用 imagesName 加载
      name = [name stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
      image = [UIImage imageNamed:name];
    }
    

    return  image;
}
+ (UIImage *)le_ImageNamed:(NSString *)name withCls:(Class)cls{
    
    // bundle
   NSBundle *bundle = [NSBundle le_loadBundleClass:cls bundleName:@"LinKingGameHkSDKBundle"];
    
    name = [name stringByAppendingFormat:@"@2x"];
    // path
   NSString *imagePath = [bundle pathForResource:name ofType:@"png"];
    
    // image
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    if (!image) {
        
        // 去除@2x 使用 imagesName 加载
      name = [name stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
      image = [UIImage imageNamed:name];
    }
    

    
    return  image;
}
@end
