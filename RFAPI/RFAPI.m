
#import "RFRuntime.h"
#import "RFAPI.h"
#import "RFMessageManager+RFDisplay.h"
#import "RFAPIDefineManager.h"

#import "AFHTTPRequestOperation.h"
#import "AFURLRequestSerialization.h"
#import "AFURLResponseSerialization.h"
#import "AFNetworkReachabilityManager.h"
#import "AFSecurityPolicy.h"
#import "JSONModel.h"
#import "NSFileManager+RFKit.h"

RFDefineConstString(RFAPIErrorDomain);
static NSString *RFAPIOperationUIkControl = @"RFAPIOperationUIkControl";
NSString *const RFAPIRequestArrayParameterKey = @"_RFArray_";
NSString *const RFAPIRequestForceQuryStringParametersKey = @"RFAPIRequestForceQuryStringParametersKey";


@interface RFAPI ()
@property (strong, readwrite) AFNetworkReachabilityManager *reachabilityManager;
@property (strong, readwrite) RFAPIDefineManager *defineManager;
@property (strong, readwrite) RFAPICacheManager *cacheManager;
@end

@implementation RFAPI
RFInitializingRootForNSObject

- (void)onInit {
    self.reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    self.maxConcurrentOperationCount = 5;
    self.defineManager = [[RFAPIDefineManager alloc] init];
    self.defineManager.master = self;

    self.securityPolicy = [AFSecurityPolicy defaultPolicy];
    self.shouldUseCredentialStorage = YES;

    // As most request are API reqest, we dont need too much space
    self.cacheManager = [[RFAPICacheManager alloc] initWithMemoryCapacity:500 * 1000 diskCapacity:10 * 1000 * 1000 diskPath:@"com.github.RFUI.RFAPICache"];
    self.cacheManager.reachabilityManager = self.reachabilityManager;
}

- (void)afterInit {
    [self.reachabilityManager startMonitoring];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p, operations: %@>", self.class, (void *)self, self.operations];
}

#pragma mark - Request management

- (void)cancelOperationWithIdentifier:(nullable NSString *)identifier {
    for (AFHTTPRequestOperation *op in [self operationsWithIdentifier:identifier]) {
        _dout_debug(@"Cancel HTTP request operation(%p) with identifier: %@", (void *)op, identifier);
        [op cancel];
    }
}

- (void)cancelOperationsWithGroupIdentifier:(nullable NSString *)identifier {
    for (AFHTTPRequestOperation *op in [self operationsWithGroupIdentifier:identifier]) {
        _dout_debug(@"Cancel HTTP request operation(%p) with group identifier: %@", (void *)op, identifier);
        [op cancel];
    }
}

