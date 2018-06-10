/*!
 RFNavigationController
 RFUI
 
 Copyright (c) 2014-2016, 2018 BB9z
 https://github.com/RFUI/Alpha
 
 The MIT License (MIT)
 http://www.opensource.org/licenses/mit-license.php
 */
#import <RFInitializing/RFInitializing.h>
#import <RFKit/RFRuntime.h>


@protocol RFNavigationBehaving;
@class RFNavigationPopInteractionController;

typedef NSString* RFViewControllerAppearanceAttributeKey NS_STRING_ENUM;

/**
 
 */
NS_CLASS_AVAILABLE_IOS(7_0)
@interface RFNavigationController : UINavigationController <
    RFInitializing,
    UINavigationControllerDelegate
>

#pragma mark - Appearance Control

/**
 If any attribute’s kind is mismatched, an NSRangeException is raised.
 */
@property (copy, null_resettable, nonatomic) NSDictionary<RFViewControllerAppearanceAttributeKey, id> *defaultAppearanceAttributes;

/**
 Subclasses may override this method to support additional attributes or change the default behaviors.
 */
- (void)updateNavigationAppearanceWithAppearanceAttributes:(nonnull NSDictionary<RFViewControllerAppearanceAttributeKey, id> *)attributes animationDuration:(NSTimeInterval)animationDuration animated:(BOOL)animated;

/**
 Call this method to update the reciver's status, such as navigationBar/bottomBar hidden/unhidden.

 @param viewController If the view controller is not managed by the reciver, only status bar appearance will change.
 */
- (void)updateNavigationAppearanceWithViewController:(nullable __kindof UIViewController *)viewController animated:(BOOL)animated;

/**
 Update appearance with attributes specified by the top view controller.
 */
- (void)updateCurrentNavigationAppearanceAnimated:(BOOL)animated;

#pragma mark - Bottom Bar

/**
 A Boolean indicating whether the navigation controller’s built-in bottom bar is visible.
 
 This bottom bar is a custom view, not the same with navigation controller’s toolbar.
 */
@property (nonatomic) BOOL bottomBarHidden;

/**
 Height relative to the bottomLayoutGuide.
 
 The value cann't be 0. Default height is 48.
 */
@property (nonatomic) IBInspectable CGFloat bottomBarHeight;

/**
 Changes the visibility of the navigation controller’s built-in bottom bar.
 */
- (void)setBottomBarHidden:(BOOL)hidden animated:(BOOL)animated;

@property (nullable, nonatomic) IBOutlet UIView *bottomBar;

/**
 A Boolean value indicating whether the bottom bar is translucent (YES) or not (NO).
 
 If the bottom bar is translucent, layout will be extended includes opaque bars.
 */
@property IBInspectable BOOL translucentBottomBar;

/**
 A Boolean value indicating whether the bottom bar fades in and out as it is shown or hidden, respectively.
 */
@property IBInspectable BOOL bottomBarFadeAnimation;

#pragma mark - Status Bar

/**
 If you want modify staus bar manually through UIApplication, you need set UIViewControllerBasedStatusBarAppearance to NO in application’s info.plist.
 
 Set YES will let the reciver ask current view controller for status bar appearance and then update.

 Default No.
 
 iOS introduce a build-in mechanism after iOS 7 and works fine. This leaves for legacy usages and will be removed at year 2019.
 
 @bug It works fine at most of time, but using it may lead the navigation bar to an abnormal status and can't be restored. It happens rarely and randomly, and can not be reproduced.
 */
@property IBInspectable BOOL handelViewControllerBasedStatusBarAppearance DEPRECATED_ATTRIBUTE;

#pragma mark - Delegate

- (void)setDelegate:(nullable id<UINavigationControllerDelegate>)delegate __attribute__((unavailable("You can’t change RFNavigationController’s delegtae")));

@property (nullable) void (^willShowViewControllerBlock)(UINavigationController *__nonnull navigationController, UIViewController *__nonnull viewController, BOOL animated);
@property (nullable) void (^didShowViewControllerBlock)(UINavigationController *__nonnull navigationController, UIViewController *__nonnull viewController, BOOL animated);

#pragma mark - Transitioning

/// Default NO
@property BOOL preferSourceViewControllerTransitionStyle;

@property (readonly, weak, nullable, nonatomic) RFNavigationPopInteractionController *currentPopInteractionController;
@property (readonly, weak, nullable, nonatomic) UIGestureRecognizer *currentPopInteractionGestureRecognizer;

