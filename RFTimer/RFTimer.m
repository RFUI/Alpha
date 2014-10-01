
#import "RFTimer.h"

@interface RFTimer ()
@property (strong, nonatomic) NSTimer *realTimer;
@property (assign, nonatomic, getter = isScheduled) BOOL scheduled;
@property (assign, nonatomic) NSUInteger fireCounter;
@property (weak, nonatomic) NSRunLoop *runLoop;
@property (copy, nonatomic) NSString *runLoopMode;
@property (assign, nonatomic) BOOL needsCoverToRepeatingTimer;
@end

@implementation RFTimer

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats fireBlock:(void (^)(RFTimer *timer, NSUInteger repeatCount))block {
    RFTimer *tm = [[RFTimer alloc] init];
    if (seconds <= 0) {
        seconds = 0.01;
    }
    tm.timeInterval = seconds;
    tm.repeating = repeats;
    tm.fireBlock = block;
    [tm scheduleInRunLoop:nil forMode:nil];
    return tm;
}

- (void)dealloc {
    [self invalidate];
}

- (void)scheduleInRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode {
    if (self.scheduled) return;
    self.scheduled = YES;
    self.runLoop = runLoop;
    self.runLoopMode = mode;
    self.fireCounter = 0;

    if (self.realTimer) {
        [self.realTimer invalidate];
        self.realTimer = nil;
    }

    [self resume];
}

- (void)resume {
    if (self.realTimer) return;

    NSTimer *tm = [NSTimer timerWithTimeInterval:self.timeInterval target:self selector:@selector(scheduledFire) userInfo:nil repeats:self.repeating];
    if ([tm respondsToSelector:@selector(setTolerance:)]) {
        tm.tolerance = self.tolerance;
    }

    NSRunLoop *runLoop = self.runLoop?: [NSRunLoop mainRunLoop];
    NSString *mode = self.runLoopMode?: NSDefaultRunLoopMode;
    [runLoop addTimer:tm forMode:mode];
    self.realTimer = tm;
}

- (void)invalidate {
    [self.realTimer invalidate];
    self.realTimer = nil;
    self.scheduled = NO;
}

- (void)setSuspended:(BOOL)suspended {
    if (_suspended != suspended) {
        if (suspended) {
            [self.realTimer invalidate];
            self.realTimer = nil;
        }
        else {
            [self resume];
        }
        _suspended = suspended;
    }
}

- (void)setRepeating:(BOOL)repeating {
    if (_repeating != repeating) {
        if (repeating) {
            self.needsCoverToRepeatingTimer = YES;
        }
        _repeating = repeating;
    }
}

- (void)fire {
    if (self.fireBlock) {
        self.fireBlock(self, 0);
    }

    if (!self.repeating) {
        [self invalidate];
    }
}

- (void)scheduledFire {
    self.fireCounter++;

    if (self.fireBlock) {
        self.fireBlock(self, self.fireCounter);
    }

    // Detect repeating changes during last interval.
    if (!self.repeating) {
        [self invalidate];
    }
    if (self.needsCoverToRepeatingTimer) {
        [self scheduleInRunLoop:nil forMode:nil];
        self.needsCoverToRepeatingTimer = NO;
    }
}


@end
