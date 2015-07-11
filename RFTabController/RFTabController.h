/*!
    RFTabController

    Copyright (c) 2015 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    TEST
 */
#import "RFUI.h"

@protocol RFTabControllerDelegate, RFTabControllerDataSource;

@interface RFTabController : UIViewController <
    RFInitializing
>

#pragma mark - Delegate & DataSource
@property (weak, nonatomic) IBOutlet id<RFTabControllerDelegate> delegate;

/**
 RFTabController support set view controllers directly or provide view controllers through a data source. Ask the data source is preferred.
 */
@property (copy, nonatomic) NSArray *viewControllers;
@property (weak, nonatomic) IBOutlet id<RFTabControllerDataSource> dataSource;

#pragma mark - Index

- (NSUInteger)indexForViewController:(UIViewController *)viewController;
- (UIViewController *)viewControllerAtIndex:(NSUInteger)index;

#pragma mark - Selection

@property (weak, nonatomic) UIViewController *selectedViewController;
@property (assign, nonatomic) NSUInteger selectedIndex;

- (void)setSelectedIndex:(NSUInteger)index animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;
- (void)setSelectedViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

#pragma mark - View Config

/**
 The selected view controller’s view will be added into the wrapper view. If this property not set, the reciver will auto create a view fill it’s view’s bounds as the wrapper view.
 */
@property (weak, nonatomic) IBOutlet UIView *wrapperView;

/**
 一般设置为 tab 按钮所在的容器，设置后会在切换 tab 时禁用 userInteractionEnabled，结束后启用
 */
@property (weak, nonatomic) IBOutlet UIView *tabButtonsContainerView;

#pragma mark - Memory Management

/**
 No implementation. For overwrite
 */
@property (assign, nonatomic) IBInspectable BOOL forceUnloadInvisibleWhenMemoryWarningReceived;

#pragma mark - For Overwrite

- (void)didDataSourceUpdateFromArray:(NSArray *)oldViewControllers toArray:(NSArray *)newViewControllers;

@end


@protocol RFTabControllerDelegate <NSObject>
@optional
- (BOOL)RFTabController:(RFTabController *)tabController shouldSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index;
- (void)RFTabController:(RFTabController *)tabController willSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index;
- (void)RFTabController:(RFTabController *)tabController didSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index;
@end

@protocol RFTabControllerDataSource <NSObject>
@required
- (NSUInteger)RFNumberOfViewControllerInTabController:(RFTabController *)tabController;
- (UIViewController *)RFTabController:(RFTabController *)tabController viewControllerAtIndex:(NSUInteger)index;

@optional

/**
 Default `YES`
 */
- (BOOL)RFTabController:(RFTabController *)tabController shouldUnlodadViewControllerAtIndex:(NSUInteger)index;

@end
