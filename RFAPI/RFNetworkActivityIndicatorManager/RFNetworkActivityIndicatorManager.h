// Test

#import <Foundation/Foundation.h>
#import "RFInitializing.h"

typedef NS_ENUM(short, RFNetworkActivityIndicatorStatus) {
    RFNetworkActivityIndicatorStatusLoading = 0,
    RFNetworkActivityIndicatorStatusSuccess,
    RFNetworkActivityIndicatorStatusFail,

    RFNetworkActivityIndicatorStatusDownloading,
    RFNetworkActivityIndicatorStatusUploading
};

/**  RFNetworkActivityIndicatorMessagePriority
 

 @enum RFNetworkActivityIndicatorMessagePriorityQueue 排队显示
 @enum RFNetworkActivityIndicatorMessagePriorityHigh 不改变队列，立即显示
 @enum RFNetworkActivityIndicatorMessagePriorityReset 立即显示，同时清空队列
 */
typedef NS_ENUM(NSInteger, RFNetworkActivityIndicatorMessagePriority) {
    RFNetworkActivityIndicatorMessagePriorityQueue = 0,
    RFNetworkActivityIndicatorMessagePriorityHigh = 750,
    RFNetworkActivityIndicatorMessagePriorityReset = 1000
};

@class RFNetworkActivityIndicatorMessage;

/**
 网络请求加载状态管理器
 
 具体表现需要重写本类
 引入 identifier 的意图是支持多个状态的管理，配对的方式来管理消隐。目前设计只能同时显示一个
 */
@interface RFNetworkActivityIndicatorManager : NSObject <
    RFInitializing
>


/**
 @param identifier nil 会取消所有显示，如果 show 时的 identifier 未传，应使用 @""
 */
- (void)hideWithIdentifier:(NSString *)identifier;

- (void)showMessage:(RFNetworkActivityIndicatorMessage *)message;
- (void)hideMessage:(RFNetworkActivityIndicatorMessage *)message;

#pragma mark - Methods for overwrite.
/** 
 
 Must call super.
 
 @param displayingMessage 目前显示的信息
 @param message 将要显示的信息
 */
- (void)replaceMessage:(RFNetworkActivityIndicatorMessage *)displayingMessage withNewMessage:(RFNetworkActivityIndicatorMessage *)message animated:(BOOL)animated;

@end


@interface RFNetworkActivityIndicatorMessage : NSObject
@property (copy, nonatomic) NSString *identifier;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *message;
@property (assign, nonatomic) RFNetworkActivityIndicatorStatus status;

@property (assign, nonatomic) RFNetworkActivityIndicatorMessagePriority priority;
@property (assign, nonatomic) BOOL modal;
@property (assign, nonatomic) float progress;
@property (assign, nonatomic) NSTimeInterval displayTimeInterval;

@property (strong, nonatomic) NSDictionary *userInfo;

- (instancetype)initWithIdentifier:(NSString *)identifier title:(NSString *)title message:(NSString *)message status:(RFNetworkActivityIndicatorStatus)status;
@end