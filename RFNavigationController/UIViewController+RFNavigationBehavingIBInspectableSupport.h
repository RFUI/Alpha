/*!
    UIViewController (RFNavigationBehavingIBInspectableSupport)
    RFNavigationController

    Copyright (c) 2016 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    BETA
 */
#import "RFNavigationController.h"

/**
 Add support for setting RFNavigationBehaving properties in interface builder.
 */
@interface UIViewController (RFNavigationBehavingIBInspectableSupport) <
    RFNavigationBehaving
>

@property (nonatomic) IBInspectable BOOL prefersNavigationBarHidden;

@property (nonatomic, nullable, copy) IBInspectable UIColor *preferredNavigationBarTintColor;

//  - (nullable UIColor *)preferredNavigationBarItemColor;

//  - (nullable NSDictionary <NSString *,id> *)preferredNavigationBarTitleTextAttributes;

@property (nonatomic) IBInspectable BOOL prefersBottomBarShown;

@property (nonatomic) IBInspectable BOOL prefersStatusBarHidden;

@property (nonatomic) IBInspectable UIStatusBarStyle preferredStatusBarStyle;

// - (UIStatusBarAnimation)preferredStatusBarUpdateAnimation;

@end
