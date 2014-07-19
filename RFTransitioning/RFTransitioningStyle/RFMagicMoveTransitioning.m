
#import "RFMagicMoveTransitioning.h"
#import "UIView+RFAnimate.h"

@interface RFMagicMoveTransitioningBinding : NSObject
@property (strong, nonatomic) UIView *fromView;
@property (strong, nonatomic) UIView *toView;
@property (strong, nonatomic) UIView *fromViewSnapshot;
@property (strong, nonatomic) UIView *toViewSnapshot;

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
        bind.fromViewHidden = vFrom.hidden;
        vFrom.hidden = YES;

        bind.toView = vTo;
        bind.toViewHidden = vTo.hidden;

        // vTo may not been rendered, so we cannot snapshotting it.
        // Also vTo may need update, snapshot now may get a wrong status. So always rendered it as an image.
        UIView *sTo = [[UIImageView alloc] initWithImage:[vTo renderToImage]];
        sTo.frame = [containerView convertRect:vFrom.frame fromView:vFrom.superview];
        [containerView addSubview:sTo];
        sTo.alpha = 0;
        bind.toViewSnapshot = sTo;

        UIView *sFrom = [vFrom snapshotViewAfterScreenUpdates:NO];
        sFrom.frame = [containerView convertRect:vFrom.frame fromView:vFrom.superview];
        [containerView addSubview:sFrom];
        sFrom.alpha = vFrom.alpha;
        bind.fromViewSnapshot = sFrom;

        vTo.hidden = YES;
        [bindings addObject:bind];
    }];

    [UIView animateWithDuration:duration animations:^{
        toView.alpha = 1;

        // Move each snapshot to destination
        for (RFMagicMoveTransitioningBinding *bind in bindings) {
            UIView *vTo = bind.toView;
            bind.fromViewSnapshot.alpha = 0;
            bind.toViewSnapshot.alpha = bind.toViewHidden? 0 : bind.toView.alpha;
            bind.fromViewSnapshot.frame = [containerView convertRect:vTo.frame fromView:vTo.superview];
            bind.toViewSnapshot.frame = bind.fromViewSnapshot.frame;
        }
    } completion:^(BOOL finished) {
        // Restore status
        for (RFMagicMoveTransitioningBinding *bind in bindings) {
            bind.fromView.hidden = bind.fromViewHidden;
            bind.toView.hidden = bind.toViewHidden;

            [bind.fromViewSnapshot removeFromSuperview];
            [bind.toViewSnapshot removeFromSuperview];
        }

        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end
