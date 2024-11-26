//
//  UIImageView+LEWebCache.m
//  LingKingSDK_Example
//
//  Created by leon on 2020/4/14.
//  Copyright © 2020 "". All rights reserved.
//

#import "UIImageView+LEWebCache.h"
#import "LEImageCache.h"
@implementation UIImageView (LEWebCache)
-(void)le_setImageWithURStr:(NSString*)urlStr
{
    LEImageCache *imageCache = [LEImageCache sharedImageCache];
    
    //1.从内存中找
      //假设在一个大字典中有很多的文件,图片的地址作为键 把图片对象作为值 存到字典中
    
    UIImage *image = nil;
    image = [imageCache searchImageFromMemoryWithURLString:urlStr];
    if (image != nil) {
        
        self.image = image;
        
        return;
        
    }
    
    //2.从沙盒中找
    
     image =[imageCache searceImageFromDiskWithURLStr:urlStr];
    if (image != nil) {
        
        self.image = image;
        return;
    }
    
    //3.从网络网络网请求  基本上用异步下载都会使用block 返回出来 GCD 内部是异步的 不能再里面直接写return
    [imageCache downloadImageWithURLStr:urlStr withComplitionBlock:^(UIImage *image) {
       // self.image = image;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image = image;
        });
    }];
    
}




@end
