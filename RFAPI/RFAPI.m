
#import "RFAPI.h"
#import "RFAssetsCache.h"
#import "RFMessageManager+RFDisplay.h"
#import "RFAPIDefineManager.h"

#import "AFURLResponseSerialization.h"
#import "AFURLRequestSerialization.h"
#import "AFHTTPRequestOperation.h"

#import "AFNetworkReachabilityManager.h"
#import "AFNetworkActivityIndicatorManager.h"

RFDefineConstString(RFAPIErrorDomain);

#ifndef DebugAPIDelayFetchCallbackReturnSecond
#   define DebugAPIDelayFetchCallbackReturnSecond 0
#endif

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
    self.defineManager.master = self;
}

- (void)afterInit {
    [self.reachabilityManager startMonitoring];
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

#define __RFAPIMakeRequestError(CONDITION)\
    if (CONDITION) {\
        if (error) {\
            *error = e;\
        }\
        return nil;\
    }

#define __RFAPICompletionCallback(BLOCK, ...)\
    if (BLOCK) {\
        if (DebugAPIDelayFetchCallbackReturnSecond) {\
            dispatch_after_seconds(DebugAPIDelayFetchCallbackReturnSecond, ^{\
                BLOCK(__VA_ARGS__);\
            });\
        }\
        else {\
            BLOCK(__VA_ARGS__);\
        }\
    }

- (AFHTTPRequestOperation *)requestWithName:(NSString *)APIName parameters:(NSDictionary *)parameters controlInfo:(RFAPIControl *)controlInfo controlFlag:(int *)flag success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure completion:(void (^)(AFHTTPRequestOperation *))completion {
    NSParameterAssert(APIName);
    RFAPIDefine *define = [self defineForName:APIName];
    RFAssert(define, @"Can not find an API with name: %@.", APIName);
    if (!define) return nil;

    NSError __autoreleasing *e = nil;
    NSMutableURLRequest *request = [self URLRequestWithDefine:define parameters:parameters controlInfo:controlInfo error:&e];
    if (!request) {
#if RFDEBUG
        dout_error(@"无法创建请求: %@", e);
#endif
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:@{
            NSLocalizedDescriptionKey : @"内部错误，无法创建请求",
            NSLocalizedFailureReasonErrorKey : @"很可能是应用 bug",
            NSLocalizedRecoverySuggestionErrorKey : @"请再试一次，如果依旧请尝试重启应用。给您带来不便，敬请谅解"
        }];

        __RFAPICompletionCallback(failure, nil, error);
        __RFAPICompletionCallback(completion, nil);
    }

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [self.defineManager responseSerializerForDefine:define];

    Class expectClass = define.responseClass;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id responseObject) {
        switch (define.responseExpectType) {
            case RFAPIDefineResponseExpectSuccess:
                break;

            case RFAPIDefineResponseExpectObject:
                break;

            case RFAPIDefineResponseExpectObjects:
                break;

            case RFAPIDefineResponseExpectDefault:
            default:
                break;
        }
        __RFAPICompletionCallback(success, op, responseObject);
        __RFAPICompletionCallback(completion, op);
    } failure:^(AFHTTPRequestOperation *op, NSError *error) {
        __RFAPICompletionCallback(failure, op, error);
        __RFAPICompletionCallback(completion, op);
    }];

    [self addOperation:operation];
    return operation;
}

- (NSMutableURLRequest *)URLRequestWithDefine:(RFAPIDefine *)define parameters:(NSDictionary *)parameters controlInfo:(RFAPIControl *)controlInfo error:(NSError *__autoreleasing *)error {
    NSParameterAssert(define);

    NSError __autoreleasing *e = nil;
    NSURL *url = [self.defineManager requestURLForDefine:define error:&e];
    __RFAPIMakeRequestError(!url);

    // TODO: Cache policy
    NSURLRequestCachePolicy cachePolicy = (self.reachabilityManager.reachable)? NSURLRequestUseProtocolCachePolicy : NSURLRequestReturnCacheDataElseLoad;
    NSMutableURLRequest *r = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:cachePolicy timeoutInterval:10];
    [r setHTTPMethod:define.method];

    AFHTTPRequestSerializer *s = [self.defineManager requestSerializerForDefine:define];

    r = [[s requestBySerializingRequest:r withParameters:parameters error:&e] mutableCopy];
    __RFAPIMakeRequestError(!r);

    [define.HTTPRequestHeaders enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL *__unused stop) {
        [r setValue:value forHTTPHeaderField:field];
    }];

    return r;
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

#pragma mark - Old raw request

