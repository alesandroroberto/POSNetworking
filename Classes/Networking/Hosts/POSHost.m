//
//  POSHost.m
//  POSNetworking
//
//  Created by Pavel Osipov on 22.09.15.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSHost.h"
#import "POSHTTPGateway.h"
#import "POSHTTPGatewayOptions.h"
#import "POSHTTPRequest.h"
#import "POSHTTPResponse.h"
#import "NSError+POSNetworking.h"

NS_ASSUME_NONNULL_BEGIN

@interface POSHost ()
@property (nonatomic, readonly) id<POSHTTPGateway> gateway;
@end

@implementation POSHost

@synthesize options = _options;

- (instancetype)initWithGateway:(id<POSHTTPGateway>)gateway
                        options:(nullable POSHTTPGatewayOptions *)options {
    POS_CHECK(gateway);
    if (self = [super initWithScheduler:gateway.scheduler safetyPredicate:nil]) {
        _gateway = gateway;
        _options = options;
    }
    return self;
}

- (nullable NSURL *)URL {
    return nil;
}

- (RACSignal<POSHostURLInfo *> *)fetchURLInfo {
    POS_CHECK(self.URL);
    return [RACSignal return:[[POSHostURLInfo alloc] initWithURL:self.URL options:self.options.requestOptions]];
}

- (RACSignal *)pushRequest:(id<POSHTTPRequest>)request {
    return [self pushRequest:request options:nil];
}

- (RACSignal *)pushRequest:(id<POSHTTPRequest>)request options:(nullable POSHTTPGatewayOptions *)options {
    POS_CHECK(request);
    POS_CHECK(self.URL);
    return [[[[_gateway
        taskForRequest:request toHost:self.URL hostOptions:_options extraOptions:options]
        execute]
        takeUntil:self.rac_willDeallocSignal]
        flattenMap:^RACSignal *(POSHTTPResponse *response) {
            @try {
                NSError *error = nil;
                id _Nullable parsedResponse = request.responseHandler(response, &error);
                if (error) {
                    return [RACSignal error:error];
                }
                if (parsedResponse) {
                    return [RACSignal return:parsedResponse];
                }
                return [RACSignal empty];
            } @catch (NSException *exception) {
                return [RACSignal error:[NSError pos_serverErrorWithTag:@"exception" format:exception.reason]];
            }
        }];
}

@end

#pragma mark -

@implementation POSHostURLInfo

- (instancetype)initWithURL:(NSURL *)URL options:(nullable POSHTTPRequestOptions *)options {
    POS_CHECK(URL);
    if (self = [super init]) {
        _URL = URL;
        _options = options;
    }
    return self;
}

@end

NS_ASSUME_NONNULL_END
