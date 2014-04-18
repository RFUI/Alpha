
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

- (void)requestWithName:(NSString *)APIName parameters:(NSDictionary *)parameters uploadResources:(NSArray *)uploadResources headers:(NSDictionary *)headers success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure completion:(void (^)(AFHTTPRequestOperation *))completion {
    RFAPIDefine *define = [self defineForName:APIName];
    if (!define) {


        return;
    }
}

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

#define __APICompletionCallback(BLOCK, OPERATION, OBJECT)\
    if (BLOCK) {\
        if (DebugAPIDelayFetchCallbackReturnSecond) {\
            dispatch_after_seconds(DebugAPIDelayFetchCallbackReturnSecond, ^{\
                BLOCK(OPERATION, OBJECT);\
            });\
        }\
        else {\
            BLOCK(OPERATION, OBJECT);\
        }\
    }

- (AFHTTPRequestOperation *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters headers:(NSDictionary *)headers success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure completion:(void (^)(AFHTTPRequestOperation *operation))completion {
    RFAssert(success, @"你确定成功没回调？");
    RFAssert(failure, @"写个接口错误不处理？");

    NSError *e = nil;
    NSMutableURLRequest *request = [self URLRequestWithMethod:method URLString:URLString parameters:parameters headers:headers error:&e];
    if (e) {
        __APICompletionCallback(failure, nil, e)
        if (completion) {
            completion(nil);
        }
        return nil;
    }

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = self.responseSerializer;

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id responseObject) {
        __APICompletionCallback(success, op, responseObject)
        if (completion) {
            completion(op);
        }
    } failure:^(AFHTTPRequestOperation *op, NSError *error) {
        __APICompletionCallback(failure, op, error)
        if (completion) {
            completion(op);
        }
    }];

    [self addOperation:operation];
    return operation;
}

#undef __APICompletionCallback

- (NSMutableURLRequest *)URLRequestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters headers:(NSDictionary *)headers error:(NSError *__autoreleasing *)error {
    NSParameterAssert(method);
    NSParameterAssert(URLString);

    NSURL *url = [NSURL URLWithString:URLString relativeToURL:self.baseURL];
    if (!url) {
        if (error) {
#if RFDEBUG
            dout_error(@"无法拼接 URL: %@\n请检查代码是否正确", URLString);
#endif
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:@{
                NSLocalizedDescriptionKey : @"内部错误，无法创建请求",
                NSLocalizedFailureReasonErrorKey : @"很可能是应用bug",
                NSLocalizedRecoverySuggestionErrorKey : @"请再试一次，如果依旧请尝试重启应用。给您带来不便，敬请谅解",
                NSURLErrorFailingURLErrorKey : URLString
            }];
        }
        return nil;
    }
    
    NSURLRequestCachePolicy cachePolicy = (self.reachabilityManager.reachable)? NSURLRequestUseProtocolCachePolicy : NSURLRequestReturnCacheDataElseLoad;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:cachePolicy timeoutInterval:10];
    [request setHTTPMethod:method];
    
    NSError __autoreleasing *e = nil;
    request = [[self.requestSerializer requestBySerializingRequest:request withParameters:parameters error:&e] mutableCopy];
    if (e) {
        if (error) {
#if RFDEBUG
            dout_error(@"无法序列化参数\n请检查代码是否正确");
#endif
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:@{
                NSLocalizedDescriptionKey : @"内部错误，无法创建请求",
                NSLocalizedFailureReasonErrorKey : @"很可能是应用bug",
                NSLocalizedRecoverySuggestionErrorKey : @"请再试一次，如果依旧请尝试重启应用。给您带来不便，敬请谅解",
                NSURLErrorFailingURLErrorKey : URLString
            }];
        }
        return nil;
    }
    
    [headers enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL *__unused stop) {
        [request setValue:value forHTTPHeaderField:field];
    }];
    
	return request;
}

@end

NSString *const RFAPIMessageControlKey = @"RFAPIControlInfoMessage";
NSString *const RFAPIIdentifierControlKey = @"RFAPIControlInfoIdentifier";
NSString *const RFAPIGroupIdentifierControlKey = @"RFAPIControlInfoGroupIdentifier";

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