- (nonnull NSArray<AFHTTPRequestOperation *> *)operationsWithIdentifier:(nullable NSString *)identifier {
    @autoreleasepool {
        return [self.operations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K.%K.%K == %@", @keypathClassInstance(AFHTTPRequestOperation, userInfo), RFAPIOperationUIkControl, @keypathClassInstance(RFAPIControl, identifier), identifier]];
    }
}

- (nonnull NSArray<AFHTTPRequestOperation *> *)operationsWithGroupIdentifier:(nullable NSString *)identifier {
    @autoreleasepool {
        return [self.operations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K.%K.%K == %@", @keypathClassInstance(AFHTTPRequestOperation, userInfo), RFAPIOperationUIkControl, @keypathClassInstance(RFAPIControl, groupIdentifier), identifier]];
    }
}

#pragma mark - Request

#define RFAPICompletionCallback_(BLOCK, ...)\
    if (BLOCK) {\
        BLOCK(__VA_ARGS__);\
    }

#if RFDEBUG
#   define RFAPILogError_(DEBUG_ERROR, ...) dout_error(DEBUG_ERROR, __VA_ARGS__);
#else
#   define RFAPILogError_(DEBUG_ERROR, ...)
#endif

#define RFAPICompletionCallback_ProccessError(CONDITION, DEBUG_ERROR, DEBUG_ARG, ERROR_DESCRIPTION, ERROR_FAILUREREASON, ERROR_RECOVERYSUGGESTION)\
    if (CONDITION) {\
        RFAPILogError_(DEBUG_ERROR, DEBUG_ARG);\
        error = [NSError errorWithDomain:RFAPIErrorDomain code:0 userInfo:@{ NSLocalizedDescriptionKey: ERROR_DESCRIPTION, NSLocalizedFailureReasonErrorKey: ERROR_FAILUREREASON, NSLocalizedRecoverySuggestionErrorKey: ERROR_RECOVERYSUGGESTION }];\
        RFAPICompletionCallback_(operationFailure, op, error);\
        return;\
    }

- (nullable AFHTTPRequestOperation *)requestWithName:(nonnull NSString *)APIName parameters:(NSDictionary *)parameters formData:(nullable NSArray<RFHTTPRequestFormData *> *)arrayContainsFormDataObj controlInfo:(nullable RFAPIControl *)controlInfo uploadProgress:(void (^_Nullable)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progress success:(void (^_Nullable )(AFHTTPRequestOperation *_Nullable operation, id _Nullable responseObject))success failure:(void (^_Nullable)(AFHTTPRequestOperation *_Nullable operation, NSError *_Nonnull error))failure completion:(void (^_Nullable)(AFHTTPRequestOperation *_Nullable operation))completion {
    NSParameterAssert(APIName);
    RFAPIDefine *define = [self.defineManager defineForName:APIName];
    RFAssert(define, @"Can not find an API with name: %@.", APIName);
    if (!define) return nil;

    NSError __autoreleasing *e = nil;
    NSMutableURLRequest *request = [self URLRequestWithDefine:define parameters:parameters formData:arrayContainsFormDataObj controlInfo:controlInfo error:&e];
    if (!request) {
        RFAPILogError_(@"无法创建请求: %@", e);
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:@{
            NSLocalizedDescriptionKey : @"内部错误，无法创建请求",
            NSLocalizedFailureReasonErrorKey : @"很可能是应用 bug",
            NSLocalizedRecoverySuggestionErrorKey : @"请再试一次，如果依旧请尝试重启应用。给您带来不便，敬请谅解"
        }];

        RFAPICompletionCallback_(failure, nil, error);
        RFAPICompletionCallback_(completion, nil);
        return nil;
    }

    // Request object get ready.
    // Build operation block.
    RFNetworkActivityIndicatorMessage *message = controlInfo.message;
    void (^operationCompletion)(id) = ^(AFHTTPRequestOperation *blockOp) {
        dispatch_async_on_main(^{
            NSString *mid = message.identifier;
            if (mid) {
                [self.networkActivityIndicatorManager hideWithIdentifier:mid];
            }

            if (completion) {
                completion(blockOp);
            }
        });
    };

    void (^operationSuccess)(id, id) = ^(AFHTTPRequestOperation *blockOp, id blockResponse) {
        dispatch_async_on_main(^{
            if (success) {
                success(blockOp, blockResponse);
            }
            operationCompletion(blockOp);
        });
    };

    void (^operationFailure)(id, NSError*) = ^(AFHTTPRequestOperation *blockOp, NSError *blockError) {
        dispatch_async_on_main(^{
            if (blockError.code == NSURLErrorCancelled && blockError.domain == NSURLErrorDomain) {
                dout_info(@"A HTTP operation cancelled: %@", blockOp);
                operationCompletion(blockOp);
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
            operationCompletion(blockOp);
        });
    };

    // Check cache
    NSCachedURLResponse *cachedResponse = [self.cacheManager cachedResponseForRequest:request define:define control:controlInfo];
    if (cachedResponse) {
        dout_debug(@"Cache(%@) vaild for request: %@", cachedResponse, request);
        AFHTTPResponseSerializer *serializer = [self.defineManager responseSerializerForDefine:define];

        NSError *error = nil;
        id _Nullable responseObject = [serializer responseObjectForResponse:cachedResponse.response data:cachedResponse.data error:&error];
        if (error) {
            dispatch_async(self.responseProcessingQueue, ^{
                operationFailure(nil, error);
            });
            return nil;
        }

        dispatch_async(self.responseProcessingQueue, ^{
            [self processingCompletionWithHTTPOperation:nil responseObject:responseObject define:define control:controlInfo success:operationSuccess failure:operationFailure];
        });
        return nil;
    }

    // Setup HTTP operation
    AFHTTPRequestOperation *operation = [self requestOperationWithRequest:request define:define controlInfo:controlInfo];
    operation.completionQueue = self.responseProcessingQueue;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *_Nonnull op, id _Nullable responseObject) {
        @autoreleasepool {
            dout_debug(@"HTTP request operation(%p) with info: %@ completed.", (void *)op, [op valueForKeyPath:@"userInfo.RFAPIOperationUIkControl"]);

            [self processingCompletionWithHTTPOperation:op responseObject:responseObject define:define control:controlInfo success:operationSuccess failure:operationFailure];
            [self.cacheManager storeCachedResponseForRequest:op.request response:op.response data:op.responseData define:define control:controlInfo];
        }
    } failure:^(AFHTTPRequestOperation *_Nonnull op, NSError *_Nonnull error) {
        operationFailure(op, error);
    }];

    if (progress) {
        [operation setUploadProgressBlock:progress];
    }

    // Start request
    if (message) {
        dispatch_sync_on_main(^{
            [self.networkActivityIndicatorManager showMessage:message];
        });
    }
    [self addOperation:operation];
    return operation;
}

- (AFHTTPRequestOperation *)requestWithName:(nonnull NSString *)APIName parameters:(NSDictionary *)parameters controlInfo:(RFAPIControl *)controlInfo success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure completion:(void (^)(AFHTTPRequestOperation *))completion {
    return [self requestWithName:APIName parameters:parameters formData:nil controlInfo:controlInfo uploadProgress:nil success:success failure:failure completion:completion];
}

- (void)invalidateCacheWithName:(nullable NSString *)APIName parameters:(nullable NSDictionary *)parameters {
    if (!APIName.length) return;

    RFAPIDefine *define = [self.defineManager defineForName:APIName];
    if (!define) return;

    NSError __autoreleasing *e = nil;
    NSURLRequest *request = [self URLRequestWithDefine:define parameters:parameters formData:nil controlInfo:nil error:&e];
    if (e) dout_error(@"%@", e);

    [self.cacheManager removeCachedResponseForRequest:request];
}

#pragma mark - Build Request

#define RFAPIMakeRequestError_(CONDITION)\
    if (CONDITION) {\
        if (error) {\
            *error = e;\
        }\
        return nil;\
    }

- (nullable NSMutableURLRequest *)URLRequestWithDefine:(nonnull RFAPIDefine *)define parameters:(nullable NSDictionary *)parameters formData:(nullable NSArray *)RFFormData controlInfo:(nullable RFAPIControl *)controlInfo error:(NSError *_Nullable __autoreleasing *_Nullable)error {
    NSParameterAssert(define);

    // Preprocessing arguments
    NSMutableDictionary *requestParameters = [NSMutableDictionary new];
    NSMutableDictionary *requestHeaders = [NSMutableDictionary new];
    [self preprocessingRequestParameters:&requestParameters HTTPHeaders:&requestHeaders withParameters:(NSDictionary *)parameters define:define controlInfo:controlInfo];

    // Creat URL
    NSError __autoreleasing *e = nil;
    NSURL *url = [self.defineManager requestURLForDefine:define parameters:requestParameters error:&e];
    RFAPIMakeRequestError_(!url);

    // Creat URLRequest
    NSMutableURLRequest *r;
    AFHTTPRequestSerializer *s = [self.defineManager requestSerializerForDefine:define];
    if (RFFormData.count) {
        NSString *urlString = url.absoluteString;
        r = [s multipartFormRequestWithMethod:define.method URLString:urlString parameters:requestParameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            for (RFHTTPRequestFormData *file in RFFormData) {
                NSError __autoreleasing *f_e = nil;
                [file buildFormData:formData error:&f_e];
                if (f_e) dout_error(@"%@", f_e);
            }
        } error:&e];
    }
    else {
        NSURLRequestCachePolicy cachePolicy = [self.cacheManager cachePolicyWithDefine:define control:controlInfo];
        r = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:cachePolicy timeoutInterval:40];
        [r setHTTPMethod:define.method];
        NSArray *arrayParameter = requestParameters[RFAPIRequestArrayParameterKey];
        r = [[s requestBySerializingRequest:r withParameters:arrayParameter?: requestParameters error:&e] mutableCopy];
    }
    RFAPIMakeRequestError_(!r);

    // Set header
    [requestHeaders enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL *__unused stop) {
        [r setValue:value forHTTPHeaderField:field];
    }];

    // Finalization
    r = [self finalizeSerializedRequest:r withDefine:define controlInfo:controlInfo];
    return r;
}

