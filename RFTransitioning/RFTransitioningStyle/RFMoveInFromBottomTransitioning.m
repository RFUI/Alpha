
#import "RFMoveInFromBottomTransitioning.h"
#import "UIView+RFAnimate.h"

@interface RFMoveInFromBottomTransitioning ()
@end

@implementation RFMoveInFromBottomTransitioning

- (void)onInit {
    self.duration = 0.3f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {

    UIView* containerView = transitionContext.containerView;
    CGRect fromFrame = [transitionContext initialFrameForViewController:fromVC];
    CGRect toFrame = [transitionContext finalFrameForViewController:toVC];

    if (self.reverse) {
        toView.frame = toFrame;
        [containerView insertSubview:toView belowSubview:fromView];
        [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            fromView.y = fromView.height;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
    else {
        toView.frame = fromFrame;
        toView.y = toView.height;
        [containerView insertSubview:toView aboveSubview:fromView];
        [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            toView.frame = toFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
}

@end
