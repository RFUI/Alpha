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

@property (assign, nonatomic) BOOL interactionInProgress;

@property (weak, nonatomic) IBOutlet UIViewController *viewController;

#pragma mark - Gestures
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *gestureRecognizer;

- (void)installGestureRecognizer;
- (void)uninstallGestureRecognizer;
@end
