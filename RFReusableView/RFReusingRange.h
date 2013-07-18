// Pre TEST

/**
 
 | Out range | <------------------ In range ------------------> | Out range |
 | Unactive  | Critical Before | Active range | Critical aftrer | Unactive  |
 
 */

#import <Foundation/Foundation.h>

@protocol RFReusingRangeDelegate;

@interface RFReusingRange : NSObject

@property(weak, nonatomic) id<RFReusingRangeDelegate> delegate;

@property(assign, nonatomic) NSRange activeRange;

// Default 1
@property(assign, nonatomic) NSUInteger criticalBefore;
@property(assign, nonatomic) NSUInteger criticalAfter;

@end

@protocol RFReusingRangeDelegate <NSObject>
@required
- (void)RFReusingRange:(RFReusingRange *)range itemEnterRangeAtIndex:(NSUInteger)index;

- (void)RFReusingRange:(RFReusingRange *)range itemLeaveRangeAtIndex:(NSUInteger)index;


@end
