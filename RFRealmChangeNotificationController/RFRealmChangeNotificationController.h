/*!
 RFRealmChangeNotificationController
 RFAlpha
 
 Copyright © 2018 RFUI.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/RFUI/Alpha
 
 The MIT License (MIT)
 http://www.opensource.org/licenses/mit-license.php
 */
#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

/**
 监听 Realm 一个集合的变更，在发生变更时进行修改，但是修改可能会修改这个集合造成通知=>变更=>通知的循环。

 这个类就是为了破除这个循环准备的，它会在在得知通知时临时禁用通知，等修改结束后再启用通知从而避免循环问题
 */
@interface RFRealmChangeNotificationController : NSObject
@property (nonatomic, nullable) id<RLMCollection> collection;

@property (nonatomic, nullable, copy) NSString *name;

/// 大于 0 忽略变更通知
@property (nonatomic) NSUInteger changeSkipSignal;

/// 在变更发生后执行
@property (nonatomic, nullable, copy) void (^changeProcessHandler)(RFRealmChangeNotificationController *_Nonnull controller);

/// 未设置，变更操作在主线程
@property (nonatomic, nullable) dispatch_queue_t changeHandlerQueue;

/// 处理完变更后要调用通知
- (void)markChangeProcessFinished;

@end
