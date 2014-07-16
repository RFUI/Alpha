
#import "RFNavigationControllerTransitionDelegate.h"
#import "RFAnimationTransitioning.h"

@interface RFNavigationControllerTransitionDelegate ()
@end

@implementation RFNavigationControllerTransitionDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {

    _douto(fromVC)
    _douto(toVC)

    BOOL usingToTransitionStyle = YES;
    if (self.preferSourceViewControllerTransitionStyle) {
        usingToTransitionStyle = !usingToTransitionStyle;
    }
    if (operation == UINavigationControllerOperationPop) {
        usingToTransitionStyle = !usingToTransitionStyle;
    }

    NSString *transitionClassName = usingToTransitionStyle? toVC.RFTransitioningStyle : fromVC.RFTransitioningStyle;
    if (!transitionClassName) {
        transitionClassName = navigationController.RFTransitioningStyle;
    }

    Class transitionClass = NSClassFromString(transitionClassName);
    _douto(transitionClass)

    if (transitionClass) {
        RFAnimationTransitioning *transitionInstance = [transitionClass new];
        if ([transitionInstance respondsToSelector:@selector(setReverse:)]) {
            [transitionInstance setReverse:(UINavigationControllerOperationPop == operation)];
        }
        return transitionInstance;
    }
    return nil;
}

//- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
//
//}

@end
