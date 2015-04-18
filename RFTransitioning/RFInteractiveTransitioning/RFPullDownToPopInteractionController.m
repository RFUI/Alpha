
#import "RFPullDownToPopInteractionController.h"
#import "RFPerformance.h"
#import "UIView+RFAnimate.h"

@interface RFPullDownToPopInteractionController ()
@property (strong, nonatomic) UIPanGestureRecognizer *gestureRecognizer;
@property (assign, nonatomic) CGFloat translationStartOffset;
@end

@implementation RFPullDownToPopInteractionController
@dynamic gestureRecognizer;

- (void)onInit {
    [super onInit];

    self.gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    self.gestureRecognizer.delaysTouchesBegan = YES;
}

- (void)handleGesture:(UIPanGestureRecognizer*)gestureRecognizer {
    UIView *piece = [gestureRecognizer view];

    CGFloat translation = [gestureRecognizer translationInView:piece.superview].y;
    CGFloat offset = translation - self.translationStartOffset;

    CGFloat percentComplete = (offset * 2) / piece.height;

    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            self.translationStartOffset = offset;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (self.interactionInProgress) {

                if (percentComplete < 0) {
                    percentComplete = 0;
                }

                // If an interactive transitions is 100% completed via the user interaction, the animation completion block is not called, and hence the transition is not completed.
                // This glorious hack makes sure that this doesn't happen.
                // see: https://github.com/ColinEberhardt/VCTransitionsLibrary/issues/4
                if (percentComplete >= 1) {
                    percentComplete = 0.99;
                }
                [self updateInteractiveTransition:percentComplete];
            }
            else {
                if (translation > 0) {
                    self.interactionInProgress = YES;
                    [self.viewController.navigationController popViewControllerAnimated:YES];
                }
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (self.interactionInProgress) {
                self.interactionInProgress = NO;

                CGFloat velocity = [gestureRecognizer velocityInView:piece.superview].y;

                if (((offset * 2 + velocity) / piece.height) < 0.5 || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
                    [self cancelInteractiveTransition];
                }
                else {
                    [self finishInteractiveTransition];
                }
            }
            break;
        }

        default:
            break;
    }
}

@end
