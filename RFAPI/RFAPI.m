
#import "RFAPI.h"
#import "RFAssetsCache.h"
#import "RFMessageManager+RFDisplay.h"
#import "RFAPIDefineManager.h"

#import "AFHTTPRequestOperation.h"
#import "AFNetworkReachabilityManager.h"
#import "AFNetworkActivityIndicatorManager.h"

RFDefineConstString(RFAPIErrorDomain);
static NSString *RFAPIOperationUIkControl = @"RFAPIOperationUIkControl";

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

#pragma mark - Request management

#if RFDebugLevel > RFDebugLevelInfo
- (void)addOperation:(NSOperation *)op {
    dout_debug(@"Add HTTP request operation(%p) with info: %@", op, [op valueForKeyPath:@"userInfo.RFAPIOperationUIkControl"]);
    [super addOperation:op];
}
#endif

- (void)cancelOperationWithIdentifier:(NSString *)identifier {
    for (AFHTTPRequestOperation *op in [self operationsWithIdentifier:identifier]) {
        dout_debug(@"Cancel HTTP request operation(%p) with identifier: %@", op, identifier);
        [op cancel];
    }
}

- (void)cancelOperationsWithGroupIdentifier:(NSString *)identifier {
    for (AFHTTPRequestOperation *op in [self operationsWithGroupIdentifier:identifier]) {
        dout_debug(@"Cancel HTTP request operation(%p) with group identifier: %@", op, identifier);
        [op cancel];
    }
}

- (NSArray *)operationsWithIdentifier:(NSString *)identifier {
    return [self.operations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K.%K.%K == %@", @keypathClassInstance(AFHTTPRequestOperation, userInfo), RFAPIOperationUIkControl, @keypathClassInstance(RFAPIControl, identifier), identifier]];
}

- (NSArray *)operationsWithGroupIdentifier:(NSString *)identifier {
    return [self.operations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K.%K.%K == %@", @keypathClassInstance(AFHTTPRequestOperation, userInfo), RFAPIOperationUIkControl, @keypathClassInstance(RFAPIControl, groupIdentifier), identifier]];
}

#pragma mark - Request

#define __RFAPICompletionCallback(BLOCK, ...)\
    if (BLOCK) {\
        BLOCK(__VA_ARGS__);\
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
        __RFAPICompletionCallback(operationFailure, op, error);\
        __RFAPICompletionCallback(operationCompletion, op);\
        return;\
    }

- (AFHTTPRequestOperation *)requestWithName:(NSString *)APIName parameters:(NSDictionary *)parameters controlInfo:(RFAPIControl *)controlInfo success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure completion:(void (^)(AFHTTPRequestOperation *))completion {
    NSParameterAssert(APIName);
    RFAPIDefine *define = [self.defineManager defineForName:APIName];
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
    if (controlInfo) {
        operation.userInfo = @{ RFAPIOperationUIkControl : controlInfo };
    }

    void (^operationFailure)(id, NSError*) = ^(AFHTTPRequestOperation *blockOp, NSError *blockError) {

        if (blockError.code == NSURLErrorCancelled && blockError.domain == NSURLErrorDomain) {
            dout_info(@"A HTTP operation cancelled: %@", blockOp);
            return;
        }

        if ([self generalHandlerForError:blockError withDefine:define controlInfo:controlInfo requestOperation:blockOp operationFailureCallback:failure]) {
            if (failure) {
                failure(blockOp, blockError);
            }
            else {
                [self.networkActivityIndicatorManager alertError:blockError title:@"请求失败"];
            }
        };
    };

    RFNetworkActivityIndicatorMessage *message = controlInfo.message;
    void (^operationCompletion)(id) = ^(AFHTTPRequestOperation *blockOp){
        NSString *mid = message.identifier;
        if (mid) {
            [self.networkActivityIndicatorManager hideWithIdentifier:mid];
        }

        if (completion) {
            completion(blockOp);
        }
    };

    Class expectClass = define.responseClass;
    if (message) {
        [self.networkActivityIndicatorManager showMessage:message];
    }
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id responseObject) {
        dout_debug(@"HTTP request operation(%p) with info: %@ completed.", op, [op valueForKeyPath:@"userInfo.RFAPIOperationUIkControl"]);

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
        _douto(responseObject)
        __RFAPICompletionCallback(success, op, responseObject);
        __RFAPICompletionCallback(operationCompletion, op);
    } failure:^(AFHTTPRequestOperation *op, NSError *error) {
        __RFAPICompletionCallback(operationFailure, op, error);
        __RFAPICompletionCallback(operationCompletion, op);
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

    // TODO: Full cache policy implementation.
    NSURLRequestCachePolicy cachePolicy = NSURLRequestUseProtocolCachePolicy;
    if (self.reachabilityManager.reachable) {
        switch (define.cachePolicy) {
            case RFAPICachePolicyAlways:
                cachePolicy = NSURLRequestReturnCacheDataDontLoad;
                break;

            case RFAPICachePolicyNoCache:
                cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
                break;

            case RFAPICachePolicyExpire:
                // TODO: similar, but not right
                cachePolicy = NSURLRequestReturnCacheDataElseLoad;
                break;
                
            default:
                break;
        }
    }
    else {
        switch (define.offlinePolicy) {
            case RFAPOfflinePolicyLoadCache:
                cachePolicy = NSURLRequestReturnCacheDataElseLoad;
                break;
                
            default:
                break;
        }
    }

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

    r = [self customSerializedRequest:r withDefine:define];

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

- (BOOL)generalHandlerForError:(NSError *)error withDefine:(RFAPIDefine *)define controlInfo:(RFAPIControl *)controlInfo requestOperation:(AFHTTPRequestOperation *)operation operationFailureCallback:(void (^)(AFHTTPRequestOperation *, NSError *))operationFailureCallback {
    return YES;
}

- (void)alertError:(NSError *)error title:(NSString *)title {
    [self.networkActivityIndicatorManager alertError:error title:title];
}

@end

NSString *const RFAPIMessageControlKey = @"_RFAPIMessageControl";
NSString *const RFAPIIdentifierControlKey = @"_RFAPIIdentifierControl";
NSString *const RFAPIGroupIdentifierControlKey = @"_RFAPIGroupIdentifierControl";
NSString *const RFAPIBackgroundTaskControlKey = @"_RFAPIBackgroundTaskControl";
NSString *const RFAPIRequestCustomizationControlKey = @"_RFAPIRequestCustomizationControl";

@implementation RFAPIControl

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, identifier = %@, groupIdentifier = %@>", self.class, self, self.identifier, self.groupIdentifier];
}

- (id)initWithDictionary:(NSDictionary *)info {
    self = [super init];
    if (self) {
        _message = info[RFAPIMessageControlKey];
        _identifier = info[RFAPIIdentifierControlKey];
        _groupIdentifier = info[RFAPIGroupIdentifierControlKey];
        _backgroundTask = [info[RFAPIBackgroundTaskControlKey] boolValue];
        _requestCustomization = info[RFAPIRequestCustomizationControlKey];
    }
    return self;
}

- (id)initWithIdentifier:(NSString *)identifier loadingMessage:(NSString *)message {
    self = [super init];
    if (self) {
        _identifier = identifier;
        _message = [[RFNetworkActivityIndicatorMessage alloc] initWithIdentifier:identifier title:nil message:message status:RFNetworkActivityIndicatorStatusLoading];
    }
    return self;
}

@end

@implementation RFHTTPRequestFormData

@end
