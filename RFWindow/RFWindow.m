
#import "RFWindow.h"

@implementation RFWindowTouchForwardView
@end

@interface RFWindow ()
@end

@implementation RFWindow
RFInitializingRootForUIView

- (void)onInit {
    self.frame = self.screen.bounds;
    self.backgroundColor = [UIColor clearColor];
}

- (void)afterInit {
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitTestResult = [super hitTest:point withEvent:event];

    if ([hitTestResult isKindOfClass:[RFWindowTouchForwardView class]]) {
        return nil;
    }
    return hitTestResult;
}

@end

@implementation UIWindow (RFWindowLevel)

- (void)bringAboveWindow:(UIWindow *)window {
    self.windowLevel = window.windowLevel;
}

- (void)sendBelowWindow:(UIWindow *)window {
    UIWindowLevel level = window.windowLevel;
    self.windowLevel = --level;
}

@end

