// TEST

#import <RFKit/RFRuntime.h>
#import <RFInitializing/RFInitializing.h>

/**

 
 */
typedef NS_ENUM(short, RFAssetsCacheStatus) {
    RFAssetsCacheStatusNotAvailable = 0,
    RFAssetsCacheStatusOK,

    RFAssetsCacheStatusNew
};

@protocol RFAssetsCacheRecord;

@interface RFAssetsCache : NSObject <
    RFInitializing
>
- (instancetype)initWithCacheFileName:(NSString *)cacheFileName;

@property (strong, readonly, nonatomic) NSOperationQueue *operationQueue;

- (void)cacheWithURI:(NSString *)uri data:(NSData *)data briefData:(NSData *)briefData age:(NSTimeInterval)age etag:(NSString *)etag completionHandler:(void (^)(NSError *error))completionHandler;

- (void)requestCacheWithURI:(NSString *)uri completionHandler:(void (^)(NSData *response, RFAssetsCacheStatus status, NSObject<RFAssetsCacheRecord> *record, NSError *error))completionHandler;
@end

@protocol RFAssetsCacheRecord <NSObject>

- (NSData *)briefData;
- (NSString *)uri;
- (NSString *)etag;
- (NSTimeInterval)age;

@end
