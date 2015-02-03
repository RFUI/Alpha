
#import "RFMoveInFromBottomTransitioning.h"
#import "UIView+RFAnimate.h"
#import "RFPullDownToPopInteractionController.h"

@interface RFMoveInFromBottomTransitioning ()
@end

@implementation RFMoveInFromBottomTransitioning

- (void)onInit {
    self.duration = 0.3f;
    self.interactionControllerType = NSStringFromClass([RFPullDownToPopInteractionController class]);
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {

    UIView* containerView = transitionContext.containerView;
    CGRect fromFrame = [transitionContext initialFrameForViewController:fromVC];
    CGRect toFrame = [transitionContext finalFrameForViewController:toVC];
    BOOL reverse = self.reverse;

    if (reverse) {
        toView.frame = toFrame;
    }
    else {
        // Navigation bar hidden may change between transition.
        // Let initial frame bigger can avoid user see window background.
        toView.frame = CGRectContainsRect(toFrame, fromFrame)? toFrame : fromFrame;
    }

    if (self.reverse) {
        [containerView insertSubview:toView belowSubview:fromView];
    }
    else {
        toView.y += toView.height;
        [containerView insertSubview:toView aboveSubview:fromView];
    }

    [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (reverse) {
            fromView.y += fromView.height;
        }
        toView.frame = toFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
