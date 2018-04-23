/*!
    RFWindow
    RFUI

    Copyright (c) 2012, 2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    TEST
 */
#import <UIKit/UIKit.h>
#import <RFInitializing/RFInitializing.h>


/**
 This window should be full screen all the time.
 
 It need a rootViewController to display something.
 You can creat an RFWindowTouchForwardView in the rootViewController’s view to let user touch something below this window.
 */
@interface RFWindow : UIWindow <
    RFInitializing
>
@end

@interface UIWindow (RFWindowLevel)
- (void)bringAboveWindow:(UIWindow *)window;
- (void)sendBelowWindow:(UIWindow *)window;
@end

@interface RFWindowTouchForwardView : UIView
@end