- (void)preprocessingRequestParameters:(NSMutableDictionary *_Nullable *_Nonnull)requestParameters HTTPHeaders:(NSMutableDictionary *_Nullable *_Nonnull)requestHeaders withParameters:(nullable NSDictionary *)parameters define:(nonnull RFAPIDefine *)define controlInfo:(nullable RFAPIControl *)controlInfo {
    BOOL needsAuthorization = define.needsAuthorization;

    [*requestParameters addEntriesFromDictionary:define.defaultParameters];
    if (needsAuthorization) {
        [*requestParameters addEntriesFromDictionary:self.defineManager.authorizationParameters];
    }
    if (parameters) {
        [*requestParameters addEntriesFromDictionary:(NSDictionary *)parameters];
    }

    [*requestHeaders addEntriesFromDictionary:define.HTTPRequestHeaders];
    if (needsAuthorization) {
        [*requestHeaders addEntriesFromDictionary:self.defineManager.authorizationHeader];
    }
}

- (nullable NSMutableURLRequest *)finalizeSerializedRequest:(nonnull NSMutableURLRequest *)request withDefine:(nonnull RFAPIDefine *)define controlInfo:(nullable RFAPIControl *)controlInfo {
    if (controlInfo.requestCustomization) {
        return controlInfo.requestCustomization(request);
    }
    return request;
}

