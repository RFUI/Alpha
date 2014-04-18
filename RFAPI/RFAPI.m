
#import "RFAPI.h"
#import "RFAssetsCache.h"
#import "RFMessageManager+RFDisplay.h"
#import "RFAPIDefineManager.h"

#import "AFURLResponseSerialization.h"
#import "AFURLRequestSerialization.h"
#import "AFHTTPRequestOperation.h"

#import "AFNetworkReachabilityManager.h"
#import "AFNetworkActivityIndicatorManager.h"

@interface RFAPI ()
@property (strong, nonatomic, readwrite) AFNetworkReachabilityManager *reachabilityManager;
@property (strong, nonatomic) RFAPIDefineManager *defineManager;
@end

@implementation RFAPI
RFInitializingRootForNSObject

+ (instancetype)sharedInstance {
	static RFAPI *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
	return sharedInstance;
}

- (void)onInit {
    self.reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    self.maxConcurrentOperationCount = 5;
    self.defineManager = [[RFAPIDefineManager alloc] init];
}

- (void)afterInit {
}

//- (NSString *)description {
//    return [NSString stringWithFormat:@"<%@: %p, baseURL: %@, operationQueue: %@>", self.class, self, [self.baseURL absoluteString], self.operationQueue];
//}

#pragma mark - Define

- (void)setAPIDefineWithRules:(NSDictionary *)rules {
    [self.defineManager mergeWithRules:rules];
}

- (RFAPIDefine *)defineForName:(NSString *)APIName {
    return [self.defineManager defineForName:APIName];
}

#pragma mark - Request

- (AFHTTPRequestSerializer<AFURLRequestSerialization> *)requestSerializer {
    if (!_requestSerializer) {
        _requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    return _requestSerializer;
}

- (NSMutableURLRequest *)URLRequestWithDefine:(RFAPIDefine *)define parameters:(NSDictionary *)parameters uploadResources:(NSArray *)uploadResources {
    NSParameterAssert(define);

    AFHTTPRequestSerializer *s = [self.defineManager requestSerializerForDefine:define];
    NSError __autoreleasing *e = nil;
    if (e) dout_error(@"%@", e);
    return [s requestWithMethod:define.method URLString:define.path parameters:parameters error:&e];
}

- (NSMutableURLRequest *)customSerializedRequest:(NSMutableURLRequest *)request withDefine:(RFAPIDefine *)define {
    // Nothing
    return request;
}

- (id<AFURLResponseSerialization>)responseSerializer {
    if (!_responseSerializer) {
        _responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return _responseSerializer;
}

- (void)alertError:(NSError *)error title:(NSString *)title {
    [self.networkActivityIndicatorManager alertError:error title:title];
}



@end
