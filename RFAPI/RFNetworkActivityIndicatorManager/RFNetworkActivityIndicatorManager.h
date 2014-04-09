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

/**
 网络请求加载状态管理器
 
 具体表现需要重写本类
 引入 identifier 的意图是支持多个状态的管理，配对的方式来管理消隐。目前设计只能同时显示一个
 */
@interface RFNetworkActivityIndicatorManager : NSObject <
    RFInitializing
>

/** 显示状态信息
 
 @param modal 是否以模态显示该信息，即显示时是否响应用户交互
 @param priority 状态优先级，会控制队列行为，
 @param timeInterval 0 不自动隐藏
 @param identifier 标示，新加入的显示请求会替换掉排队中的有着相同标示的请求。为 nil 会被转换为 @""。
 */
- (void)showWithTitle:(NSString *)title message:(NSString *)message status:(RFNetworkActivityIndicatorStatus)status modal:(BOOL)modal priority:(RFNetworkActivityIndicatorMessagePriority)priority autoHideAfterTimeInterval:(NSTimeInterval)timeInterval identifier:(NSString *)identifier userinfo:(NSDictionary *)userinfo;

/** 显示请求进度
 
 @param progress 0～1，小于 0 表示进行中但无具体进度
 */
- (void)showProgress:(float)progress title:(NSString *)title message:(NSString *)message status:(RFNetworkActivityIndicatorStatus)status modal:(BOOL)modal identifier:(NSString *)identifier userinfo:(NSDictionary *)userinfo;

/**
 @param identifier nil 会取消所有显示，如果 show 时的 identifier 未传，应使用 @""
 */
- (void)hideWithIdentifier:(NSString *)identifier;

- (void)alertError:(NSError *)error title:(NSString *)title;

@end


@interface RFNetworkActivityIndicatorMessage : NSObject
@property (copy, nonatomic) NSString *identifier;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *message;
@property (assign, nonatomic) BOOL modal;
@property (assign, nonatomic) RFNetworkActivityIndicatorMessagePriority priority;
@end