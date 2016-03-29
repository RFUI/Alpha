/*!
    RFAPIDefine
    RFAPI

    Copyright (c) 2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Alpha
 */
#import "RFRuntime.h"
#import "RFAPIDefineConfigFileKeys.h"

@interface RFAPIDefine : NSObject <
    NSCopying,
    NSSecureCoding
>
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

/// If send authorization HTTP header or parameters
@property (nonatomic) BOOL needsAuthorization;

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
@property (nonatomic) RFAPIDefineCachePolicy cachePolicy;

/// Gives the date/time after which the cache is considered stale
@property (nonatomic) NSTimeInterval expire;

typedef NS_ENUM(short, RFAPIDefineOfflinePolicy) {
    RFAPIOfflinePolicyDefault = 0,       /// 不特殊处理
    RFAPIOfflinePolicyLoadCache = 1      /// 返回缓存数据
};
@property (nonatomic) RFAPIDefineOfflinePolicy offlinePolicy;

#pragma mark - Response

@property (strong, nonatomic) Class responseSerializerClass;

typedef NS_ENUM(short, RFAPIDefineResponseExpectType) {
    RFAPIDefineResponseExpectDefault = 0,   /// 不特殊处理
    RFAPIDefineResponseExpectSuccess = 1,   /// Overwrite [RFAPI isSuccessResponse:error:] to  determine whether success or failure.
    RFAPIDefineResponseExpectObject  = 2,   /// Expect an object
    RFAPIDefineResponseExpectObjects = 3,   /// Expect an array of objects
};
///
@property (nonatomic) RFAPIDefineResponseExpectType responseExpectType;

/// Accept null response
@property (nonatomic) BOOL responseAcceptNull;

/// Expect JSONModel class
@property (strong, nonatomic) Class responseClass;

#pragma mark - 

/// User info
@property (copy, nonatomic) NSDictionary *userInfo;

/// Comment
@property (copy, nonatomic) NSString *notes;
@end
