/*!
    RFPageTabController

    Copyright (c) 2015 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    TEST
 */
#import "RFTabController.h"

@interface RFPageTabController : RFTabController
@property (readonly, nonatomic) UIPageViewController *pageViewController;

@property (assign, nonatomic) IBInspectable BOOL scrollEnabled;
@end
