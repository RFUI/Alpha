/*!
    RFNavigationController
    RFUI

    Copyright (c) 2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    TEST
 */
#import "RFUI.h"

@interface RFNavigationController : UINavigationController <
    UINavigationControllerDelegate
>

+ (instancetype)globalNavigationController;

@end

@protocol RFNavigationBehaving <NSObject>
@optional

/**
 Ask current view controller whether should pop or not when user tap the back button.

 @return Return NO to cancel pop.
 */
- (BOOL)shouldPopOnBackButtonTappedForNavigationController:(RFNavigationController *)navigation;

@end
