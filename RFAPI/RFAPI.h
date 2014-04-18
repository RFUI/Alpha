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
/// Load API deine config file.
- (void)setAPIDefineWithRules:(NSDictionary *)rules;

/// Get an API define object with API name.
- (RFAPIDefine *)defineForName:(NSString *)APIName;

#pragma mark - Request management

// No implementation
- (void)cancelOperationWithIdentifier:(NSString *)identifier;

// No implementation
- (void)cancelOperationsWithGroupIdentifier:(NSString *)identifier;

#pragma mark - Request

// 如果传一个特殊请求，直接创建一个 AFHTTPRequestOperation 并加进来也许更合适

/**
 @param APIName 接口名
 @param parameters 请求的参数
 @param controlInfo No implementation
 @param controlFlag No implementation
 @param success
 @param failure
 @param completion
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
 
 @param uploadResources

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
- (void)alertError:(NSError *)error title:(NSString *)title;

#pragma mark - Old raw request

/** 创建并执行请求，期望的返回是一个数组

 @param method      HTTP 请求模式
 @param URLString   请求的相对地址
 @param parameters  请求参数，可为空
 @param headers     附加的 HTTP header，可为空
 @param modelClass  数组中期望的元素的 JSONModel 类型
 @param success     请求成功回调的 block，可为空
 @param failure     请求失败回调的 block，可为空
 @param completion  请求完成回掉的 block，必定会被调用（即使请求创建失败），会在 success 和 failure 回调后执行。被设计用来执行通用的清理。可为空
 */
- (AFHTTPRequestOperation *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters headers:(NSDictionary *)headers expectArrayContainsClass:(Class)modelClass success:(void (^)(AFHTTPRequestOperation *operation, NSMutableArray *objects))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure completion:(void (^)(AFHTTPRequestOperation *operation))completion;

/** 创建并执行请求，期望的返回是一个对象

 @param modelClass 期望的元素的 JSONModel 类型
 */
- (AFHTTPRequestOperation *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters headers:(NSDictionary *)headers expectObjectClass:(Class)modelClass success:(void (^)(AFHTTPRequestOperation *operation, id JSONModelObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure completion:(void (^)(AFHTTPRequestOperation *operation))completion;

/** 创建并执行请求

 @return AFHTTPRequestOperation 对象
 */
- (AFHTTPRequestOperation *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters headers:(NSDictionary *)headers success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure completion:(void (^)(AFHTTPRequestOperation *operation))completion;

/** 创建 NSURLRequest 对象

 @param method HTTP 请求模式，如 `GET`、`POST`。不能为空
 @param URLString 请求路径，相对于 baseURL。不能为空
 @param parameters HTTP 请求的参数
 @param headers 附加的 HTTP header，新加的字段的会覆盖原有的
 @param error 创建请求对象出错时产生的错误

 @return 使用当前对象的 requestSerializer 序列好的请求对象
 */
- (NSMutableURLRequest *)URLRequestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters headers:(NSDictionary *)headers error:(NSError *__autoreleasing *)error;

@end

extern NSString *const RFAPIErrorDomain;

extern NSString *const RFAPIMessageControlKey;
extern NSString *const RFAPIIdentifierControlKey;
extern NSString *const RFAPIGroupIdentifierControlKey;
extern NSString *const RFAPIRequestCustomizationControlKey;

@interface RFAPIControl : NSObject
@property (strong, nonatomic) RFNetworkActivityIndicatorMessage *message;
@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *groupIdentifier;
@property (copy, nonatomic) NSMutableURLRequest * (^requestCustomization)(NSMutableURLRequest *request);
@end

@interface RFHTTPRequestFormData : NSObject
@end
