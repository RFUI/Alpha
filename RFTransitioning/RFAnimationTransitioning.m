
#import "RFAnimationTransitioning.h"

@interface RFAnimationTransitioning ()
@end

@implementation RFAnimationTransitioning
RFInitializingRootForNSObject

- (void)onInit {
    self.duration = 0.5f;
}

- (void)afterInit {
    // Nothing
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    @autoreleasepool {
        UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        UIView *toView = toVC.view;
        UIView *fromView = fromVC.view;

        [self animateTransition:transitionContext fromVC:fromVC toVC:toVC fromView:fromView toView:toView];
    }
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    RFAssert(false, @"Subclass must overwrite animateTransition:fromVC:toVC:fromView:toView:")
}

@end
