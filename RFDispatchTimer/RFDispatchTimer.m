
#import "RFDispatchTimer.h"

@interface RFDispatchTimer ()
@property (strong) dispatch_source_t dispatchSource;
@end

@implementation RFDispatchTimer

+ (nullable instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(nonnull dispatch_block_t)block onQueue:(nullable dispatch_queue_t)queue {
    if (!queue) {
        queue = dispatch_get_main_queue();
    }

    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (!timer) return nil;

    RFDispatchTimer *dt = [RFDispatchTimer new];
    dt.dispatchSource = timer;

    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC));
    dispatch_source_set_timer(timer, delay, interval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        dt.dispatchSource = nil;
        block();
    });
    dispatch_resume(timer);

    return dt;
}

- (void)cancel {
    dispatch_source_t timer = self.dispatchSource;
    if (timer) {
        dispatch_source_cancel(timer);
        self.dispatchSource = nil;
    }
}

@end
