
#import "RFMagicMoveTransitioning.h"
#import "UIView+RFAnimate.h"

@interface RFMagicMoveTransitioningBinding : NSObject
@property (strong, nonatomic) UIView *fromView;
@property (strong, nonatomic) UIView *toView;
@property (strong, nonatomic) UIView *snapshotView;

@property (assign, nonatomic) BOOL fromViewHidden;
@property (assign, nonatomic) BOOL toViewHidden;
@end

@implementation RFMagicMoveTransitioningBinding
@end

@interface RFMagicMoveTransitioning ()
@end

@implementation RFMagicMoveTransitioning

- (void)onInit {
    self.duration = 0.4f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {

    UIView* containerView = transitionContext.containerView;
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    BOOL reverse = self.reverse;

    // Setup toView
    toView.alpha = 0;
    toView.frame = [transitionContext finalFrameForViewController:toVC];
    [containerView addSubview:toView];

    // Creat snapshots
    NSMutableArray *bindings = [NSMutableArray arrayWithCapacity:self.viewBindings.count];
    [self.viewBindings enumerateKeysAndObjectsUsingBlock:^(id fromKey, id toKey, BOOL *stop) {
        UIView *vFrom = [fromVC valueForKeyPath:reverse? toKey : fromKey];
        UIView *vTo = [toVC valueForKeyPath:reverse? fromKey : toKey];
        RFAssert([vFrom isKindOfClass:[UIView class]], @"%@ must be an UIView", vFrom);
        RFAssert([vTo isKindOfClass:[UIView class]], @"%@ must be an UIView", vTo);

        RFMagicMoveTransitioningBinding *bind = [RFMagicMoveTransitioningBinding new];
        bind.fromView = vFrom;
        bind.fromView.hidden = vFrom.hidden;

        bind.toView = vTo;
        bind.toViewHidden = vTo.hidden;

        UIView *snap = [vFrom snapshotViewAfterScreenUpdates:NO];
        snap.frame = [containerView convertRect:vFrom.frame fromView:vFrom.superview];
        [containerView addSubview:snap];

        bind.snapshotView = snap;

        vTo.hidden = YES;
        [bindings addObject:bind];
    }];

    [UIView animateWithDuration:duration animations:^{
        toView.alpha = 1;

        // Move each snapshot to destination
        for (RFMagicMoveTransitioningBinding *bind in bindings) {
            UIView *vTo = bind.toView;
            bind.snapshotView.alpha = bind.toViewHidden? 0 : vTo.alpha;
            bind.snapshotView.frame = [containerView convertRect:vTo.frame fromView:vTo.superview];
        }
    } completion:^(BOOL finished) {
        for (RFMagicMoveTransitioningBinding *bind in bindings) {
            bind.toView.hidden = bind.toViewHidden;
            bind.fromView.hidden = bind.fromViewHidden;
            [bind.snapshotView removeFromSuperview];
        }

        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end
