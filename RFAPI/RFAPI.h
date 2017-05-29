/*!
    RFAPI

    Copyright (c) 2014-2016 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Alpha
 */
#import "RFUI.h"
#import "RFAPIDefine.h"
#import "RFAPIDefineManager.h"
#import "RFAPICacheManager.h"

@class AFNetworkReachabilityManager;
@class AFSecurityPolicy;
@protocol AFMultipartFormData;

@class RFMessageManager, RFNetworkActivityIndicatorMessage, AFHTTPRequestOperation;
@class RFAPIControl, RFHTTPRequestFormData;


@interface RFAPI : NSOperationQueue <
    RFInitializing
>

/**
 Defult shared manager
 */
@property (nonnull, readonly) AFNetworkReachabilityManager *reachabilityManager;

/**
 @bug RFAPI cache management only works on iOS 7.
 */
@property (nonnull, readonly) RFAPICacheManager *cacheManager;

#pragma mark - Define

@property (nonnull, readonly) RFAPIDefineManager *defineManager;

#pragma mark - Request management

- (nonnull NSArray<AFHTTPRequestOperation *> *)operationsWithIdentifier:(nullable NSString *)identifier;
- (nonnull NSArray<AFHTTPRequestOperation *> *)operationsWithGroupIdentifier:(nullable NSString *)identifier;

- (void)cancelOperationWithIdentifier:(nullable NSString *)identifier;
- (void)cancelOperationsWithGroupIdentifier:(nullable NSString *)identifier;

#pragma mark - Activity Indicator

@property (nullable, strong) RFMessageManager *networkActivityIndicatorManager;

#pragma mark - Request

// 如果传一个特殊请求，直接创建一个 AFHTTPRequestOperation 并加进来也许更合适

/**
 Creat and send a HTTP request.

 @discussion 当请求取消时，success 和 failure 都不会被调用，只有 completion 会被调用。请求从缓存读取时，几个 block 回调中的 operation 参数会为空。

 @param APIName     接口名
 @param parameters  请求的参数
 @param controlInfo 控制接口行为的结构体
 @param success     请求成功回调的 block，可为空
 @param failure     请求失败回调的 block，可为空。为空时将用默认的方法显示错误信息
 @param completion  请求完成回掉的 block，必定会被调用（即使请求创建失败），会在 success 和 failure 回调后执行。被设计用来执行通用的清理。可为空。
 */
- (nullable AFHTTPRequestOperation *)requestWithName:(nonnull NSString *)APIName
     parameters:(nullable NSDictionary *)parameters
    controlInfo:(nullable RFAPIControl *)controlInfo
        success:(void (^_Nullable)(AFHTTPRequestOperation *_Nullable operation, id _Nullable responseObject))success
        failure:(void (^_Nullable)(AFHTTPRequestOperation *_Nullable operation, NSError *_Nonnull error))failure
     completion:(void (^_Nullable)(AFHTTPRequestOperation *_Nullable operation))completion;

/**
 上传文件

 @param arrayContainsFormDataObj 包含 RFHTTPRequestFormData 对象的数组
 */
