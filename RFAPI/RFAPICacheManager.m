
#import "RFAPICacheManager.h"
#import "RFAPI.h"
#import "AFNetworkReachabilityManager.h"

@interface RFAPICacheManager ()
@end

@implementation RFAPICacheManager

- (NSURLRequestCachePolicy)cachePolicyWithDefine:(RFAPIDefine *)define control:(RFAPIControl *)control {
    if (control.forceLoad) {
        return NSURLRequestReloadIgnoringLocalCacheData;
    }

    if (self.reachabilityManager.reachable) {
        switch (define.cachePolicy) {
            case RFAPICachePolicyAlways:
                return NSURLRequestReturnCacheDataElseLoad;

            case RFAPICachePolicyNoCache:
                return NSURLRequestReloadIgnoringLocalCacheData;

            case RFAPICachePolicyExpire:
            default:
                return NSURLRequestUseProtocolCachePolicy;
        }
    }
    else {
        switch (define.offlinePolicy) {
            case RFAPIOfflinePolicyLoadCache:
                return NSURLRequestReturnCacheDataElseLoad;

            default:
                break;
        }
    }
    return NSURLRequestUseProtocolCachePolicy;
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request define:(RFAPIDefine *)define control:(RFAPIControl *)control {
    NSCachedURLResponse *cachedResponse = [self cachedResponseForRequest:request];
    if (!cachedResponse) return nil;

    if (control.forceLoad) {
        return nil;
    }

    if (self.reachabilityManager.reachable) {
        switch (define.cachePolicy) {
            case RFAPICachePolicyAlways:
                return cachedResponse;

            case RFAPICachePolicyNoCache:
                return nil;

            case RFAPICachePolicyExpire: {
                NSTimeInterval expireTime = [cachedResponse.userInfo[RFAPIDefineExpireKey] doubleValue];
                if (expireTime > [NSDate timeIntervalSinceReferenceDate]) {
                    return cachedResponse;
                }
                else {
                    dout_debug(@"Cache expired.")
                }
            }
            default:
                return nil;
        }
    }
    else {
        switch (define.offlinePolicy) {
            case RFAPIOfflinePolicyLoadCache:
                return cachedResponse;

            default:
                return nil;
        }
    }
    return nil;
}

- (void)storeCachedResponseForRequest:(NSURLRequest *)request response:(NSHTTPURLResponse *)response data:(NSData *)responseData define:(RFAPIDefine *)define control:(RFAPIControl *)control {
    // No need to store cache
    if (define.offlinePolicy == RFAPIOfflinePolicyDefault) {
        if (define.cachePolicy == RFAPICachePolicyNoCache) {
            return;
        }

        // Cache controlled by server, ignore.
        if (define.cachePolicy == RFAPICachePolicyDefault
            || define.cachePolicy == RFAPICachePolicyProtocol) {
            return;
        }
    }

    NSTimeInterval age = define.expire;
    NSTimeInterval expire = age? age + [NSDate timeIntervalSinceReferenceDate] : 1;

    NSMutableDictionary *headers = [response.allHeaderFields mutableCopy];

    // Rewrite cache headers to force NSURLCache store responses.
    headers[@"Cache-Control"] = [NSString stringWithFormat:@"%@; max-age=%.0f", define.needsAuthorization? @"private" : @"public", fmax(age, 1)];
    [headers removeObjectForKey:@"Expires"];
    [headers removeObjectForKey:@"Pragma"];

    // MARK: How to avoid hard-code HTTPVersion?
    NSHTTPURLResponse *modifiedResponse = [[NSHTTPURLResponse alloc] initWithURL:(id)response.URL statusCode:response.statusCode HTTPVersion:@"HTTP/1.1" headerFields:headers];

    NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:modifiedResponse data:responseData userInfo:@{ RFAPIDefineExpireKey : @(expire) } storagePolicy:NSURLCacheStorageAllowed];
    [self storeCachedResponse:cachedResponse forRequest:request];

    _dout_debug(@"RFAPICache current usage: disk = %lu, memory = %lu", (unsigned long)self.currentDiskUsage, (unsigned long)self.currentMemoryUsage);
}

@end
