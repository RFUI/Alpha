
#import "RFSerialTaskOperationController.h"
#import <RFKit/RFRuntime.h>

@interface RFSerialTaskOperationController ()
@property BOOL lock;
@property BOOL hasRequestBlocked;
@property BOOL hasSetNeedsRequestScheduled;
@property (nonatomic, strong) NSMutableArray<NSOperation *> *manualPerformOperation;
@end

@implementation RFSerialTaskOperationController

- (instancetype)init {
    self = [super init];
    if (self) {
        _operationPriorityDefult = NSOperationQueuePriorityLow;
        _operationPriorityTriggeredByUser = NSOperationQueuePriorityHigh;
    }
    return self;
}

- (void)setNeedsPerformTask {
    if (self.hasSetNeedsRequestScheduled) {
        return;
    }
    if (self.lock || !self.enabled) {
        self.hasRequestBlocked = YES;
        return;
    }
    _dout_debug(@"SerialTaskController: schedule task");
    self.hasSetNeedsRequestScheduled = YES;
    dispatch_after_seconds(0.1, ^{
        self.hasSetNeedsRequestScheduled = NO;
        @synchronized(self) {
            if (self.lock) {
                return;
            }
            self.lock = YES;
            [self performTaskImmediately];
        }
    });
}

- (void)performTaskImmediately {
    _dout_debug(@"SerialTaskController: perform task");
    RFAssert([NSThread isMainThread], nil);
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:self.taskBlock];
    [op setCompletionBlock:^{
        _dout_debug(@"SerialTaskController: operation complete");
        [self onTaskComplate];
    }];

    RFAssert(self.queue, nil);
    op.queuePriority = self.operationPriorityDefult;
    [self.queue addOperation:op];
}

- (void)performTask:(nonnull dispatch_block_t)taskBlock {
    NSParameterAssert(taskBlock);
    @synchronized(self) {
        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:taskBlock];
        [op setCompletionBlock:^{
            _dout_debug(@"SerialTaskController: manual operation complete");
            [self onTaskComplate];
        }];
        op.queuePriority = self.operationPriorityTriggeredByUser;

        if (self.lock || !self.enabled) {
            [self.manualPerformOperation addObject:op];
            return;
        }

        self.lock = YES;
        dispatch_async_on_main(^{
            [self.queue addOperation:op];
        });
    }
}

- (void)onTaskComplate {
    @synchronized(self) {
        self.lock = NO;

        NSMutableArray *ops = _manualPerformOperation;
        NSOperation *op = ops.firstObject;
        if (op) {
            _dout_debug(@"SerialTaskController: add another manual task to queue");
            self.lock = YES;
            [ops removeObject:op];
            dispatch_async_on_main(^{
                [self.queue addOperation:op];
            });
            return;
        }

        if (self.hasRequestBlocked) {
            _dout_debug(@"SerialTaskController: set needs perfrom blocked task");
            self.hasRequestBlocked = NO;
            [self setNeedsPerformTask];
        }
    }
}

- (NSMutableArray *)manualPerformOperation {
    if (_manualPerformOperation) return _manualPerformOperation;
    _manualPerformOperation = [NSMutableArray array];
    return _manualPerformOperation;
}

@end