- (nonnull AFHTTPRequestOperation *)requestOperationWithRequest:(nonnull NSURLRequest *)request define:(nonnull RFAPIDefine *)define controlInfo:(nullable RFAPIControl *)controlInfo {
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [self.defineManager responseSerializerForDefine:define];
    operation.shouldUseCredentialStorage = self.shouldUseCredentialStorage;
    operation.credential = self.credential;
    operation.securityPolicy = self.securityPolicy;
    if (controlInfo) {
        operation.userInfo = @{ RFAPIOperationUIkControl : controlInfo };
    }
    return operation;
}

#pragma mark - Handel Response

- (dispatch_queue_t)responseProcessingQueue {
    if (_responseProcessingQueue) return _responseProcessingQueue;
    _responseProcessingQueue = dispatch_get_main_queue();
    return _responseProcessingQueue;
}

- (void)processingCompletionWithHTTPOperation:(nullable AFHTTPRequestOperation *)op responseObject:(nullable id)responseObject define:(nonnull RFAPIDefine *)define control:(nullable RFAPIControl *)control success:(void (^_Nonnull)(AFHTTPRequestOperation *_Nullable, id _Nullable))operationSuccess failure:(void (^_Nonnull)(id _Nullable, NSError *_Nonnull))operationFailure {

    if ((!responseObject || responseObject == [NSNull null])
        && define.responseAcceptNull) {
        operationSuccess(op, nil);
        return;
    }
    Class expectClass = define.responseClass;
    NSError *error = nil;
    switch (define.responseExpectType) {
        case RFAPIDefineResponseExpectObject: {
            RFAPICompletionCallback_ProccessError(![responseObject isKindOfClass:[NSDictionary class]], @"期望的数据类型是字典，而实际是 %@\n请先确认一下代码，如果服务器没按要求返回请联系后台人员", [responseObject class], @"返回数据异常", @"可能服务器正在升级或者维护，也可能是应用bug", @"建议稍后重试，如果持续报告这个错误请检查AppStore是否有新版本");

            NSError __autoreleasing *e = nil;
            id JSONModelObject = [[expectClass alloc] initWithDictionary:responseObject error:&e];
            RFAPICompletionCallback_ProccessError(!JSONModelObject, @"不能将返回内容转换为Model：%@\n请先确认一下代码，如果服务器没按要求返回请联系后台人员", e, @"返回数据异常", @"可能服务器正在升级或者维护，也可能是应用bug", @"建议稍后重试，如果持续报告这个错误请检查AppStore是否有新版本");
            responseObject = JSONModelObject;
            break;
        }
        case RFAPIDefineResponseExpectObjects: {
            RFAPICompletionCallback_ProccessError(![responseObject isKindOfClass:[NSArray class]], @"期望的数据类型是数组，而实际是 %@\n", [responseObject class], @"返回数据异常", @"可能服务器正在升级或者维护，也可能是应用bug", @"建议稍后重试，如果持续报告这个错误请检查AppStore是否有新版本");

            NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[responseObject count]];
            for (NSDictionary *info in responseObject) {
                id obj = [[expectClass alloc] initWithDictionary:info error:&error];
                RFAPICompletionCallback_ProccessError(!obj, @"不能将数组中的元素转换为Model %@\n请先确认一下代码，如果服务器没按要求返回请联系后台人员", error, @"返回数据异常", @"可能服务器正在升级或者维护，也可能是应用bug", @"建议稍后重试，如果持续报告这个错误请检查AppStore是否有新版本")
                else {
                    [objects addObject:obj];
                }
            }
            responseObject = objects;
            break;
        }
        case RFAPIDefineResponseExpectSuccess: {
            if (![self isSuccessResponse:&responseObject error:&error]) {
                operationFailure(op, error);
                return;
            }
            break;
        }
        case RFAPIDefineResponseExpectDefault:
        default:
            break;
    }
    _douto(responseObject)
    operationSuccess(op, responseObject);
}

