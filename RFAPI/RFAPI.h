/*!
    RFAPI

    Copyright (c) 2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Alpha
 */
#import "RFUI.h"
#import "RFAPIDefine.h"
#import "RFAPIDefineManager.h"
#import "RFAPICacheManager.h"
#import "AFNetworkReachabilityManager.h"
#import "JSONModel.h"
#import "AFSecurityPolicy.h"

@class RFMessageManager, RFNetworkActivityIndicatorMessage, AFHTTPRequestOperation;
@class RFAPIControl, RFHTTPRequestFormData;

@interface RFAPI : NSOperationQueue <
    RFInitializing
>

+ (instancetype)sharedInstance;

@property (readonly, nonatomic) AFNetworkReachabilityManager *reachabilityManager;
@property (readonly, nonatomic) RFAPICacheManager *cacheManager;

#pragma mark - Define

@property (readonly, nonatomic) RFAPIDefineManager *defineManager;

#pragma mark - Request management

- (NSArray *)operationsWithIdentifier:(NSString *)identifier;
- (NSArray *)operationsWithGroupIdentifier:(NSString *)identifier;

- (void)cancelOperationWithIdentifier:(NSString *)identifier;
- (void)cancelOperationsWithGroupIdentifier:(NSString *)identifier;

#pragma mark - Activity Indicator

@property (strong, nonatomic) RFMessageManager *networkActivityIndicatorManager;

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
- (AFHTTPRequestOperation *)requestWithName:(NSString *)APIName
     parameters:(NSDictionary *)parameters
    controlInfo:(RFAPIControl *)controlInfo
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
     completion:(void (^)(AFHTTPRequestOperation *operation))completion;

/**
 上传文件

 @param arrayContainsFormDataObj 包含 RFHTTPRequestFormData 对象的数组
 */
- (AFHTTPRequestOperation *)requestWithName:(NSString *)APIName
     parameters:(NSDictionary *)parameters
       formData:(NSArray *)arrayContainsFormDataObj
    controlInfo:(RFAPIControl *)controlInfo
 uploadProgress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progress
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
     completion:(void (^)(AFHTTPRequestOperation *operation))completion;

/**
 Creat a mutable URLRequest with special info.
 */
- (NSMutableURLRequest *)URLRequestWithDefine:(RFAPIDefine *)define parameters:(NSDictionary *)parameters formData:(NSArray *)RFFormData controlInfo:(RFAPIControl *)controlInfo error:(NSError *__autoreleasing *)error;

#pragma mark - Response

- (void)invalidateCacheWithName:(NSString *)APIName parameters:(NSDictionary *)parameters;

#pragma mark - Methods for overwrite

/**
 Default implementation first add parameters from APIDefine then add parameters from define manager.
 */
- (void)preprocessingRequestParameters:(NSMutableDictionary **)requestParameters HTTPHeaders:(NSMutableDictionary **)requestHeaders withParameters:(NSDictionary *)parameters define:(RFAPIDefine *)define controlInfo:(RFAPIControl *)controlInfo;

/**
 Default implementation execute RFAPIControl’s requestCustomization.
 */
- (NSMutableURLRequest *)finalizeSerializedRequest:(NSMutableURLRequest *)request withDefine:(RFAPIDefine *)define controlInfo:(RFAPIControl *)controlInfo;

/**
 默认实现返回 YES

 @return 返回 YES 将继续错误的处理继续交由请求的回调处理，NO 处理结束
 */
- (BOOL)generalHandlerForError:(NSError *)error withDefine:(RFAPIDefine *)define controlInfo:(RFAPIControl *)controlInfo requestOperation:(AFHTTPRequestOperation *)operation operationFailureCallback:(void (^)(AFHTTPRequestOperation *, NSError *))operationFailureCallback;

/**
 判断响应是否是成功的结果
 
 Default implementation just return YES.
 
 @param responseObjectRef 可以用来修改返回值
 @param error 可选的错误信息
 */
- (BOOL)isSuccessResponse:(id *)responseObjectRef error:(NSError *__autoreleasing *)error;

#pragma mark - Credentials & Security

/**
 Whether request operations should consult the credential storage for authenticating the connection. `YES` by default.

 @see AFURLConnectionOperation -shouldUseCredentialStorage
 */
@property (nonatomic, assign) BOOL shouldUseCredentialStorage;

/**
 The credential used by request operations for authentication challenges.

 @see AFURLConnectionOperation -credential
 */
@property (nonatomic, strong) NSURLCredential *credential;

/**
 The security policy used by created request operations to evaluate server trust for secure connections. `RFAPI` uses the `defaultPolicy` unless otherwise specified.
 */
@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;

@end

extern NSString *const RFAPIErrorDomain;

extern NSString *const RFAPIMessageControlKey;
extern NSString *const RFAPIIdentifierControlKey;
extern NSString *const RFAPIGroupIdentifierControlKey;
extern NSString *const RFAPIBackgroundTaskControlKey;
extern NSString *const RFAPIRequestCustomizationControlKey;

@interface RFAPIControl : NSObject
/** Activity message.
 请求开始前，自动进入消息显示队列。结束时自动从队列中清除。
*/
@property (strong, nonatomic) RFNetworkActivityIndicatorMessage *message;

/// Identifier for request.
@property (strong, nonatomic) NSString *identifier;

/// Group identifier for request.
@property (strong, nonatomic) NSString *groupIdentifier;

// No implementation
@property (assign, nonatomic) BOOL backgroundTask;

/// Ignore cache policy, force current request load from server.
@property (assign, nonatomic) BOOL forceLoad;

/// Customization URL request object
@property (copy, nonatomic) NSMutableURLRequest * (^requestCustomization)(NSMutableURLRequest *request);

- (id)initWithDictionary:(NSDictionary *)info;
- (id)initWithIdentifier:(NSString *)identifier loadingMessage:(NSString *)message;
@end


@interface RFHTTPRequestFormData : NSObject
/// The name to be associated with the specified data. This property must be set.
@property (copy, nonatomic) NSString *name;

// No implementation
@property (copy, nonatomic) NSString *fileName;

// No implementation
@property (copy, nonatomic) NSString *mimeType;

/// The URL corresponding to the form content
@property (strong, nonatomic) NSURL *fileURL;

// No implementation
@property (strong, nonatomic) NSInputStream *inputStream;

/// The data to be encoded and appended to the form data.
@property (strong, nonatomic) NSData *data;

/**
 @param fileURL The URL corresponding to the file whose content will be appended to the form. This parameter must not be `nil`.
 @param name The name to be associated with the specified data. This parameter must not be `nil`.
 */
+ (instancetype)formDataWithFileURL:(NSURL *)fileURL name:(NSString *)name;

+ (instancetype)formDataWithData:(NSData *)data name:(NSString *)name;
+ (instancetype)formDataWithData:(NSData *)data name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType;

- (void)buildFormData:(id<AFMultipartFormData>)formData error:(NSError * __autoreleasing *)error;
@end
