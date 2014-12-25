/*!
    RFNavigationControllerTransitionDelegate
    RFTransitioning

    Copyright (c) 2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    TEST
 */
#import "RFDelegateChain.h"
#import "UIViewController+RFTransitioning.h"

NS_CLASS_AVAILABLE_IOS(7_0) @interface RFNavigationControllerTransitionDelegate : RFDelegateChain <
    UINavigationControllerDelegate
>
@property (weak, nonatomic) IBOutlet id<UINavigationControllerDelegate> delegate;

/// Default NO
@property (assign, nonatomic) BOOL preferSourceViewControllerTransitionStyle;

@property (readonly, weak, nonatomic) RFNavigationPopInteractionController *currentPopInteractionController;
@property (readonly, weak, nonatomic) UIGestureRecognizer *currentPopInteractionGestureRecognizer;

@end

@protocol RFNavigationControllerAppearanceUpdating <NSObject>
@optional
- (void)updateNavigationAppearanceWithViewController:(id)viewController animated:(BOOL)animated;

@end