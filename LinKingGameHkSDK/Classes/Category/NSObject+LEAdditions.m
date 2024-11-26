//
//  NSObject+LEAdditions.m
//  LinKingEnSDK
//
//  Created by leon on 2020/8/10.
//  Copyright © 2020 "". All rights reserved.
//

#import "NSObject+LEAdditions.h"

@implementation NSObject (LEAdditions)
- (id)exceptNull
{
    if (self == [NSNull null]) {
        return nil;
    }
    if ([self isKindOfClass:[NSString class]]) {
        if ([(NSString*)self isEqualToString:@"<null>"]) {
            return nil;
        }
        if ([(NSString*)self isEqualToString:@"null"]) {
            return nil;
        }
        if ([(NSString*)self isEqualToString:@""]) {
            return nil;
        }
        if ([(NSString*)self isEqualToString:@"false"]) {
            return nil;
        }
        if ([(NSString*)self isEqualToString:@"(null)"]) {
            return nil;
        }
        if ([(NSString*)self isEqualToString:@"<nil>"]) {
            return nil;
        }
    }

    return self;
}

- (NSError *)responserErrorMsg:(NSString *)msg code:(int)code{
    NSString *domain = @"com.linking.sdk.ErrorDomain";
        NSString *errorDesc = NSLocalizedString(msg, @"");
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : errorDesc };
        NSError *error = [NSError errorWithDomain:domain code:code userInfo:userInfo];
    return error;
}
@end
