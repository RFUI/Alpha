/*!
    RFNavigationController
    RFUI

    Copyright (c) 2014-2016 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    BETA
 */
#import "RFUI.h"
#import "RFNavigationControllerTransitionDelegate.h"

@protocol RFNavigationBehaving;

/**
 
 */
NS_CLASS_AVAILABLE_IOS(7_0)
@interface RFNavigationController : UINavigationController <
    RFInitializing,
    RFNavigationControllerAppearanceUpdating
>

/**
 The first navigation controller instance will become the globalNavigationController automatically.
 */
+ (nullable instancetype)globalNavigationController;

/**
 Sets the default global navigation controller to the given instance.
 */
+ (void)setGlobalNavigationController:(nullable __kindof RFNavigationController *)navigationController;

/**
 Call this method to update the reciver's status, such as navigationBar/bottomBar hidden/unhidden.
 */
- (void)updateNavigationAppearanceWithViewController:(nullable __kindof UIViewController *)viewController animated:(BOOL)animated;

/**
 Determine navigaiton bar should hidden or not by default.

 If the reciver is load from nib, this property will be set with storyboard setting.
 */
@property (nonatomic) IBInspectable BOOL preferredNavigationBarHidden;

#pragma mark - Bottom Bar

/**
 A Boolean indicating whether the navigation controller’s built-in bottom bar is visible.
 
 This bottom bar is a custom view, not the same with navigation controller’s toolbar.
 */
@property (nonatomic) BOOL bottomBarHidden;

/**
 Changes the visibility of the navigation controller’s built-in bottom bar.
 */
- (void)setBottomBarHidden:(BOOL)hidden animated:(BOOL)animated;

@property (nonatomic, nullable, strong) IBOutlet UIView *bottomBar;

/**
 A Boolean value indicating whether the bottom bar is translucent (YES) or not (NO).
 
 If the bottom bar is translucent, layout will be extended includes opaque bars.
 */
@property (nonatomic) IBInspectable BOOL translucentBottomBar;

/**
 A Boolean value indicating whether the bottom bar fades in and out as it is shown or hidden, respectively.
 */
@property (nonatomic) IBInspectable BOOL bottomBarFadeAnimation;

#pragma mark - Status Bar

/**
 If you want modify staus bar manually through UIApplication, you need set UIViewControllerBasedStatusBarAppearance to NO in application’s info.plist.
 
 Set YES will let the reciver ask current view controller for status bar appearance and then update.

 Default No.
 */
@property (nonatomic) IBInspectable BOOL handelViewControllerBasedStatusBarAppearance;

/// Default `NO`.
@property (nonatomic) IBInspectable BOOL prefersStatusBarHidden;

/// Default `UIStatusBarStyleDefault`.
@property (nonatomic) UIStatusBarStyle preferredStatusBarStyle;

/// Default `UIStatusBarAnimationFade`.
@property (nonatomic) UIStatusBarAnimation preferredStatusBarUpdateAnimation;

#pragma mark - Delegate

///
@property (nonatomic, nullable, strong) IBOutlet RFNavigationControllerTransitionDelegate *forwardDelegate;

@end

@protocol RFNavigationBehaving <NSObject>
@optional

/**
 Specifies whether the view controller prefers the navigation bar to be hidden or shown.

 @return A Boolean value of YES specifies the navigation bar should be hidden. Default value is NO.
 */
- (BOOL)prefersNavigationBarHidden;

//
- (nullable UIColor *)preferredNavigationBarTintColor;

//
- (nullable UIColor *)preferredNavigationBarItemColor;

//
- (nullable NSDictionary <NSString *,id> *)preferredNavigationBarTitleTextAttributes;

/**
 Ask current view controller whether should pop or not when user tap the back button.

 @return Return NO to cancel pop.
 */
- (BOOL)shouldPopOnBackButtonTappedForNavigationController:(nonnull RFNavigationController *)navigation;

/**
 Specifies whether the view controller prefers the bottom bar to be hidden or shown.

 @return A Boolean value of YES specifies the bottom bar should be visiable. Default value is NO.
 */
- (BOOL)prefersBottomBarShown;

/**
 Specifies whether the view controller prefers the status bar to be hidden or shown
 */
- (BOOL)prefersStatusBarHidden;

/**
 The preferred status bar style for the view controller.
 */
- (UIStatusBarStyle)preferredStatusBarStyle;

/**
 Specifies the animation style to use for hiding and showing the status bar for the view controller.
 */
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation;


@end


@interface UIViewController (RFNavigationBehaving)

/**
 Generally, you dont need call this method manually unless there is an interactive transition.
 
 When an interactive transition canceled, you should call this method in viewWillApear:.
 */
- (void)updateNavigationAppearanceAnimated:(BOOL)animated;

@end
