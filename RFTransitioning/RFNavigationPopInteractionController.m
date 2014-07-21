
#import "RFNavigationPopInteractionController.h"
#import "UIViewController+RFTransitioning.h"

@interface RFNavigationPopInteractionController ()
@end

@implementation RFNavigationPopInteractionController
RFInitializingRootForNSObject

- (void)dealloc {
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

        [self uninstallGestureRecognizer];

        _viewController = viewController;
        [self installGestureRecognizer];
    }
}

- (CGFloat)completionSpeed {
    return 1 - self.percentComplete;
}

- (void)installGestureRecognizer {
    if (self.gestureRecognizer) {
        [self.viewController.navigationController.view addGestureRecognizer:self.gestureRecognizer];
    }
}

- (void)uninstallGestureRecognizer {
    douts(@"Remove")
    [self.gestureRecognizer.view removeGestureRecognizer:self.gestureRecognizer];
}

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    douto(transitionContext)
    [super startInteractiveTransition:transitionContext];
}

/*
- (void)cancelInteractiveTransition {
    [super cancelInteractiveTransition];
}*/

- (void)finishInteractiveTransition {
    [super finishInteractiveTransition];
    [self uninstallGestureRecognizer];
}

@end