@end

@protocol RFNavigationBehaving <NSObject>
@optional

/**
 Ask current view controller whether should pop or not when user tap the back button.

 @return Return NO to cancel pop.
 */
- (BOOL)shouldPopOnBackButtonTappedForNavigationController:(nonnull RFNavigationController *)navigation DEPRECATED_ATTRIBUTE;

/**
 Appearance attributes of current view controller.
 
 If attribute accepts non NSNumber kind of value, you can pass NSNull to reset.

 @return An NSDictionary object containing appearance attributes.
 */
- (nullable NSDictionary<RFViewControllerAppearanceAttributeKey, id> *)RFNavigationAppearanceAttributes;

@end


@interface UIViewController (RFNavigationBehaving)

/**
 Generally, you dont need call this method manually unless there is an interactive transition.
 
 When an interactive transition canceled, you should call this method in viewWillApear:.
 */
- (void)updateNavigationAppearanceAnimated:(BOOL)animated;

@end

#pragma mark - View controller-based appearance attributes

NS_ASSUME_NONNULL_BEGIN

/// The value of this attribute is an NSNumber object containing a boolean value
/// indicating the navigation bar should to be hidden or shown.
UIKIT_EXTERN RFViewControllerAppearanceAttributeKey const RFViewControllerPrefersNavigationBarHiddenAttribute;

/// The value of this attribute is an UIColor or NSNull object.
/// Use this attribute to specify the tint color to apply to the navigation bar background.
UIKIT_EXTERN RFViewControllerAppearanceAttributeKey const RFViewControllerPreferredNavigationBarTintColorAttribute;

/// The value of this attribute is an UIColor or NSNull object.
/// Use this attribute to specify the tint color to apply to the navigation items and bar button items.
UIKIT_EXTERN RFViewControllerAppearanceAttributeKey const RFViewControllerPreferredNavigationBarItemColorAttribute;

/// The value of this attribute is an NSDictionary or NSNull object containing text attributes.
/// Use this attribute to specify display attributes for the bar’s title text.
UIKIT_EXTERN RFViewControllerAppearanceAttributeKey const RFViewControllerPreferredNavigationBarTitleTextAttributes;

/// The value of this attribute is an NSNumber object containing a boolean value
/// indicating the bottom bar should to be hidden or shown.
UIKIT_EXTERN RFViewControllerAppearanceAttributeKey const RFViewControllerPrefersBottomBarShownAttribute;

/// The value of this attribute is an float NSNumber object (0-1)
/// indicating the navigation bar backgroundImage alpha.
UIKIT_EXTERN RFViewControllerAppearanceAttributeKey const RFViewControllerPreferredNavigationBarBackgroundAlphaAttributes;

/// The value of this attribute is an UIImage object
/// indicating the navigation bar backgroundImage.
UIKIT_EXTERN RFViewControllerAppearanceAttributeKey const RFViewControllerPreferredNavigationBarBackgroundImageAttribute;

UIKIT_EXTERN RFViewControllerAppearanceAttributeKey const RFViewControllerPreferredNavigationBackImageAttributes DEPRECATED_MSG_ATTRIBUTE("Use .preferredNavigationBarBackgroundImageAttribute instead");

/// Status bar appearance attributes are deprecated.
/// @see handelViewControllerBasedStatusBarAppearance

// The value of this attribute is an NSNumber object containing a boolean value
// indicating the status bar should to be hidden or shown.
UIKIT_EXTERN RFViewControllerAppearanceAttributeKey const RFViewControllerPrefersStatusBarHiddenAttribute DEPRECATED_ATTRIBUTE;

// The value of this attribute is an NSNumber object containing an UIStatusBarAnimation value
// indicating the animation style to use for hiding and showing the status bar for the view controller.
UIKIT_EXTERN RFViewControllerAppearanceAttributeKey const RFViewControllerPreferredStatusBarUpdateAnimationAttribute DEPRECATED_ATTRIBUTE;

// The value of this attribute is an NSNumber object containing an UIStatusBarStyle value
// indicating the preferred status bar style for the view controller.
UIKIT_EXTERN RFViewControllerAppearanceAttributeKey const RFViewControllerPreferredStatusBarStyleAttribute DEPRECATED_ATTRIBUTE;

NS_ASSUME_NONNULL_END