- (BOOL)generalHandlerForError:(nonnull NSError *)error withDefine:(nonnull RFAPIDefine *)define controlInfo:(nullable RFAPIControl *)controlInfo requestOperation:(nullable AFHTTPRequestOperation *)operation operationFailureCallback:(void (^_Nullable)(AFHTTPRequestOperation *_Nullable, NSError *_Nonnull))operationFailureCallback {
    return YES;
}

- (BOOL)isSuccessResponse:(id _Nullable __strong *_Nonnull)responseObjectRef error:(NSError *_Nullable __autoreleasing *_Nullable)error {
    return YES;
}

@end


#pragma mark - RFAPIControl
NSString *const RFAPIMessageControlKey = @"_RFAPIMessageControl";
NSString *const RFAPIIdentifierControlKey = @"_RFAPIIdentifierControl";
NSString *const RFAPIGroupIdentifierControlKey = @"_RFAPIGroupIdentifierControl";
NSString *const RFAPIBackgroundTaskControlKey = @"_RFAPIBackgroundTaskControl";
NSString *const RFAPIRequestCustomizationControlKey = @"_RFAPIRequestCustomizationControl";

@implementation RFAPIControl

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, identifier = %@, groupIdentifier = %@>", self.class, (void *)self, self.identifier, self.groupIdentifier];
}

- (nonnull id)initWithDictionary:(nonnull NSDictionary *)info {
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

- (nonnull id)initWithIdentifier:(nonnull NSString *)identifier loadingMessage:(nullable NSString *)message {
    self = [super init];
    if (self) {
        _identifier = identifier;
        _message = [[RFNetworkActivityIndicatorMessage alloc] initWithIdentifier:identifier title:nil message:message status:RFNetworkActivityIndicatorStatusLoading];
    }
    return self;
}

@end

#pragma mark - RFHTTPRequestFormData

typedef NS_ENUM(short, RFHTTPRequestFormDataSourceType) {
    RFHTTPRequestFormDataSourceTypeURL = 0,
    RFHTTPRequestFormDataSourceTypeStream,
    RFHTTPRequestFormDataSourceTypeData
};

@interface RFHTTPRequestFormData ()
@property RFHTTPRequestFormDataSourceType type;
@end

@implementation RFHTTPRequestFormData

+ (nonnull instancetype)formDataWithFileURL:(nonnull NSURL *)fileURL name:(nonnull NSString *)name {
    NSParameterAssert(fileURL);
    NSParameterAssert(name);
    RFHTTPRequestFormData *this = [RFHTTPRequestFormData new];
    this.fileURL = fileURL;
    this.name = name;
    this.type = RFHTTPRequestFormDataSourceTypeURL;
    return this;
}

+ (nonnull instancetype)formDataWithData:(nonnull NSData *)data name:(nonnull NSString *)name {
    NSParameterAssert(data);
    NSParameterAssert(name);
    RFHTTPRequestFormData *this = [RFHTTPRequestFormData new];
    this.data = data;
    this.name = name;
    this.type = RFHTTPRequestFormDataSourceTypeData;
    return this;
}

+ (nonnull instancetype)formDataWithData:(nonnull NSData *)data name:(nonnull NSString *)name fileName:(nullable NSString *)fileName mimeType:(nullable NSString *)mimeType {
    NSParameterAssert(data);
    NSParameterAssert(name);
    RFHTTPRequestFormData *this = [RFHTTPRequestFormData new];
    this.data = data;
    this.name = name;
    this.fileName = fileName;
    this.mimeType = mimeType;
    this.type = RFHTTPRequestFormDataSourceTypeData;
    return this;
}

- (void)buildFormData:(nonnull id<AFMultipartFormData>)formData error:(NSError *_Nullable __autoreleasing *_Nullable)error {
    switch (self.type) {
        case RFHTTPRequestFormDataSourceTypeURL: {
            NSURL *fileURL = self.fileURL;
            [formData appendPartWithFileURL:fileURL name:self.name error:error];
            break;
        }
        case RFHTTPRequestFormDataSourceTypeData: {
            NSData *data = self.data;
            if (self.fileName
                && self.mimeType) {
                [formData appendPartWithFileData:data name:self.name fileName:(NSString *)self.fileName mimeType:(NSString *)self.mimeType];
            }
            else {
                [formData appendPartWithFormData:data name:self.name];
            }
            break;
        }
        default:
            break;
    }
}

@end
