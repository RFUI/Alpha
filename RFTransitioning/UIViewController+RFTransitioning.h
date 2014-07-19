/*!
    UIViewController (RFTransitioning)
    RFTransitioning

    Copyright (c) 2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    TEST
 */
#import <UIKit/UIKit.h>
#import "RFNavigationPopInteractionController.h"

@interface UIViewController (RFTransitioning)

/**
 Name of RFTransitioningStyle class.
 
 Optional
 */
@property (copy, nonatomic) NSString *RFTransitioningStyle;

@property (strong, nonatomic) id<UIViewControllerInteractiveTransitioning> RFTransitioningInteractionController;

@end
