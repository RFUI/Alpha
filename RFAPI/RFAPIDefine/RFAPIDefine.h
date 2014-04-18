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

@property (assign, nonatomic) RFAPIDefineCachePolicy cachePolicy;
@property (assign, nonatomic) NSTimeInterval expire;

typedef NS_ENUM(short, RFAPIDefineOfflinePolicy) {
    RFAPOfflinePolicyDefault = 0,       /// 不特殊处理
    RFAPOfflinePolicyLoadCache = 1      /// 返回缓存数据
};

@property (assign, nonatomic) RFAPIDefineOfflinePolicy offlinePolicy;

#pragma mark - Response

@property (strong, nonatomic) Class responseSerializerClass;

typedef NS_ENUM(short, RFAPIDefineResponseExpectType) {
    RFAPIDefineResponseExpectDefault = 0,       /// 不特殊处理
    RFAPIDefineResponseExpectSuccess = 1,      /// 返回缓存数据
    RFAPIDefineResponseExpectObject = 2,
    RFAPIDefineResponseExpectObjects = 3,
};
@property (assign, nonatomic) RFAPIDefineResponseExpectType responseExpectType;
@property (assign, nonatomic) BOOL responseList;
@property (strong, nonatomic) Class responseClass;

@property (copy, nonatomic) NSDictionary *userInfo;
@end
