/*!
 RFPageTabController
 
 Copyright (c) 2015-2016, 2018 BB9z
 https://github.com/RFUI/Alpha
 
 The MIT License (MIT)
 http://www.opensource.org/licenses/mit-license.php
 */
#import "RFTabController.h"

@interface RFPageTabController : RFTabController
@property (readonly, nonnull, nonatomic) UIPageViewController *pageViewController;

/**
 This property don't support KVO.
 */
@property (readonly, nonatomic) BOOL isTransitioning;

/**
 Calling this method does not cause the delegate to receive a RFTabController:didSelectViewController:atIndex: message.
 */
- (void)setSelectedIndex:(NSUInteger)newSelectedIndex animated:(BOOL)animated completion:(void (^__nullable)(BOOL))completion;

@property (nonatomic) IBInspectable BOOL scrollEnabled;

/**
 Default `NO`
 */
@property (nonatomic) IBInspectable BOOL noticeDelegateWhenSelectionChangedProgrammatically;
@end
