/*!
    RFNavigationController
    RFUI

    Copyright (c) 2014 BB9z
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
NS_CLASS_AVAILABLE_IOS(7_0) @interface RFNavigationController : UINavigationController <
    RFInitializing,
    RFNavigationControllerAppearanceUpdating
>

/**
 Generally, the first navigation controller instance will become the globalNavigationController.
 */
+ (instancetype)globalNavigationController;

/**
 Call this method to update the reciver's status, such as navigationBar/bottomBar hidden/unhidden.
 */
- (void)updateNavigationAppearanceWithViewController:(id)viewController animated:(BOOL)animated;

/**
 Determine navigaiton bar should hidden or not by default.

 If the reciver is load from nib, this property will be set with storyboard setting.
 */
@property (assign, nonatomic) IBInspectable BOOL preferredNavigationBarHidden;

#pragma mark - Bottom Bar

/**
 A Boolean indicating whether the navigation controller’s built-in bottom bar is visible.
 
 This bottom bar is a custom view, not the same with navigation controller’s toolbar.
 */
@property (assign, nonatomic) BOOL bottomBarHidden;

/**
 Changes the visibility of the navigation controller’s built-in bottom bar.
 */
- (void)setBottomBarHidden:(BOOL)hidden animated:(BOOL)animated;

@property (strong, nonatomic) IBOutlet UIView *bottomBar;

/**
 A Boolean value indicating whether the bottom bar is translucent (YES) or not (NO).
 
 If the bottom bar is translucent, layout will be extended includes opaque bars.
 */
@property (assign, nonatomic) IBInspectable BOOL translucentBottomBar;

/**
 A Boolean value indicating whether the bottom bar fades in and out as it is shown or hidden, respectively.
 */
@property (assign, nonatomic) IBInspectable BOOL bottomBarFadeAnimation;

#pragma mark - Status Bar

/**
 If you want modify staus bar manually through UIApplication, you need set UIViewControllerBasedStatusBarAppearance to NO in application’s info.plist.
 
 Set YES will let the reciver ask current view controller for status bar appearance and then update.

 Default No.
 */
@property (assign, nonatomic) IBInspectable BOOL handelViewControllerBasedStatusBarAppearance;

/// Default `NO`.
@property (assign, nonatomic) IBInspectable BOOL prefersStatusBarHidden;

/// Default `UIStatusBarStyleDefault`.
@property (assign, nonatomic) UIStatusBarStyle preferredStatusBarStyle;

/// Default `UIStatusBarAnimationFade`.
@property (assign, nonatomic) UIStatusBarAnimation preferredStatusBarUpdateAnimation;

#pragma mark - Delegate
@property (strong, nonatomic) IBOutlet RFNavigationControllerTransitionDelegate *forwardDelegate;

@end

@protocol RFNavigationBehaving <NSObject>
@optional

/**
 Specifies whether the view controller prefers the navigation bar to be hidden or shown.

 @return A Boolean value of YES specifies the navigation bar should be hidden. Default value is NO.
 */
- (BOOL)prefersNavigationBarHidden;

- (BOOL)prefersNavigationBarHiddenForNavigationController:(RFNavigationController *)navigation  DEPRECATED_ATTRIBUTE;

/**
 Ask current view controller whether should pop or not when user tap the back button.

 @return Return NO to cancel pop.
 */
- (BOOL)shouldPopOnBackButtonTappedForNavigationController:(RFNavigationController *)navigation;

/**
 Specifies whether the view controller prefers the bottom bar to be hidden or shown.

 @return A Boolean value of YES specifies the bottom bar should be visiable. Default value is NO.
 */
- (BOOL)prefersBottomBarShown;

@end


@interface UIViewController (RFNavigationBehaving)

/**
 Generally, you dont need call this method manually unless there is an interactive transition.
 
 When an interactive transition canceled, you should call this method in viewWillApear:.
 */
- (void)updateNavigationAppearanceAnimated:(BOOL)animated;

@end
