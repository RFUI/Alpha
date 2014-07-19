
#import "RFNavigationPopInteractionController.h"
#import "UIViewController+RFTransitioning.h"

@interface RFNavigationPopInteractionController ()
@end

#import "RFPerformance.h"

@implementation RFNavigationPopInteractionController
RFInitializingRootForNSObject

+ (id)alloc {
    id var = [super alloc];
    NSLog(@"%@ alloc >> %p", [self class], var);
    return var;
}

- (void)dealloc {
    NSLog(@"%@ dealloc << %p", [self class], self);
    if (self.gestureRecognizer.view) {
        [self.gestureRecognizer.view removeGestureRecognizer:self.gestureRecognizer];
    }
}

- (void)onInit {

}

- (void)afterInit {
    // Nothing
}

- (void)setViewController:(UIViewController *)viewController {
    if (_viewController != viewController) {
        _viewController.RFTransitioningInteractionController = nil;
        viewController.RFTransitioningInteractionController = self;

        UIGestureRecognizer *gr = self.gestureRecognizer;
        [gr.view removeGestureRecognizer:gr];
        [viewController.navigationController.view addGestureRecognizer:gr];

        _viewController = viewController;
    }
}

- (CGFloat)completionSpeed {
    return 1 - self.percentComplete;
}

@end