- (nullable AFHTTPRequestOperation *)requestWithName:(nonnull NSString *)APIName
     parameters:(nullable NSDictionary *)parameters
       formData:(nullable NSArray<RFHTTPRequestFormData *> *)arrayContainsFormDataObj
    controlInfo:(nullable RFAPIControl *)controlInfo
 uploadProgress:(void (^_Nullable)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progress
        success:(void (^_Nullable)(AFHTTPRequestOperation *_Nullable operation, id _Nullable responseObject))success
        failure:(void (^_Nullable)(AFHTTPRequestOperation *_Nullable operation, NSError *_Nonnull error))failure
     completion:(void (^_Nullable)(AFHTTPRequestOperation *_Nullable operation))completion;

/**
 Creat a mutable URLRequest with special info.
 */
- (nullable NSMutableURLRequest *)URLRequestWithDefine:(nonnull RFAPIDefine *)define parameters:(nullable NSDictionary *)parameters formData:(nullable NSArray *)RFFormData controlInfo:(nullable RFAPIControl *)controlInfo error:(NSError *_Nullable __autoreleasing *_Nullable)error;

#pragma mark - Response

/**
 If `NULL` (default), the main queue will be used.
 */
@property (nonatomic, null_resettable, strong) dispatch_queue_t responseProcessingQueue;

- (void)invalidateCacheWithName:(nullable NSString *)APIName parameters:(nullable NSDictionary *)parameters;

#pragma mark - Methods for overwrite

/**
 Default implementation first add parameters from APIDefine then add parameters from define manager.
 */
- (void)preprocessingRequestParameters:(NSMutableDictionary *_Nullable *_Nonnull)requestParameters HTTPHeaders:(NSMutableDictionary *_Nullable *_Nonnull)requestHeaders withParameters:(nullable NSDictionary *)parameters define:(nonnull RFAPIDefine *)define controlInfo:(nullable RFAPIControl *)controlInfo;

/**
 Default implementation execute RFAPIControl’s requestCustomization.
 */
- (nullable NSMutableURLRequest *)finalizeSerializedRequest:(nonnull NSMutableURLRequest *)request withDefine:(nonnull RFAPIDefine *)define controlInfo:(nullable RFAPIControl *)controlInfo;

/**
 默认实现返回 YES
 
 This method is called on the main queue.

 @return 返回 YES 将继续错误的处理继续交由请求的回调处理，NO 处理结束
 */
- (BOOL)generalHandlerForError:(nonnull NSError *)error withDefine:(nonnull RFAPIDefine *)define controlInfo:(nullable RFAPIControl *)controlInfo requestOperation:(nullable AFHTTPRequestOperation *)operation operationFailureCallback:(void (^_Nullable)(AFHTTPRequestOperation *_Nullable, NSError *_Nonnull))operationFailureCallback;

/**
 判断响应是否是成功的结果
 
 Default implementation just return YES.
 
 This method is called on responseProcessingQueue.
 
 @param responseObjectRef 可以用来修改返回值
 @param error 可选的错误信息
 */
- (BOOL)isSuccessResponse:(id _Nullable __strong *_Nonnull)responseObjectRef error:(NSError *_Nullable __autoreleasing *_Nullable)error;

#pragma mark - Credentials & Security

/**
 Whether request operations should consult the credential storage for authenticating the connection. `YES` by default.

 @see AFURLConnectionOperation -shouldUseCredentialStorage
 */
@property BOOL shouldUseCredentialStorage;

/**
 The credential used by request operations for authentication challenges.

 @see AFURLConnectionOperation -credential
 */
@property (nullable, strong) NSURLCredential *credential;

/**
 The security policy used by created request operations to evaluate server trust for secure connections. `RFAPI` uses the `defaultPolicy` unless otherwise specified.
 */
@property (nonnull, strong) AFSecurityPolicy *securityPolicy;

@end

extern NSString *_Nonnull const RFAPIRequestArrayParameterKey;
extern NSString *_Nonnull const RFAPIRequestForceQuryStringParametersKey;
extern NSString *_Nonnull const RFAPIErrorDomain;

extern NSString *_Nonnull const RFAPIMessageControlKey;
extern NSString *_Nonnull const RFAPIIdentifierControlKey;
extern NSString *_Nonnull const RFAPIGroupIdentifierControlKey;
extern NSString *_Nonnull const RFAPIBackgroundTaskControlKey;
extern NSString *_Nonnull const RFAPIRequestCustomizationControlKey;

@interface RFAPIControl : NSObject
/** Activity message.
 请求开始前，自动进入消息显示队列。结束时自动从队列中清除。
*/
@property (nullable, strong) RFNetworkActivityIndicatorMessage *message;

/// Identifier for request.
@property (nullable, copy) NSString *identifier;

/// Group identifier for request.
@property (nullable, copy) NSString *groupIdentifier;

// No implementation
@property BOOL backgroundTask;

/// Ignore cache policy, force current request load from server.
@property BOOL forceLoad;

/// Customization URL request object
@property (nullable, copy) NSMutableURLRequest *_Nullable (^requestCustomization)(NSMutableURLRequest *_Nonnull request);

- (nonnull id)initWithDictionary:(nonnull NSDictionary *)info;
- (nonnull id)initWithIdentifier:(nonnull NSString *)identifier loadingMessage:(nullable NSString *)message;
@end


@interface RFHTTPRequestFormData : NSObject
/// The name to be associated with the specified data. This property must be set.
@property (nonnull, copy) NSString *name;

// No implementation
@property (nullable, copy) NSString *fileName;

// No implementation
@property (nullable, copy) NSString *mimeType;

/// The URL corresponding to the form content
@property (nullable, copy) NSURL *fileURL;

// No implementation
@property (nullable, strong) NSInputStream *inputStream;

/// The data to be encoded and appended to the form data.
@property (nullable, strong) NSData *data;

/**
 @param fileURL The URL corresponding to the file whose content will be appended to the form. This parameter must not be `nil`.
 @param name The name to be associated with the specified data. This parameter must not be `nil`.
 */
+ (nonnull instancetype)formDataWithFileURL:(nonnull NSURL *)fileURL name:(nonnull NSString *)name;

+ (nonnull instancetype)formDataWithData:(nonnull NSData *)data name:(nonnull NSString *)name;
+ (nonnull instancetype)formDataWithData:(nonnull NSData *)data name:(nonnull NSString *)name fileName:(nullable NSString *)fileName mimeType:(nullable NSString *)mimeType;

- (void)buildFormData:(nonnull id<AFMultipartFormData>)formData error:(NSError *_Nullable __autoreleasing *_Nullable)error;
@end
