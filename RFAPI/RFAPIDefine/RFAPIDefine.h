// TEST

#import "RFRuntime.h"
#import "RFAPIDefineConfigFileKeys.h"

@interface RFAPIDefine : NSObject <NSCopying>
/// Used to get a deine from a RFAPIDefineManager
@property (copy, nonatomic) NSString *name;

/// HTTP base URL
@property (copy, nonatomic) NSURL *baseURL;

///
@property (copy, nonatomic) NSString *pathPrefix;

///
@property (copy, nonatomic) NSString *path;

/// HTTP Method
@property (copy, nonatomic) NSString *method;

#pragma mark - Request

/// HTTP headers to append
@property (copy, nonatomic) NSDictionary *HTTPRequestHeaders;

/// Default HTTP request parameters
@property (copy, nonatomic) NSDictionary *defaultParameters;

// No implementation
@property (assign, nonatomic) BOOL needsAuthorization;

/// AFURLRequestSerialization class
@property (strong, nonatomic) Class requestSerializerClass;

#pragma mark - Cache

typedef NS_ENUM(short, RFAPIDefineCachePolicy) {
    RFAPICachePolicyDefault = 0,
    RFAPICachePolicyProtocol = 1,       /// 协议，现在未作特殊处理
    RFAPICachePolicyAlways = 2,         /// 缓存一次后总是返回缓存数据
    RFAPICachePolicyExpire = 3,         /// 一段时间内不再请求
    RFAPICachePolicyNoCache = 5         /// 无缓存，总是请求新数据
};
// No implementation
@property (assign, nonatomic) RFAPIDefineCachePolicy cachePolicy;

// No implementation
@property (assign, nonatomic) NSTimeInterval expire;

typedef NS_ENUM(short, RFAPIDefineOfflinePolicy) {
    RFAPOfflinePolicyDefault = 0,       /// 不特殊处理
    RFAPOfflinePolicyLoadCache = 1      /// 返回缓存数据
};
// No implementation
@property (assign, nonatomic) RFAPIDefineOfflinePolicy offlinePolicy;

#pragma mark - Response

@property (strong, nonatomic) Class responseSerializerClass;

typedef NS_ENUM(short, RFAPIDefineResponseExpectType) {
    RFAPIDefineResponseExpectDefault = 0,   /// 不特殊处理
    RFAPIDefineResponseExpectSuccess = 1,   // No implementation
    RFAPIDefineResponseExpectObject  = 2,
    RFAPIDefineResponseExpectObjects = 3,   /// Expect an array of objects
};
///
@property (assign, nonatomic) RFAPIDefineResponseExpectType responseExpectType;

/// Expect JSONModel class
@property (strong, nonatomic) Class responseClass;

#pragma mark - 

/// User info
@property (copy, nonatomic) NSDictionary *userInfo;

/// Comment
@property (copy, nonatomic) NSString *notes;
@end
