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
    RFInitializing
>

/**
 Generally, the first navigation controller instance will become the globalNavigationController.
 */
+ (instancetype)globalNavigationController;

/**
 Determine navigaiton bar should hidden or not by default.

 If the reciver is load from nib, this property will be set with storyboard setting.
 */
@property (assign, nonatomic) BOOL preferredNavigationBarHidden;

#pragma mark - Tab Bar

/**
 A Boolean indicating whether the navigation controller’s built-in bottom bar is visible.
 */
@property (assign, nonatomic) BOOL bottomBarHidden;

/**
 Changes the visibility of the navigation controller’s built-in bottom bar.
 */
- (void)setBottomBarHidden:(BOOL)hidden animated:(BOOL)animated;

@property (strong, nonatomic) IBOutlet UIView *bottomBar;

#pragma mark - Delegate
@property (weak, nonatomic) IBOutlet id<UINavigationControllerDelegate> forwardDelegate;

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end

@protocol RFNavigationBehaving <NSObject>
@optional

/**
 Specifies whether the view controller prefers the navigation bar to be hidden or shown.

 @return A Boolean value of YES specifies the navigation bar should be hidden. Default value is NO.
 */
- (BOOL)prefersNavigationBarHiddenForNavigationController:(RFNavigationController *)navigation;

/**
 Ask current view controller whether should pop or not when user tap the back button.

 @return Return NO to cancel pop.
 */
- (BOOL)shouldPopOnBackButtonTappedForNavigationController:(RFNavigationController *)navigation;


- (BOOL)prefersBottomBarShown;

@end