- (AFHTTPRequestOperation *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters headers:(NSDictionary *)headers expectArrayContainsClass:(Class)modelClass success:(void (^)(AFHTTPRequestOperation *operation, NSMutableArray *objects))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure completion:(void (^)(AFHTTPRequestOperation *operation))completion {
    RFAssert([modelClass isSubclassOfClass:[JSONModel class]], @"modelClass 必须是 JSONModel");

    return [self requestWithMethod:method URLString:URLString parameters:parameters headers:headers success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (![responseObject isKindOfClass:[NSArray class]]) {
            if (failure) {
#if RFDEBUG
                dout_error(@"期望的数据类型是数组，而实际是 %@\n", [responseObject class]);
#endif
                failure(operation, [NSError errorWithDomain:RFAPIErrorDomain code:0 userInfo:@{
                    NSLocalizedDescriptionKey : @"返回数据异常",
                    NSLocalizedFailureReasonErrorKey : @"可能服务器正在升级或者维护，也可能是应用bug",
                    NSLocalizedRecoverySuggestionErrorKey : @"建议稍后重试，如果持续报告这个错误请检查应用是否有新版本",
                    NSURLErrorFailingURLErrorKey : operation.request.URL
                }]);
            }
            return;
        }

        NSError __autoreleasing *e = nil;
        NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[responseObject count]];
        for (NSDictionary *info in responseObject) {
            id obj = [[modelClass alloc] initWithDictionary:info error:&e];
            if (obj) {
                [objects addObject:obj];
            }
            else {
                if (failure) {
#if RFDEBUG
                    dout_error(@"不能将数组中的元素转换为Model %@\n请先确认一下代码，如果服务器没按要求返回请联系后台人员", e);
#endif
                    failure(operation, [NSError errorWithDomain:RFAPIErrorDomain code:0 userInfo:@{
                        NSLocalizedDescriptionKey : @"返回数据异常",
                        NSLocalizedFailureReasonErrorKey : @"可能服务器正在升级或者维护，也可能是应用bug",
                        NSLocalizedRecoverySuggestionErrorKey : @"建议稍后重试，如果持续报告这个错误请检查应用是否有新版本",
                        NSURLErrorFailingURLErrorKey : operation.request.URL
                    }]);
                }
                return;
            }
        }

        if (success) {
            success(operation, objects);
        }
    } failure:failure completion:completion];
}

- (AFHTTPRequestOperation *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters headers:(NSDictionary *)headers expectObjectClass:(Class)modelClass success:(void (^)(AFHTTPRequestOperation *operation, id JSONModelObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure completion:(void (^)(AFHTTPRequestOperation *operation))completion {
    RFAssert([modelClass isSubclassOfClass:[JSONModel class]], @"modelClass 必须是 JSONModel");

    return [self requestWithMethod:method URLString:URLString parameters:parameters headers:headers success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            if (failure) {
#if RFDEBUG
                dout_error(@"期望的数据类型是字典，而实际是 %@\n请先确认一下代码，如果服务器没按要求返回请联系后台人员", [responseObject class]);
#endif
                failure(operation, [NSError errorWithDomain:RFAPIErrorDomain code:0 userInfo:@{
                    NSLocalizedDescriptionKey : @"返回数据异常",
                    NSLocalizedFailureReasonErrorKey : @"可能服务器正在升级或者维护，也可能是应用bug",
                    NSLocalizedRecoverySuggestionErrorKey : @"建议稍后重试，如果持续报告这个错误请检查应用是否有新版本",
                    NSURLErrorFailingURLErrorKey : operation.request.URL
                }]);
            }
            return;
        }

        NSError __autoreleasing *e = nil;
        id JSONModelObject = [[modelClass alloc] initWithDictionary:responseObject error:&e];
        if (!JSONModelObject) {
            if (failure) {
#if RFDEBUG
                dout_error(@"不能将返回内容转换为Model：%@\n请先确认一下代码，如果服务器没按要求返回请联系后台人员", e);
#endif
                failure(operation, [NSError errorWithDomain:RFAPIErrorDomain code:0 userInfo:@{
                    NSLocalizedDescriptionKey : @"返回数据异常",
                    NSLocalizedFailureReasonErrorKey : @"可能服务器正在升级或者维护，也可能是应用bug",
                    NSLocalizedRecoverySuggestionErrorKey : @"建议稍后重试，如果持续报告这个错误请检查应用是否有新版本",
                    NSURLErrorFailingURLErrorKey : operation.request.URL
                }]);
            }
            return;
        }

        if (success) {
            success(operation, JSONModelObject);
        }
    } failure:failure completion:completion];
}

#undef __RFAPICompletionCallback

@end

NSString *const RFAPIMessageControlKey = @"_RFAPIMessageControl";
NSString *const RFAPIIdentifierControlKey = @"_RFAPIIdentifierControl";
NSString *const RFAPIGroupIdentifierControlKey = @"_RFAPIGroupIdentifierControl";
NSString *const RFAPIRequestCustomizationControlKey = @"_RFAPIRequestCustomizationControl";

@implementation RFAPIControl

- (id)initWithDictionary:(NSDictionary *)info {
    self = [super init];
    if (self) {
        _message = info[RFAPIMessageControlKey];
        _identifier = info[RFAPIIdentifierControlKey];
        _groupIdentifier = info[RFAPIGroupIdentifierControlKey];
    }
    return self;
}

@end

@implementation RFHTTPRequestFormData

@end
