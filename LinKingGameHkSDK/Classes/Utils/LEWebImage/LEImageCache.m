//
//  LEImageCache.m
//  LingKingSDK_Example
//
//  Created by leon on 2020/4/14.
//  Copyright © 2020 "". All rights reserved.
//

#import "LEImageCache.h"
#import <CommonCrypto/CommonCrypto.h>
@interface LEImageCache (){
    NSMutableDictionary *_allCache;
}

@end
static LEImageCache *imageCache = nil;
@implementation LEImageCache
+ (instancetype)sharedImageCache
{
    //block 在内部修改外部的值 加static即可
    
    static  dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
       
     imageCache = [[LEImageCache alloc] init];

    });

    return imageCache;
    
}
// 如果防止别人alloc 单例类的对象 可以重写alloc方法
+(id)alloc
{
   static  dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^{
       imageCache=[super alloc];
   });

    return imageCache;
}

-(instancetype)init
{
    if (self=[super init]) {
        
        _allCache = [[NSMutableDictionary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearMemory) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        
    }
    return self;
}
-(void)clearMemory
{
    //当收到内存警告时会清理内存的图片对象 模拟器中模拟内存警告 HareWare-->
    [_allCache removeAllObjects];
    
}

#pragma mark 拿到内存中image对象的大小
- (long long)getMemorySize
{
    long long size = 0;
    
    for (NSString*key in [_allCache allKeys]) {
        
        UIImage *image = [_allCache objectForKey:key];
          NSData *data =UIImageJPEGRepresentation(image, 1);
        size +=data.length;
    }
    return size;
}

- (long long)getDiskSize
{
    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Imagecache"];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    long long size = 0;
    
    while ([enumerator nextObject]) {
        
        size +=enumerator.fileAttributes.fileSize;
    }
    return size;
}

- (UIImage *)searchImageFromMemoryWithURLString:(NSString*)urlStr
{
     //假设在一个大字典中有很多的文件,图片的地址作为键 把图片对象作为值 存到字典中
    
    
    return [_allCache objectForKey:urlStr];
    
}


- (NSString *)getFilePathWithURLStr:(NSString *)urlStr
{
    
  NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"ImageCache"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        
    }
    
    NSString *filePath = [path stringByAppendingPathComponent:[self MD5:urlStr]];
    NSLog(@"filePath-----%@",filePath);
    return filePath;
    
    
}


- (UIImage *)searceImageFromDiskWithURLStr:(NSString *)urlStr
{
    //假设缓存在沙盒中的图片 ~/Documents/ImageCache/图片地址
    
    UIImage *image = [UIImage imageWithContentsOfFile:[self getFilePathWithURLStr:urlStr]];
    
    if ( image != nil) {
        //缓存到内存
        [_allCache setObject:image forKey:urlStr];
    }
    

    return image;
}


- (void)downloadImageWithURLStr:(NSString *)urlStr withComplitionBlock:(void (^) (UIImage*image))block
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        NSURL *url = [NSURL URLWithString:urlStr];
           NSURLSession *session =  [NSURLSession sharedSession];
           
           NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
               if (!error && data) {
                   
                  UIImage *image =  [UIImage imageWithData:data];
                
                  //缓存到沙盒
                  [data writeToFile:[self getFilePathWithURLStr:urlStr] atomically:YES];

                  //缓存到内存
                   [self->_allCache setObject:image forKey:urlStr];
                  if (block) {
                        block(image);
                    }
               }
           }];

           [task resume];
        
    });
    
}
- (NSString *)MD5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];

    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];

    return  output;
}
@end
