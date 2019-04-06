/*!
    RFTabController

    Copyright (c) 2015, 2019 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    TEST
 */
#import <RFInitializing/RFInitializing.h>
#import <RFKit/RFRuntime.h>

@protocol RFTabControllerDelegate, RFTabControllerDataSource;

@interface RFTabController : UIViewController <
    RFInitializing
>

#pragma mark - Delegate & DataSource
@property (weak, nullable) IBOutlet id<RFTabControllerDelegate> delegate;

/**
 RFTabController support set view controllers directly or provide view controllers through a data source. Ask the data source is preferred.
 */
@property (copy, nullable, nonatomic) NSArray<__kindof UIViewController *> *viewControllers;
@property (weak, nullable, nonatomic) IBOutlet id<RFTabControllerDataSource> dataSource;

#pragma mark - Index

- (NSUInteger)indexForViewController:(nonnull UIViewController *)viewController;
- (nonnull UIViewController *)viewControllerAtIndex:(NSUInteger)index;

#pragma mark - Selection

@property (weak, nullable, nonatomic) UIViewController *selectedViewController;
@property (nonatomic) NSUInteger selectedIndex;

/**
 Reset selectedIndex to NSNotFound.
 */
- (void)resetSelectedIndex;

- (void)setSelectedIndex:(NSUInteger)index animated:(BOOL)animated completion:(nullable void (^)(BOOL finished))completion;
- (void)setSelectedViewController:(nonnull UIViewController *)viewController animated:(BOOL)animated completion:(nullable void (^)(BOOL finished))completion;

#pragma mark - View Config

/**
 The selected view controller’s view will be added into the wrapper view. If this property not set, the reciver will auto create a view fill it’s view’s bounds as the wrapper view.
 */
@property (weak, nullable, nonatomic) IBOutlet UIView *wrapperView;

/**
 一般设置为 tab 按钮所在的容器，设置后会在切换 tab 时禁用 userInteractionEnabled，结束后启用
 */
@property (weak, nullable) IBOutlet UIView *tabButtonsContainerView;

#pragma mark - Memory Management

/**
 No implementation. For overwrite
 */
@property IBInspectable BOOL forceUnloadInvisibleWhenMemoryWarningReceived;

#pragma mark - For Overwrite

- (void)didDataSourceUpdateFromArray:(nullable NSArray<UIViewController *> *)oldViewControllers toArray:(nullable NSArray<UIViewController *> *)newViewControllers;

@end


@protocol RFTabControllerDelegate <NSObject>
@optional
- (BOOL)RFTabController:(nonnull RFTabController *)tabController shouldSelectViewController:(nullable UIViewController *)viewController atIndex:(NSUInteger)index;
- (void)RFTabController:(nonnull RFTabController *)tabController willSelectViewController:(nullable UIViewController *)viewController atIndex:(NSUInteger)index;
- (void)RFTabController:(nonnull RFTabController *)tabController didSelectViewController:(nullable UIViewController *)viewController atIndex:(NSUInteger)index;
@end

@protocol RFTabControllerDataSource <NSObject>
@required
- (NSUInteger)RFNumberOfViewControllerInTabController:(nonnull RFTabController *)tabController;
- (nonnull UIViewController *)RFTabController:(nonnull RFTabController *)tabController viewControllerAtIndex:(NSUInteger)index;

@optional

/**
 Default `YES`
 */
- (BOOL)RFTabController:(nonnull RFTabController *)tabController shouldUnlodadViewControllerAtIndex:(NSUInteger)index;

@end
