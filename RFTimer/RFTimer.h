/*!
    RFTimer
    RFUI

    Copyright (c) 2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    TEST
 */
#import <Foundation/Foundation.h>

/**
 Similar to a NSTimer, but support more features:

 - You can modify a RFTimer at any time.
 - You can pause and resume a RFTimer.
 - You can stop and restart a RFTimer.
 - Invoke a block when the timer fired.

 */
@interface RFTimer : NSObject

/**
 Creates and returns a new RFTimer object and schedules it on the main run loop in the default mode.
 
 @param seconds The number of seconds between firings of the timer. If seconds is less than or equal to 0.0, this method chooses the nonnegative value of 0.01 seconds instead.
 @param repeats If YES, the timer will repeatedly reschedule itself until invalidated. If NO, the timer will be invalidated after it fires.
 @param fireBlock The block to be invoked when the timer fired. This block has no return value and takes two arguments: the timer, the timer fired times if the timer is a repeating timer.
 
 @return A new RFTimer object, configured according to the specified parameters.
 */
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats fireBlock:(void (^)(RFTimer *timer, NSUInteger repeatCount))fireBlock;

/**
 The receiver’s time interval.
 
 Changes to this property takes effect on next schedule.
 */
@property (assign, nonatomic) NSTimeInterval timeInterval;

/**
 Determine the receiver is a repeating timer or not.
 */
@property (assign, nonatomic, getter = isRepeating) BOOL repeating;

/**
 Schedules the timer on a given run loop in a given mode.
 
 Takes no effect if the timer already scheduled on a run loop.

 @param runLoop The run loop to which to add the timer. If you specify nil, the main thread’s run loop will be used.
 @param mode The run loop mode to which to add the timer. If you specify nil, NSDefaultRunLoopMode will be used.
 */
- (void)scheduleInRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode;

/**
 You can use this method to fire a repeating timer without interrupting its regular firing schedule and the repeatCount of fireBlock will be zero.
 
 If the timer is non-repeating, it is automatically invalidated after firing, even if its scheduled fire date has not arrived.
 */
- (void)fire;


/**
 Set to `YES` will pause a repeating timer.
 */
@property (assign, nonatomic, getter = isSuspended) BOOL suspended;

/**
 Returns a Boolean value that indicates whether the receiver is scheduled on a run loop.
 
 @return `YES` if the receiver is scheduled on a run loop.
 */
- (BOOL)isScheduled;

/**
 Stops the receiver from firing.
 
 You can use `scheduleInRunLoop:forMode:` to restart the receiver.
 */
- (void)invalidate;

/**
 The amount of time after the scheduled firing time that the timer may fire. This property takes no effect on iOS 6 and before.
 
 The default value is zero, which means no additional tolerance is applied.
 */
@property (assign, nonatomic) NSTimeInterval tolerance;


@property (copy, nonatomic) void (^fireBlock)(RFTimer *timer, NSUInteger repeatCount);
@end
