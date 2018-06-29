//
//  NSURL+POSNetworking.m
//  POSNetworking
//
//  Created by Pavel Osipov on 23.09.14.
//  Copyright © 2014 Pavel Osipov. All rights reserved.
//

#import "NSURL+POSNetworking.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSURL (POSNetworking)

- (nullable NSURL *)pos_URLByAppendingEscapedPathComponent:(nullable NSString *)pathComponent {
    if (!pathComponent) {
        return self;
    }
    NSString *absoluteString = self.absoluteString;
    if (![absoluteString hasSuffix:@"/"]) {
        absoluteString = [absoluteString stringByAppendingString:@"/"];
    }
    absoluteString = [absoluteString stringByAppendingString:pathComponent];
    return [NSURL URLWithString:absoluteString];
}

- (nullable NSURL *)pos_URLByAppendingPathComponent:(nullable NSString *)pathComponent {
    return [self pos_URLByAppendingEscapedPathComponent:
            [pathComponent stringByAddingPercentEncodingWithAllowedCharacters:
             NSCharacterSet.URLPathAllowedCharacterSet]];
}

- (nullable NSURL *)pos_URLByAppendingQueryString:(nullable NSString *)queryString {
    if (!queryString.length) {
        return self;
    }
    NSString *URLString = [[NSString alloc] initWithFormat:@"%@%@%@",
                           self.absoluteString,
                           [self query] ? @"&" : @"?",
                           queryString];
    return [NSURL URLWithString:URLString];
}

@end

NS_ASSUME_NONNULL_END
