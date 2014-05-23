// TEST

#import "RFUI.h"
#import "RFAPIDefine.h"
#import "RFAPIDefineManager.h"
#import "AFNetworkReachabilityManager.h"
#import "AFURLRequestSerialization.h"
#import "JSONModel.h"

/**
 TODO: 
 [ ] 文件上传
 [ ] 缓存实现
 */

@class RFMessageManager, RFNetworkActivityIndicatorMessage, AFHTTPRequestOperation;
@class RFAPIControl, RFHTTPRequestFormData;
@protocol AFURLResponseSerialization;

@interface RFAPI : NSOperationQueue <
    RFInitializing
>

+ (instancetype)sharedInstance;

@property (copy, nonatomic) NSURL *baseURL DEPRECATED_ATTRIBUTE;

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
 @param controlInfo No implementation
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

@property (strong, nonatomic) AFHTTPRequestSerializer<AFURLRequestSerialization> *requestSerializer;

#pragma mark - Response

@property (strong, nonatomic) id<AFURLResponseSerialization> responseSerializer;

#pragma mark - Activity Indicator

@property (strong, nonatomic) RFMessageManager *networkActivityIndicatorManager;

/** 显示错误的统一方法

 @param error 显示错误信息的对象
 @param title 提示标题，可选
 */
- (void)alertError:(NSError *)error title:(NSString *)title DEPRECATED_ATTRIBUTE;

#pragma mark - Methods for overwrite
/**
 For subclass overwrite, default do nothing.
 */
- (NSMutableURLRequest *)customSerializedRequest:(NSMutableURLRequest *)request withDefine:(RFAPIDefine *)define;

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

// No implementation
@property (assign, nonatomic) BOOL forceLoad;

/// Customization URL request object
@property (copy, nonatomic) NSMutableURLRequest * (^requestCustomization)(NSMutableURLRequest *request);

- (id)initWithDictionary:(NSDictionary *)info;
- (id)initWithIdentifier:(NSString *)identifier loadingMessage:(NSString *)message;
@end

/*
 @code
 [
 {
 Name:@"value name",
 Data:NSData
 },
 {
 Name:@"value 2",
 URL:NSURL for resource
 },
 {
 Name:@"Optional keys",
 Data:NSData,
 FileName:@"file name",
 MimeType:@"image/png",
 Length:123
 }
 ]
 @endcode

 Support three source: `Data`, `URL`, `Stream`

 @see AFMultipartFormData
 */
@interface RFHTTPRequestFormData : NSObject
@end
