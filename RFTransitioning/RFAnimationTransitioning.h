/*!
    RFReversibleAnimationTransitioning
    RFTransitioning

    Copyright (c) 2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    TEST
 */
#import "RFUI.h"
#import "RFFeatureSupport.h"

NS_CLASS_AVAILABLE_IOS(7_0) @interface RFAnimationTransitioning : NSObject <
    UIViewControllerAnimatedTransitioning,
    RFForSubclass,
    RFInitializing
>

/**
 The direction of the animation.
 */
@property (nonatomic, assign) BOOL reverse;

/**
 The animation duration.
 */
@property (nonatomic, assign) NSTimeInterval duration;

/**
 Subclass must overwrite this method to perform the transition animations.
 */
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView;

/**
 Class name of a UIViewControllerInteractiveTransitioning object.
 */
@property (copy, nonatomic) NSString *interactionControllerType;

@property (weak, nonatomic) id interactionController;
@end
