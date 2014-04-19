
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

extern NSString *const RFAPIDefineDefaultKey;

@interface RFAPI ()
@property (strong, nonatomic, readwrite) AFNetworkReachabilityManager *reachabilityManager;
@property (strong, nonatomic, readwrite) RFAPIDefineManager *defineManager;
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

- (void)updateDefaultRule:(NSDictionary *)rule merge:(BOOL)isMerge {
    if (!rule) return;
    RFAPIDefineManager *m = self.defineManager;

    if (isMerge) {
        [m.defaultRule addEntriesFromDictionary:rule];
    }
    else {
        [m.defaultRule setDictionary:rule];
    }
    [m setNeedsUpdateDefaultRule];
}

- (void)setAPIDefineWithRules:(NSDictionary *)rules {
    [self.defineManager mergeWithRules:rules];
}

- (RFAPIDefine *)defineForName:(NSString *)APIName {
    return [self.defineManager defineForName:APIName];
}

#pragma mark - Request management

- (void)cancelOperationWithIdentifier:(NSString *)identifier {
    [self.networkActivityIndicatorManager hideWithIdentifier:identifier];
}

- (void)cancelOperationsWithGroupIdentifier:(NSString *)identifier {
    [self.networkActivityIndicatorManager hideWithGroupIdentifier:identifier];
}

#pragma mark - Request

- (AFHTTPRequestSerializer<AFURLRequestSerialization> *)requestSerializer {
    if (!_requestSerializer) {
        _requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    return _requestSerializer;
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

#if RFDEBUG
#   define __RFAPILogError(DEBUG_ERROR, ...) dout_error(DEBUG_ERROR, __VA_ARGS__);
#else
#   define __RFAPILogError(DEBUG_ERROR, ...)
#endif

#define __RFAPICompletionCallbackProccessError(CONDITION, DEBUG_ERROR, DEBUG_ARG, ERROR_DESCRIPTION, ERROR_FAILUREREASON, ERROR_RECOVERYSUGGESTION)\
    if (CONDITION) {\
        __RFAPILogError(DEBUG_ERROR, DEBUG_ARG);\
        error = [NSError errorWithDomain:RFAPIErrorDomain code:0 userInfo:@{ NSLocalizedDescriptionKey: ERROR_DESCRIPTION, NSLocalizedFailureReasonErrorKey: ERROR_FAILUREREASON, NSLocalizedRecoverySuggestionErrorKey: ERROR_RECOVERYSUGGESTION }];\
        __RFAPICompletionCallback(failure, op, error);\
        __RFAPICompletionCallback(completion, op);\
        return;\
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
        NSError *error = nil;
        switch (define.responseExpectType) {
            case RFAPIDefineResponseExpectObject: {
                __RFAPICompletionCallbackProccessError(![responseObject isKindOfClass:[NSDictionary class]], @"期望的数据类型是字典，而实际是 %@\n请先确认一下代码，如果服务器没按要求返回请联系后台人员", [responseObject class], @"返回数据异常", @"可能服务器正在升级或者维护，也可能是应用bug", @"建议稍后重试，如果持续报告这个错误请检查应用是否有新版本");

                NSError __autoreleasing *e = nil;
                id JSONModelObject = [[expectClass alloc] initWithDictionary:responseObject error:&e];
                __RFAPICompletionCallbackProccessError(!JSONModelObject, @"不能将返回内容转换为Model：%@\n请先确认一下代码，如果服务器没按要求返回请联系后台人员", e, @"返回数据异常", @"可能服务器正在升级或者维护，也可能是应用bug", @"建议稍后重试，如果持续报告这个错误请检查应用是否有新版本");
                responseObject = JSONModelObject;
                break;
            }
            case RFAPIDefineResponseExpectObjects: {
                __RFAPICompletionCallbackProccessError(![responseObject isKindOfClass:[NSArray class]], @"期望的数据类型是数组，而实际是 %@\n", [responseObject class], @"返回数据异常", @"可能服务器正在升级或者维护，也可能是应用bug", @"建议稍后重试，如果持续报告这个错误请检查应用是否有新版本");

                NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[responseObject count]];
                for (NSDictionary *info in responseObject) {
                    id obj = [[expectClass alloc] initWithDictionary:info error:&error];
                    __RFAPICompletionCallbackProccessError(!obj, @"不能将数组中的元素转换为Model %@\n请先确认一下代码，如果服务器没按要求返回请联系后台人员", error, @"返回数据异常", @"可能服务器正在升级或者维护，也可能是应用bug", @"建议稍后重试，如果持续报告这个错误请检查应用是否有新版本")
                    else {
                        [objects addObject:obj];
                    }
                }
                responseObject = objects;
                break;
            }
            case RFAPIDefineResponseExpectSuccess:
            case RFAPIDefineResponseExpectDefault:
            default:
                break;
        }
        douto(responseObject)
        __RFAPICompletionCallback(success, op, responseObject);
        __RFAPICompletionCallback(completion, op);
    } failure:^(AFHTTPRequestOperation *op, NSError *error) {
        __RFAPICompletionCallback(failure, op, error);
        __RFAPICompletionCallback(completion, op);
    }];

    [self addOperation:operation];
    return operation;
}
#undef __RFAPICompletionCallback
#undef __RFAPILogError
#undef __RFAPICompletionCallbackProccessError

#define __RFAPIMakeRequestError(CONDITION)\
    if (CONDITION) {\
        if (error) {\
            *error = e;\
        }\
        return nil;\
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

    if (define.defaultParameters) {
        NSDictionary *new = parameters;
        parameters = [define.defaultParameters mutableCopy];
        [(NSMutableDictionary *)parameters addEntriesFromDictionary:new];
    }
    r = [[s requestBySerializingRequest:r withParameters:parameters error:&e] mutableCopy];
    __RFAPIMakeRequestError(!r);

    [define.HTTPRequestHeaders enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL *__unused stop) {
        [r setValue:value forHTTPHeaderField:field];
    }];

    if (controlInfo.requestCustomization) {
        r = controlInfo.requestCustomization(r);
    }

    return r;
}
#undef __RFAPIMakeRequestError

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
