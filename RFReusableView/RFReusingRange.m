
#import "RFReusingRange.h"

@interface RFReusingRange ()
@end

@implementation RFReusingRange

- (id)init {
    self = [super init];
    if (self) {
        [self onInit];
        [self performSelector:@selector(afterInit) withObject:nil afterDelay:0];
    }
    return self;
}

- (void)onInit {
    _criticalBefore = 1;
    _criticalAfter = 1;
    _activeRange = NSMakeRange(0, 0);
}

- (void)afterInit {
}

- (void)setActiveRange:(NSRange)activeRange {
    BOOL isIntersecting = (NSIntersectionRange(_activeRange, activeRange).length);
    if (isIntersecting) {
        NSUInteger oldLast = _activeRange.location + _activeRange.length - 1;
        NSUInteger newLast = activeRange.location + activeRange.length - 1;
        
        if (_activeRange.location < activeRange.location) {
            for (NSUInteger i = _activeRange.location; i < activeRange.location; i++) {
                [self.delegate RFReusingRange:self itemLeaveRangeAtIndex:i];
            }
            
            for (NSUInteger i = oldLast; i < newLast; i++) {
                [self.delegate RFReusingRange:self itemEnterRangeAtIndex:i];
            }
        }
        else {
            for (NSUInteger i = activeRange.location; i < oldLast; i++) {
                [self.delegate RFReusingRange:self itemLeaveRangeAtIndex:i];
            }
            
            for (NSUInteger i = oldLast; i < newLast; i++) {
                [self.delegate RFReusingRange:self itemEnterRangeAtIndex:i];
            }
        }
    }
    else {
        int i = _activeRange.location;
        for (int j = _activeRange.length; j > 0; j--) {
            [self.delegate RFReusingRange:self itemLeaveRangeAtIndex:(i+j-1)];
        }
        
        i = activeRange.location;
        for (int j = activeRange.length; j > 0; j--) {
            [self.delegate RFReusingRange:self itemEnterRangeAtIndex:(i+j-1)];
        }
    }
    
    _activeRange = activeRange;
}

@end
