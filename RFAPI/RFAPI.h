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
#import "AFNetworkReachabilityManager.h"
#import "JSONModel.h"

/**
 TODO:
 [ ] 缓存实现
 */

@class RFMessageManager, RFNetworkActivityIndicatorMessage, AFHTTPRequestOperation;
@class RFAPIControl, RFHTTPRequestFormData;

@interface RFAPI : NSOperationQueue <
    RFInitializing
>

+ (instancetype)sharedInstance;

@property (readonly, nonatomic) AFNetworkReachabilityManager *reachabilityManager;

#pragma mark - Define

@property (readonly, nonatomic) RFAPIDefineManager *defineManager;

#pragma mark - Request management

- (NSArray *)operationsWithIdentifier:(NSString *)identifier;
- (NSArray *)operationsWithGroupIdentifier:(NSString *)identifier;

- (void)cancelOperationWithIdentifier:(NSString *)identifier;
- (void)cancelOperationsWithGroupIdentifier:(NSString *)identifier;

#pragma mark - Request

// 如果传一个特殊请求，直接创建一个 AFHTTPRequestOperation 并加进来也许更合适

/**
 Creat and send a HTTP request.

 @discussion 当请求取消时，success 和 failure 都不会被调用，只有 completion 会被调用

 @param APIName     接口名
 @param parameters  请求的参数
 @param controlInfo
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


#pragma mark - Response


#pragma mark - Activity Indicator

@property (strong, nonatomic) RFMessageManager *networkActivityIndicatorManager;

/** 显示错误的统一方法

 @param error 显示错误信息的对象
 @param title 提示标题，可选
 */
- (void)alertError:(NSError *)error title:(NSString *)title DEPRECATED_ATTRIBUTE;

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

/// Ignore cache policy
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
// No implementation
@property (strong, nonatomic) NSData *data;

/**
 @param fileURL The URL corresponding to the file whose content will be appended to the form. This parameter must not be `nil`.
 @param name The name to be associated with the specified data. This parameter must not be `nil`.
 */
+ (instancetype)formDataWithFileURL:(NSURL *)fileURL name:(NSString *)name;
@end
