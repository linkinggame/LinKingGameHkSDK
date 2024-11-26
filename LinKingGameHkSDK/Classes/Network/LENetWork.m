//
//  LENetWork.m
//  LinKingEnSDK
//
//  Created by leoan on 2020/8/10.
//  Copyright © 2020 dml1630@163.com. All rights reserved.
//

#import "LENetWork.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "LENetUtils.h"
#import "NSObject+LEAdditions.h"
#import <AFNetworking/AFNetworking.h>
#import "LKLog.h"
#import "LEUser.h"
typedef void (^LKSuccessBlock)(id obj);
typedef void (^LKFailureBlock)(NSError *error);
static LENetWork *manager = nil;
static AFHTTPSessionManager *af_manager = nil;
@implementation LENetWork
+(AFHTTPSessionManager *)sharedHttpSessionManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        af_manager = [AFHTTPSessionManager manager];
        af_manager.operationQueue.maxConcurrentOperationCount = 4;
    });
    
    return af_manager;
}

+ (NSDictionary *)dealParameters:(NSDictionary *)parames{

    NSMutableDictionary *resultParames = [NSMutableDictionary dictionaryWithDictionary:parames];
    // 数据签名
    NSString *signVal = [LENetUtils getSignData:parames];
    [resultParames setValue:signVal forKey:@"sign"];

    return resultParames;
}

+ (void)getFromPhpithURLString:(NSString *)urlString success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure{

    AFHTTPSessionManager *sessionManage =  [LENetWork sharedHttpSessionManager];
    sessionManage.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", @"text/plain",nil];
    LKLogInfo(@"urlString:%@",urlString);
    [sessionManage GET:urlString parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            LKLogInfo(@"josnStr:%@",responseObject);
            if (responseObject != nil) {
                success(responseObject);
            }else{
           
                LKLogInfo(@"<~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*>");
                LKLogInfo(@"--- request config fail start ---");
                LKLogInfo(@"urlString:%@",urlString);
                LKLogInfo(@"--- request config fail end ---");
                LKLogInfo(@"<~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*>");
                NSError *errorCustome =  [self responserErrorMsg:@"網絡解析失敗,請檢查網絡" code:1001];
                failure(errorCustome);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(error);
        }];
    

}

+ (void)getWithURLString:(NSString *)urlString success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure{

    AFHTTPSessionManager *sessionManage =  [LENetWork sharedHttpSessionManager];
//    sessionManage.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", @"text/plain",nil];
    LKLogInfo(@"urlString:%@",urlString);
    [sessionManage GET:urlString parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSData *data = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];

            NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            LKLogInfo(@"josnStr:%@",responseStr);

            if (data != nil) {
                id object = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                           
                       if ([object isKindOfClass:[NSDictionary class]]) {
                           
                           NSDictionary *responseDict = (NSDictionary *)object;
                           success(responseDict);
                       }else if ([object isKindOfClass:[NSArray class]]){
                              NSArray *responseDict = (NSArray *)object;

                           success(responseDict);
                       }else{
                        
                           LKLogInfo(@"<~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*>");
                           LKLogInfo(@"==== request config fail start ==");
                           LKLogInfo(@"urlString:%@",urlString);
                           LKLogInfo(@"==== request config fail end ==");
                           LKLogInfo(@"<~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*>");
                           NSError *errorCustome =  [self responserErrorMsg:@"網絡解析失敗,請檢查網絡" code:1002];
                           failure(errorCustome);
                       }
            }else{
           
                LKLogInfo(@"<~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*>");
                LKLogInfo(@"--- request config fail start ---");
                LKLogInfo(@"urlString:%@",urlString);
                LKLogInfo(@"--- request config fail end ---");
                LKLogInfo(@"<~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*>");
                NSError *errorCustome =  [self responserErrorMsg:@"網絡解析失敗,請檢查網絡" code:1001];
                failure(errorCustome);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(error);
        }];
    

}
+ (NSString *)getLanguage{
    NSString * preferredLanguage = @"zh-Hans";
    if (!preferredLanguage || !preferredLanguage.length) {
        preferredLanguage = [NSLocale preferredLanguages].firstObject;
    }
    if ([preferredLanguage rangeOfString:@"zh-Hans"].location != NSNotFound) {
        preferredLanguage = @"zh-Hans";
    } else if ([preferredLanguage rangeOfString:@"zh-Hant"].location != NSNotFound) {
        preferredLanguage = @"zh-Hant";
    } else if ([preferredLanguage rangeOfString:@"ar"].location != NSNotFound) {
        preferredLanguage = @"ar";
    } else {
        preferredLanguage = @"en";
    }
    return preferredLanguage;
}

