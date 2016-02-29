/*!
    RFPageTabController

    Copyright (c) 2015-2016 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    TEST
 */
#import "RFTabController.h"

@interface RFPageTabController : RFTabController
@property (nonatomic, nonnull, readonly) UIPageViewController *pageViewController;

/**
 Calling this method does not cause the delegate to receive a RFTabController:didSelectViewController:atIndex: message.
 */
- (void)setSelectedIndex:(NSUInteger)newSelectedIndex animated:(BOOL)animated completion:(void (^_Nullable)(BOOL))completion;

@property (nonatomic) IBInspectable BOOL scrollEnabled;

/**
 Default `NO`
 */
@property (nonatomic) IBInspectable BOOL noticeDelegateWhenSelectionChangedProgrammatically;
@end
