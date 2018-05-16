/*!
 RFSerialTaskOperationController
 RFAlpha
 
 Copyright © 2018 RFUI.
 https://github.com/RFUI/Alpha
 
 The MIT License (MIT)
 http://www.opensource.org/licenses/mit-license.php
 */

#import <Foundation/Foundation.h>

/**
 在一个 NSOperationQueue 上串行执行任务，即使队列是并发队列
 
 这个类保证在同一时间只有一个从自身触发的任务在执行
 */
@interface RFSerialTaskOperationController : NSObject

/// 队列的操作都是在主线程
@property (nonatomic, nonnull, strong) NSOperationQueue *queue;

/**
 通过 setNeedsPerformTask 延迟触发的任务在队列中的优先级

 默认 NSOperationQueuePriorityLow
 */
@property (nonatomic) NSOperationQueuePriority operationPriorityDefult;

/**
 通过 performTask: 触发的任务在队列中的优先级
 
 默认 NSOperationQueuePriorityHigh
 */
@property (nonatomic) NSOperationQueuePriority operationPriorityTriggeredByUser;

@property BOOL enabled;

/// 执行任务的 block，会在指定的 queue 上同步执行
@property (nonnull, copy) dispatch_block_t taskBlock;

/**
 标记任务需要执行
 */
- (void)setNeedsPerformTask;

/**
 供手动调用，尽快执行任务

 @param taskBlock 不能为空，会在指定的 queue 上同步执行
 */
- (void)performTask:(nonnull dispatch_block_t)taskBlock;

@end
