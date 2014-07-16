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

@interface RFNavigationControllerTransitionDelegate : RFDelegateChain <
    UINavigationControllerDelegate
>
@property (weak, nonatomic) IBOutlet id<UINavigationControllerDelegate> delegate;

/// Default NO
@property (assign, nonatomic) BOOL preferSourceViewControllerTransitionStyle;
@end
