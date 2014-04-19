// TEST

#import "RFUI.h"
#import "RFAPIDefine.h"
#import "AFNetworkReachabilityManager.h"
#import "AFURLRequestSerialization.h"
#import "JSONModel.h"

/**
 TODO: 
 [ ] 文件上传
 [ ] 缓存实现
 [ ] 加载状态集成
 [ ] 队列标识控制

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
/// Update default define rule with config info.
- (void)updateDefaultRule:(NSDictionary *)rule merge:(BOOL)isMerge;

/// Load API deine config file.
- (void)setAPIDefineWithRules:(NSDictionary *)rules;

/// Get an API define object with API name.
- (RFAPIDefine *)defineForName:(NSString *)APIName;

#pragma mark - Request management

- (NSArray *)operationsWithIdentifier:(NSString *)identifier;
- (NSArray *)operationsWithGroupIdentifier:(NSString *)identifier;

- (void)cancelOperationWithIdentifier:(NSString *)identifier;
- (void)cancelOperationsWithGroupIdentifier:(NSString *)identifier;

#pragma mark - Request

// 如果传一个特殊请求，直接创建一个 AFHTTPRequestOperation 并加进来也许更合适

/**
 @param APIName     接口名
 @param parameters  请求的参数
 @param controlInfo No implementation
 @param controlFlag No implementation
 @param success     请求成功回调的 block，可为空
 @param failure     请求失败回调的 block，可为空
 @param completion  请求完成回掉的 block，必定会被调用（即使请求创建失败），会在 success 和 failure 回调后执行。被设计用来执行通用的清理。可为空
 */
- (AFHTTPRequestOperation *)requestWithName:(NSString *)APIName
     parameters:(NSDictionary *)parameters
    controlInfo:(RFAPIControl *)controlInfo
    controlFlag:(int *)flag
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
     completion:(void (^)(AFHTTPRequestOperation *operation))completion;

@property (strong, nonatomic) AFHTTPRequestSerializer<AFURLRequestSerialization> *requestSerializer;

/**
 For subclass overwrite, default do nothing.
 */
- (NSMutableURLRequest *)customSerializedRequest:(NSMutableURLRequest *)request withDefine:(RFAPIDefine *)define;

#pragma mark - Response

@property (strong, nonatomic) id<AFURLResponseSerialization> responseSerializer;

#pragma mark - Activity Indicator

@property (strong, nonatomic) RFMessageManager *networkActivityIndicatorManager;

/** 显示错误的统一方法

 @param error 显示错误信息的对象
 @param title 提示标题，可选
 */
- (void)alertError:(NSError *)error title:(NSString *)title DEPRECATED_ATTRIBUTE;

@end

extern NSString *const RFAPIErrorDomain;

extern NSString *const RFAPIMessageControlKey;
extern NSString *const RFAPIIdentifierControlKey;
extern NSString *const RFAPIGroupIdentifierControlKey;
extern NSString *const RFAPIRequestCustomizationControlKey;

@interface RFAPIControl : NSObject
// No implementation
@property (strong, nonatomic) RFNetworkActivityIndicatorMessage *message;

// No implementation
@property (strong, nonatomic) NSString *identifier;

// No implementation
@property (strong, nonatomic) NSString *groupIdentifier;

// No implementation
@property (assign, nonatomic) BOOL backgroundTask;

/// Customization URL request object
@property (copy, nonatomic) NSMutableURLRequest * (^requestCustomization)(NSMutableURLRequest *request);
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
