
#import "UIViewController+RFTransitioning.h"
#import <objc/runtime.h>

static char UIViewControllerRFTransitioningStyleCateogryProperty;
static char UIViewControllerRFTransitioningInteractionControllerCateogryProperty;

@implementation UIViewController (RFTransitioning)
@dynamic RFTransitioningStyle, RFTransitioningInteractionController;

- (NSString *)RFTransitioningStyle {
    return objc_getAssociatedObject(self, &UIViewControllerRFTransitioningStyleCateogryProperty);
}

- (void)setRFTransitioningStyle:(NSString *)RFTransitioningStyle {
    if (![self.RFTransitioningStyle isEqualToString:RFTransitioningStyle]) {
        objc_setAssociatedObject(self, &UIViewControllerRFTransitioningStyleCateogryProperty, RFTransitioningStyle, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

- (id<UIViewControllerInteractiveTransitioning>)RFTransitioningInteractionController {
    return objc_getAssociatedObject(self, &UIViewControllerRFTransitioningInteractionControllerCateogryProperty);
}

- (void)setRFTransitioningInteractionController:(id<UIViewControllerInteractiveTransitioning>)RFTransitioningInteractionController {
    if (self.RFTransitioningInteractionController != RFTransitioningInteractionController) {
        objc_setAssociatedObject(self, &UIViewControllerRFTransitioningInteractionControllerCateogryProperty, RFTransitioningInteractionController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}


@end
