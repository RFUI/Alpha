/*!
    RFTabBarController

    Copyright (c) 2015 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    TEST
 */
#import "RFUI.h"

@protocol RFTabBarControllerDelegate;

@interface RFTabBarController : UIViewController <
RFInitializing
>
@property (copy, nonatomic) NSArray *viewControllers;
@property (weak, nonatomic) UIViewController *selectedViewController;
@property (assign, nonatomic) NSUInteger selectedIndex;
@property (weak, nonatomic) IBOutlet id<RFTabBarControllerDelegate> delegate;

- (void)setSelectedIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)setSelectedViewController:(UIViewController *)viewController animated:(BOOL)animated;

@property (weak, nonatomic) IBOutlet UIView *wrapperView;

/**
 一般设置为 tab 按钮所在的容器，设置后会在切换 tab 时禁用 userInteractionEnabled，结束后启用
 */
@property (weak, nonatomic) IBOutlet UIView *tabButtonsContainerView;

#pragma mark - Memory Management

@property (assign, nonatomic) IBInspectable BOOL forceUnloadInvisibleWhenMemoryWarningReceived;

@end


@protocol RFTabBarControllerDelegate <NSObject>
@optional
- (BOOL)RFTabBarController:(RFTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index;
- (void)RFTabBarController:(RFTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index;
@end
