/*!
    RFNavigationPopInteractionController
    RFTransitioning

    Copyright (c) 2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    TEST
 */
#import "RFUI.h"

@interface RFNavigationPopInteractionController : UIPercentDrivenInteractiveTransition <
    RFInitializing
>

@property (weak, nonatomic) IBOutlet UIViewController *viewController;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *gestureRecognizer;

@property (assign, nonatomic) BOOL interactionInProgress;
@end
