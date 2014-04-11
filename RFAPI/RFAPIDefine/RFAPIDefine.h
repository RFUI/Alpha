// TEST

#import "RFRuntime.h"

@interface RFAPIDefine : NSObject <NSCopying>
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSURL *baseURL;
@property (copy, nonatomic) NSString *path;

/// HTTP Method
@property (copy, nonatomic) NSString *method;

@property (copy, nonatomic) NSDictionary *HTTPRequestHeaders;

#pragma mark - Parameters
@property (copy, nonatomic) NSDictionary *defaultParameters;

@property (assign, nonatomic) BOOL needsAuthorization;

/// AFURLRequestSerialization class name
@property (copy, nonatomic) NSString *serializerName;

#pragma mark - Cache

typedef NS_ENUM(short, RFAPIDefineCachePolicy) {
    RFAPICachePolicyDefault = 0,
    RFAPICachePolicyProtocol = 1,       /// 协议，现在未作特殊处理
    RFAPICachePolicyExpire,             /// 一段时间内不再请求
    RFAPICachePolicyNoCache,            /// 无缓存，总是请求新数据
    RFAPICachePolicyAlways              /// 缓存一次后总是返回缓存数据
};

@property (assign, nonatomic) RFAPIDefineCachePolicy *cachePolicy;
@property (assign, nonatomic) NSTimeInterval expire;

typedef NS_ENUM(short, RFAPIDefineOfflinePolicy) {
    RFAPOfflinePolicyDefault = 0,       /// 不特殊处理
    RFAPOfflinePolicyLoadCache          /// 返回缓存数据
};

@property (assign, nonatomic) RFAPIDefineOfflinePolicy *offlinePolicy;

#pragma mark - Response

@property (copy, nonatomic) NSString *responseSerializerName;

@property (copy, nonatomic) NSDictionary *userInfo;
@end
