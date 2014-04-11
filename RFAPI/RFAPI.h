// TEST

#import "RFAPIDefine.h"
#import "RFInitializing.h"
#import "AFNetworkReachabilityManager.h"
#import "AFURLRequestSerialization.h"

@class RFMessageManager;
@protocol AFURLResponseSerialization;

@interface RFAPI : NSOperationQueue <
    RFInitializing
>

+ (instancetype)sharedInstance;

@property (copy, nonatomic) NSURL *baseURL;

@property (readonly, nonatomic) AFNetworkReachabilityManager *reachabilityManager;

#pragma mark - Define

- (void)setAPIDefineWithRules:(NSDictionary *)rules;

#pragma mark - Request

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
- (NSMutableURLRequest *)URLRequestWithDefine:(RFAPIDefine *)define parameters:(NSDictionary *)parameters uploadResources:(NSArray *)uploadResources;

/**
 For overwrite, default do nothing.
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

@end
