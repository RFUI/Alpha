/*!
    RFContainerView

    Copyright (c) 2015-2016 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Alpha
 */
#import "RFUI.h"

/**
 Embed view controller into another view controller.
 */
IB_DESIGNABLE
@interface RFContainerView : UIView <
    RFInitializing
>


/**
 用于指定嵌入 view controller 所在的 Storyboard

 nil 为当前 Storyboard
 */
@property (nonatomic, nullable, copy) IBInspectable NSString *storyboardName;

/**
 嵌入 view controller 的 Storyboard ID，为空使用 Storyboard 的初始视图
 */
@property (nonatomic, nullable, copy) IBInspectable NSString *instantiationIdentifier;

/**
 YES 时不自动载入子 view controller
 */
@property IBInspectable BOOL lazyLoad;

///
@property (readonly) BOOL embedViewControllerLoaded;

/// 
@property (nonatomic, nullable, readonly) __kindof UIViewController *embedViewController;

/**
 加载并嵌入 view controller 到所属 view controller
 */
- (void)loadEmbedViewController;

/**
 @param prepareBlock This block called before the embed view controller added into the parent view controller.
 */
- (void)loadEmbedViewControllerWithPrepareBlock:(RF_NOESCAPE void (^__nullable)(__kindof UIViewController *__nonnull viewController, RFContainerView *__nonnull container))prepareBlock;

/**
 */
- (void)unloadEmbedViewController:(BOOL)shouldReleaseEmbedViewController;

/**
 设置 parentViewController 时会自动执行 loadEmbedViewController
 */
@property (nonatomic, nullable, weak) IBOutlet UIViewController *parentViewController;

@end
