/*!
    RFAPICacheManager
    RFAPI

    Copyright (c) 2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    TEST
 */
#import <Foundation/Foundation.h>

@class RFAPIDefine, RFAPIControl, AFNetworkReachabilityManager;

@interface RFAPICacheManager : NSURLCache
@property (weak, nonatomic) AFNetworkReachabilityManager *reachabilityManager;

- (NSURLRequestCachePolicy)cachePolicyWithDefine:(RFAPIDefine *)define control:(RFAPIControl *)control;

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request define:(RFAPIDefine *)define control:(RFAPIControl *)control;
- (void)storeCachedResponseForRequest:(NSURLRequest *)request response:(NSHTTPURLResponse *)response data:(NSData *)responseData define:(RFAPIDefine *)define control:(RFAPIControl *)control;

// TODO
// - (void)removeCachedResponseForDefine:(RFAPIDefine *)define;

@end