+ (void)postNormalWithURLString:(NSString *)urlString parameters:(NSDictionary *)parameters HTTPHeaderField:(NSDictionary *)headerField success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure{
    NSData *data =[NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
    AFHTTPSessionManager *session = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest *request =  [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlString parameters:parameters error:nil];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", @"text/plain",nil];
    request.timeoutInterval = 60;
    [request setValue:@"application/json;text/plain;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    if (headerField != nil) {
        for (NSString *key in headerField.allKeys) {
            [request setValue:headerField[key] forHTTPHeaderField:key];
        }
    }
    [request setHTTPBody:data];
    [[session dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {

    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {

    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {

        if (error) {
            failure(error);
        }else{
            LKLogInfo(@"responseObject:%@",responseObject);
            if (error) {
                failure(error);
            } else {
              success(responseObject);
            }
        }

    }] resume];
}

//===
+ (void)postWithURLString:(NSString *)urlString parameters:(NSDictionary *)parameters success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure{

    LKLogInfo(@"urlString:%@",urlString);
   
    NSDictionary *resultDict = parameters;
    LKLogInfo(@"parameters:%@",parameters);


    NSData *data =[NSJSONSerialization dataWithJSONObject:resultDict options:NSJSONWritingPrettyPrinted error:nil];
    AFHTTPSessionManager *session = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    NSMutableURLRequest *request =  [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlString parameters:parameters error:nil];

    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", @"text/plain",nil];
    request.timeoutInterval = 60;
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[self getLanguage] forHTTPHeaderField:@"LK_LANGUAGE"];
    [request setHTTPBody:data];

    [[session dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {

    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {

    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {

        if (error) {
            failure(error);
        }else{
            NSData *data = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];

            NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            LKLogInfo(@"josnStr:%@",responseStr);
            
            if (data != nil) {
                id object = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                    
                    if ([object isKindOfClass:[NSDictionary class]]) {
                        
                        NSDictionary *responseDict = (NSDictionary *)object;
                        if (error) {
                            failure(error);
                        } else {
                          success(responseDict);
                        }
                    }
            } else {
                failure([self responserErrorMsg:@"解析失敗" code:-107]);
            }

        }

    }] resume];

}
+ (void)postWithURLString:(NSString *)urlString parameters:(NSDictionary *)parameters HTTPHeaderField:(NSDictionary *)headerField success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure{
    LKLogInfo(@"urlString:%@",urlString);
   
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:[self dealParameters:parameters]];
    LEUser *user = [LEUser getUser];
    if (user != nil) {
        if (user.token.exceptNull != nil) {
            [resultDict setObject:user.token forKey:@"lk_token"];
        }
        if (user.userId.exceptNull != nil) {
            [resultDict setObject:user.userId forKey:@"uid"];
        }
        
        [resultDict setObject:[self getLanguage] forKey:@"LK_LANGUAGE"];
    }
    LKLogInfo(@"parameters:%@",parameters);
    NSData *data =[NSJSONSerialization dataWithJSONObject:resultDict options:NSJSONWritingPrettyPrinted error:nil];
    AFHTTPSessionManager *session = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    NSMutableURLRequest *request =  [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlString parameters:parameters error:nil];

    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", @"text/plain",nil];
    request.timeoutInterval = 60;
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[self getLanguage] forHTTPHeaderField:@"LK_LANGUAGE"];
    if (headerField != nil) {
        for (NSString *key in headerField.allKeys) {
            [request setValue:headerField[key] forHTTPHeaderField:key];
        }
    }
    [request setHTTPBody:data];

    [[session dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {

    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {

    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {

        if (error) {
            failure(error);
        }else{
            NSData *data = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];

            NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            LKLogInfo(@"josnStr:%@",responseStr);

            if (data != nil) {
                id object = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                    
                    if ([object isKindOfClass:[NSDictionary class]]) {
                        
                        NSDictionary *responseDict = (NSDictionary *)object;
                        if (error) {
                            failure(error);
                        } else {
                          success(responseDict);
                        }
                    }
            } else {
                failure([self responserErrorMsg:@"解析失敗" code:-107]);
            }
        }

    }] resume];
}

//===

+ (void)uploadWithURLString:(NSString *)urlString withImages:(NSArray<UIImage *>*)images parameters:(NSDictionary *)parameters HTTPHeaderField:(NSDictionary *)headerField complete:(void(^)(NSError *error))complete {
    //分界线的标识符
    NSString *TWITTERFON_FORM_BOUNDARY = @"AaB03x";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    //分界线 --AaB03x
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    //结束符 AaB03x--
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    //http body的字符串
    NSMutableString *body=[[NSMutableString alloc] init];
    //参数的集合的所有key的集合
    NSArray *keys= [parameters allKeys];
    
    for (int i = 0; i <keys.count; i++) {
        //得到当前key
        NSString *key=[keys objectAtIndex:i];
        //添加分界线，换行
        [body appendFormat:@"%@\r\n",MPboundary];
        //添加字段名称，换2行
        [body appendFormat:@"Content-Disposition:form-data; name=\"%@\"\r\n\r\n", key];
        //添加字段的值
        [body appendFormat:@"%@\r\n",[parameters objectForKey:key]];
    }
    //声明myRequestData，用来放入http body
     NSMutableData *myRequestData=[NSMutableData data];
    //将body字符串转化为UTF8格式的二进制
     [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    //循环加入上传图片
    for (int i = 0; i<images.count; i++) {
        //要上传的图片
         UIImage *image = images[i];
         NSData*data=UIImageJPEGRepresentation(image, 0.1);
         NSMutableString *imgbody = [[NSMutableString alloc] init];
        //此处循环添加图片文件
        //添加图片信息字段
        //声明pic字段，文件名为boris.png
        NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
        formatter.dateFormat=@"yyyyMMddHHmmss";
        NSString *str=[formatter stringFromDate:[NSDate date]];
        NSString *fileName=[NSString stringWithFormat:@"%@.png",str];

        LKLogInfo(@"file name : %@",fileName);
        
        ////添加分界线，换行
        [imgbody appendFormat:@"%@\r\n",MPboundary];
        //[imgbody appendFormat:@"Content-Disposition: form-data; name="File%d"; filename="%@.jpg"\r\n", i, [keys objectAtIndex:i]];
        [imgbody appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"files", fileName];
        //声明上传文件的格式
        [imgbody appendFormat:@"Content-Type: application/octet-stream; charset=utf-8\r\n\r\n"];
        //将body字符串转化为UTF8格式的二进制
        [myRequestData appendData:[imgbody dataUsingEncoding:NSUTF8StringEncoding]];
        //将image的data加入
        [myRequestData appendData:data];
        [myRequestData appendData:[ @"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
     //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"%@\r\n",endMPboundary];
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    //设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [request setHTTPBody:myRequestData];
    //http method
    [request setHTTPMethod:@"POST"];
//     [request setTimeoutInterval:60];
    // 设置请求头额外参数
    if (headerField != nil) {
        for (NSString *key in headerField.allKeys) {
            [request setValue:headerField[key] forHTTPHeaderField:key];
        }
    }
     NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
     NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
             if (complete) {
                complete(error);
            }
        });
    }] resume];
}
+ (NSError *)responserErrorMsg:(NSString *)msg{
    if (msg.exceptNull == nil) {
        msg = @"系统错误";
    }
    NSString *domain = @"com.linking.sdk.ErrorDomain";
        NSString *errorDesc = NSLocalizedString(msg, @"");
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : errorDesc };
        NSError *error = [NSError errorWithDomain:domain code:-101 userInfo:userInfo];
    return error;
}
+ (NSError *)responserErrorMsg:(NSString *)msg code:(int)code{
    if (msg.exceptNull == nil) {
        msg = @"系统错误";
    }
    NSString *domain = @"com.linking.sdk.ErrorDomain";
        NSString *errorDesc = NSLocalizedString(msg, @"");
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : errorDesc };
        NSError *error = [NSError errorWithDomain:domain code:code userInfo:userInfo];
    return error;
}
@end
