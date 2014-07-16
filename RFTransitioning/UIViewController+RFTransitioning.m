
#import "UIViewController+RFTransitioning.h"
#import <objc/runtime.h>

static char UIViewControllerRFTransitioningStyleCateogryProperty;

@implementation UIViewController (RFTransitioning)
@dynamic RFTransitioningStyle;

- (NSString *)RFTransitioningStyle {
    return objc_getAssociatedObject(self, &UIViewControllerRFTransitioningStyleCateogryProperty);
}

- (void)setRFTransitioningStyle:(NSString *)RFTransitioningStyle {
    if (![self.RFTransitioningStyle isEqualToString:RFTransitioningStyle]) {
        objc_setAssociatedObject(self, &UIViewControllerRFTransitioningStyleCateogryProperty, RFTransitioningStyle, OBJC_ASSOCIATION_COPY);
    }
}

@end
