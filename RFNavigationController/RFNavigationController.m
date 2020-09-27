
#import "RFNavigationController.h"
#import "RFAnimationTransitioning.h"
#import "UIViewController+RFTransitioning.h"
#import <RFKit/NSError+RFKit.h>
#import <RFKit/UIView+RFAnimate.h>
#import <RFKit/UIView+RFKit.h>
#import <RFKit/UIViewController+RFInterfaceOrientation.h>

@interface RFNavigationBottomBar : UIView
@end

@interface RFNavigationController () <
    UIGestureRecognizerDelegate
>
@property (nonatomic) RFNavigationBottomBar *bottomBarHolder;
@property (weak) NSLayoutConstraint *_RFNavigationController_bottomHeightConstraint;
@property (weak) UIView *_RFNavigationController_transitionView;
@property (weak, nonatomic) UIViewController *statusBarHideChangeDelayViewController;

@property (weak, nonatomic) RFNavigationPopInteractionController *currentPopInteractionController;
@property (weak, nonatomic) UIGestureRecognizer *currentPopInteractionGestureRecognizer;
@property BOOL _RFNavigationController_buidlinGestureRecognizerEnabled;
@end

@implementation RFNavigationController
RFUIInterfaceOrientationSupportNavigation
RFInitializingRootForUIViewController

- (void)onInit {
    [super setDelegate:self];
}

- (void)afterInit {
    self.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self._RFNavigationController_transitionView = self.view.subviews.firstObject;
    [self _RFNavigationController_setupBottomBarLayoutIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateCurrentNavigationAppearanceAnimated:animated];
}

//! REF: http://stackoverflow.com/a/20923477
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.transitionCoordinator.isAnimated) {
        return NO;
    }

    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        if (self.currentPopInteractionGestureRecognizer) {
            return NO;
        }
    }

    if ([gestureRecognizer.view respondsToSelector:@selector(gestureRecognizerShouldBegin:)]) {
        BOOL result = [gestureRecognizer.view gestureRecognizerShouldBegin:gestureRecognizer];
        return result;
    }
    return YES;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self _RFNavigationController_updateBottomBarLayoutIfNeeded];
}

#pragma mark - Bottom bar

- (void)setBottomBarHidden:(BOOL)bottomBarHidden {
    _bottomBarHidden = bottomBarHidden;
    if (!self.isViewLoaded) return;
    if (self.bottomBarFadeAnimation) {
        self.bottomBarHolder.alpha = bottomBarHidden? 0 : 1;
    }
    [self _RFNavigationController_updateBottomBarLayoutIfNeeded];
}

- (void)setBottomBarHidden:(BOOL)hidden animated:(BOOL)animated {
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animated:animated beforeAnimations:^{
    } animations:^{
        self.bottomBarHidden = hidden;
    } completion:nil];
}

- (RFNavigationBottomBar *)bottomBarHolder {
    if (!_bottomBarHolder) {
        RFNavigationBottomBar *bar = [RFNavigationBottomBar new];
        bar.translatesAutoresizingMaskIntoConstraints = NO;
        _bottomBarHolder = bar;
    }
    return _bottomBarHolder;
}

- (void)setBottomBar:(UIView *)bottomBar {
    if (_bottomBar == bottomBar) return;
    if (_bottomBar.superview == self.bottomBarHolder) {
        [_bottomBar removeFromSuperview];
    }
    [self _RFNavigationController_setupBottomBarLayoutIfNeeded];
    _bottomBar = bottomBar;
    self.bottomBarHidden = self.bottomBarHidden;
}

- (void)_RFNavigationController_updateBottomBarLayoutIfNeeded {
    BOOL barHidden = self.bottomBarHidden;
    CGFloat barHeight = self.bottomBar? self.bottomBarHeight : 0;
    CGFloat bottomGuideSize = 0;
    if (@available(iOS 11.0, *)) {
        bottomGuideSize = self.view.safeAreaInsets.bottom;
    }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        bottomGuideSize = self.bottomLayoutGuide.length;
#pragma clang diagnostic pop
    }
    NSLayoutConstraint *layoutConstraint = self._RFNavigationController_bottomHeightConstraint;
    if (layoutConstraint) {
        CGFloat bottomConstant = barHidden? -bottomGuideSize : barHeight;
        if (layoutConstraint.constant != bottomConstant) {
            layoutConstraint.constant = bottomConstant;
        }
    }
    
    UIView *transitionView = self._RFNavigationController_transitionView;
    if (self.bottomBar && transitionView) {
        CGFloat height = self.view.height - transitionView.y - ((!barHidden && !self.translucentBottomBar)? barHeight + bottomGuideSize : 0);
        if (transitionView.height != height) {
            transitionView.height = height;
        }
    }
}

- (void)_RFNavigationController_setupBottomBarLayoutIfNeeded {
    UIView *bottomBar = self.bottomBar;
    if (!bottomBar || !self.isViewLoaded) return;
    
    UIView *holder = self.bottomBarHolder;
    if (!holder.superview) {
        holder.frame = self.view.bounds;
        if (@available(iOS 11.0, *)) {
            [holder resizeWidth:RFMathNotChange height:self.bottomBarHeight +  self.additionalSafeAreaInsets.bottom resizeAnchor:RFResizeAnchorBottom];
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [holder resizeWidth:RFMathNotChange height:self.bottomBarHeight + self.bottomLayoutGuide.length resizeAnchor:RFResizeAnchorBottom];
#pragma clang diagnostic pop
        }
        [self.view addSubview:holder];

        NSLayoutConstraint *top = nil;
        if (@available(iOS 11.0, *)) {
            UILayoutGuide *safeGuide = self.view.safeAreaLayoutGuide;
            top = [safeGuide.bottomAnchor constraintEqualToAnchor:holder.topAnchor constant:self.bottomBarHeight];
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            top = [NSLayoutConstraint constraintWithItem:self.bottomLayoutGuide attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:holder attribute:NSLayoutAttributeTop multiplier:1 constant:self.bottomBarHeight];
#pragma clang diagnostic pop
        }
        self._RFNavigationController_bottomHeightConstraint = top;
        NSLayoutConstraint *bottom = [holder.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor];
        bottom.priority = 999;
        [NSLayoutConstraint activateConstraints:@[
            top,
            [holder.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
            [holder.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
            bottom
        ]];
    }
    
    if (bottomBar.superview != holder) {
        [holder addSubview:bottomBar resizeOption:RFViewResizeOptionFill];
        bottomBar.autoresizingMask = UIViewAutoresizingFlexibleSize;
        bottomBar.translatesAutoresizingMaskIntoConstraints = YES;
    }
}

@synthesize bottomBarHeight = _bottomBarHeight;
- (CGFloat)bottomBarHeight {
    if (_bottomBarHeight == 0) {
        if (self.bottomBar) {
            _bottomBarHeight = self.bottomBar.height;
        }
        else {
            _bottomBarHeight = 48;
        }
    }
    return _bottomBarHeight;
}
- (void)setBottomBarHeight:(CGFloat)bottomBarHeight {
    _bottomBarHeight = bottomBarHeight;
    if (self._RFNavigationController_bottomHeightConstraint && bottomBarHeight != 0) {
        self._RFNavigationController_bottomHeightConstraint.constant = bottomBarHeight;
    }
}

#pragma mark - Appearance update

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@synthesize defaultAppearanceAttributes = _defaultAppearanceAttributes;

- (NSDictionary<RFViewControllerAppearanceAttributeKey,id> *)defaultAppearanceAttributes {
    if (_defaultAppearanceAttributes) return _defaultAppearanceAttributes;

    UINavigationBar *nb = self.navigationBar;
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:10];
    dic[RFViewControllerPrefersNavigationBarHiddenAttribute] = @(self.navigationBarHidden);
    dic[RFViewControllerPreferredNavigationBarTintColorAttribute] = nb.barTintColor?: NSNull.null;
    dic[RFViewControllerPreferredNavigationBarItemColorAttribute] = nb.tintColor?: NSNull.null;
    dic[RFViewControllerPreferredNavigationBarTitleTextAttributes] = nb.titleTextAttributes?: NSNull.null;
    dic[RFViewControllerPrefersBottomBarShownAttribute] = @(!self.bottomBarHidden);
    dic[RFViewControllerPreferredNavigationBarBackgroundAlphaAttributes] = @1;
    dic[RFViewControllerPreferredNavigationBarBackgroundImageAttribute] = NSNull.null;

    _defaultAppearanceAttributes = dic.copy;
    return _defaultAppearanceAttributes;
}

- (void)setDefaultAppearanceAttributes:(NSDictionary<RFViewControllerAppearanceAttributeKey, id> *)defaultAppearanceAttributes {
    NSError __autoreleasing *e = nil;
    if ([self validateAppearanceAttributes:defaultAppearanceAttributes error:&e]) {
        _defaultAppearanceAttributes = defaultAppearanceAttributes;
    }
    else {
        [NSException raise:NSInvalidArgumentException format:@"%@", e.localizedDescription];
    }
}

static BOOL _attributeCheck(NSDictionary *dic, NSString *key, Class kind, NSError **outError) {
    id value = dic[key];
    if (!value
        || (value == NSNull.null && ![kind isSubclassOfClass:NSNumber.class])) {
        return YES;
    }

    if (![(NSObject *)value isKindOfClass:kind]) {
        if (*outError) {
            *outError = [NSError errorWithDomain:@"RFNavigationController" code:2 localizedDescription:[NSString stringWithFormat:@"Expect %@ attribute is kind of %@", key, kind]];
        }
        return NO;
    }
    return YES;
}

- (BOOL)validateAppearanceAttributes:(NSDictionary<RFViewControllerAppearanceAttributeKey, id> *)attributes error:(NSError *_Nullable __autoreleasing *)error {
#define _expect_kind(KEY, CLASS)\
    if (!_attributeCheck(attributes, KEY, [CLASS class], error)) {\
        return NO;\
    }

    _expect_kind(RFViewControllerPrefersNavigationBarHiddenAttribute, NSNumber)
    _expect_kind(RFViewControllerPreferredNavigationBarTintColorAttribute, UIColor)
    _expect_kind(RFViewControllerPreferredNavigationBarItemColorAttribute, UIColor)
    _expect_kind(RFViewControllerPreferredNavigationBarTitleTextAttributes, NSDictionary)
    _expect_kind(RFViewControllerPrefersBottomBarShownAttribute, NSNumber)
    _expect_kind(RFViewControllerPreferredNavigationBarBackgroundAlphaAttributes, NSNumber)
    return YES;
}

static bool rf_isNull(id value) {
    return !value || value == NSNull.null;
}

- (void)updateNavigationAppearanceWithAppearanceAttributes:(NSDictionary<NSString *, id> *)attributes  animationDuration:(NSTimeInterval)animationDuration animated:(BOOL)animated {
    id value = nil;
    if ((value = attributes[RFViewControllerPrefersNavigationBarHiddenAttribute])) {
        BOOL shouldHide = [(NSNumber *)value boolValue];
        if (self.navigationBarHidden != shouldHide) {
            [self setNavigationBarHidden:shouldHide animated:animated];
        }
    }
    if ((value = attributes[RFViewControllerPreferredNavigationBarTintColorAttribute])) {
        self.navigationBar.barTintColor = rf_isNull(value)? nil : value;
    }
    if ((value = attributes[RFViewControllerPreferredNavigationBarItemColorAttribute])) {
        self.navigationBar.tintColor = rf_isNull(value)? nil : value;;
    }
    if ((value = attributes[RFViewControllerPreferredNavigationBarTitleTextAttributes])) {
        self.navigationBar.titleTextAttributes = rf_isNull(value)? nil : value;
    }

    if ((value = attributes[RFViewControllerPrefersBottomBarShownAttribute])) {
        BOOL shouldHide = ![(NSNumber *)value boolValue];
        if (self.bottomBarHidden != shouldHide) {
            // Show, no animation for better visual effect if bottom bar is not translucent.
            BOOL shouldAnimatd = (!shouldHide && !self.translucentBottomBar)? NO : animated;
            [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animated:shouldAnimatd beforeAnimations:nil animations:^{
                self.bottomBarHidden = shouldHide;
            } completion:nil];
        }
    }
    
    value = attributes[RFViewControllerPreferredNavigationBarBackgroundImageAttribute];
    if ([(NSObject *)value isKindOfClass:UIImage.class]) {
        [self.navigationBar setBackgroundImage:(UIImage *)value forBarMetrics:UIBarMetricsDefault];
    }
    else {
        [self.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    }
    
    if ((value = attributes[RFViewControllerPreferredNavigationBarBackgroundAlphaAttributes])) {
        UIImageView *iv = self.navigationBar.subviews.firstObject;
        iv.alpha = rf_isNull(value)? 1 : [(NSNumber *)value floatValue];
    }
}

- (void)updateNavigationAppearanceWithViewController:(UIViewController<RFNavigationBehaving> *)viewController animated:(BOOL)animated {
    @autoreleasepool {
        [self _updateNavigationAppearanceWithViewController:viewController animated:animated allEffectTakeImmediately:YES];
    }
}

- (void)_updateNavigationAppearanceWithViewController:(UIViewController<RFNavigationBehaving> *)viewController animated:(BOOL)animated allEffectTakeImmediately:(BOOL)immediately {

    // Ignore UIViewController’s prefersStatusBarHidden, preferredStatusBarStyle temporarily.
    if (![viewController respondsToSelector:@selector(RFNavigationAppearanceAttributes)]) return;

    NSDictionary *vcAttributes = [viewController RFNavigationAppearanceAttributes];
    if (!vcAttributes) return;
    NSError __autoreleasing *e = nil;
    if (![self validateAppearanceAttributes:vcAttributes error:&e]) {
        [NSException raise:NSInvalidArgumentException format:@"%@", e.localizedDescription];
        return;
    }

    NSMutableDictionary<RFViewControllerAppearanceAttributeKey, id> *attributes = self.defaultAppearanceAttributes.mutableCopy;
    
    id value = nil;
    if ((value = vcAttributes[RFViewControllerPrefersNavigationBarHiddenAttribute])) {
        BOOL shouldHide = [(NSNumber *)value boolValue];
        if (shouldHide) {
            // Prevent set navigation bar style to the default if navigation bar will be hidden.
            [attributes removeObjectForKey:RFViewControllerPreferredNavigationBarTintColorAttribute];
            [attributes removeObjectForKey:RFViewControllerPreferredNavigationBarItemColorAttribute];
            [attributes removeObjectForKey:RFViewControllerPreferredNavigationBarTitleTextAttributes];
            [attributes removeObjectForKey:RFViewControllerPreferredNavigationBarBackgroundAlphaAttributes];
            [attributes removeObjectForKey:RFViewControllerPreferredNavigationBarBackgroundImageAttribute];
        }
    }
    
    [attributes addEntriesFromDictionary:vcAttributes];

    if (viewController.navigationController != self) {
        [attributes removeObjectForKey:RFViewControllerPrefersNavigationBarHiddenAttribute];
        [attributes removeObjectForKey:RFViewControllerPreferredNavigationBarTintColorAttribute];
        [attributes removeObjectForKey:RFViewControllerPreferredNavigationBarItemColorAttribute];
        [attributes removeObjectForKey:RFViewControllerPreferredNavigationBarTitleTextAttributes];
        [attributes removeObjectForKey:RFViewControllerPreferredNavigationBarBackgroundAlphaAttributes];
        [attributes removeObjectForKey:RFViewControllerPreferredNavigationBarBackgroundImageAttribute];

    }
    [attributes removeObjectForKey:RFViewControllerPreferredNavigationBarBackgroundAlphaAttributes];
    [attributes removeObjectForKey:RFViewControllerPreferredNavigationBarBackgroundImageAttribute];

    BOOL navigationBarHiddenChanged = NO;
    if (attributes[RFViewControllerPrefersNavigationBarHiddenAttribute]
        && [(NSNumber *)attributes[RFViewControllerPrefersNavigationBarHiddenAttribute] boolValue] != self.navigationBarHidden) {
        navigationBarHiddenChanged = YES;
    }

    // If is interactive transitioning, use transitionDuration.
    NSTimeInterval transitionDuration = self.transitionCoordinator.isInteractive? self.transitionCoordinator.transitionDuration : 0.35;
    [self updateNavigationAppearanceWithAppearanceAttributes:attributes animationDuration:transitionDuration animated:animated];
}

- (void)updateCurrentNavigationAppearanceAnimated:(BOOL)animated {
    [self _updateNavigationAppearanceWithViewController:(id)self.topViewController animated:animated allEffectTakeImmediately:YES];
}

#pragma clang diagnostic pop // Appearance update

#pragma mark - Delegate

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate {
    NSAssert(false, @"You must not change RFNavigationController’s delegate.");
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (navigationController != self) return;

    [self _updateNavigationAppearanceWithViewController:(id)viewController animated:animated allEffectTakeImmediately:NO];
    [self.transitionCoordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if (context.isCancelled) {
            [self updateCurrentNavigationAppearanceAnimated:context.isAnimated];
        }
    }];

    UIGestureRecognizer *gr = self.currentPopInteractionGestureRecognizer;
    if (gr.state == UIGestureRecognizerStatePossible) {
        self._RFNavigationController_buidlinGestureRecognizerEnabled = gr.enabled;
        gr.enabled = NO;
    }

    if (self.willShowViewControllerBlock) {
        self.willShowViewControllerBlock(self, viewController, animated);
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (navigationController != self) return;

    if (self.currentPopInteractionGestureRecognizer && self._RFNavigationController_buidlinGestureRecognizerEnabled) {
        self.currentPopInteractionGestureRecognizer.enabled = YES;
    }

    self.currentPopInteractionController = (id)viewController.RFTransitioningInteractionController;
    self.interactivePopGestureRecognizer.enabled = (!self.currentPopInteractionController && self.viewControllers.count > 1);

    if (self.statusBarHideChangeDelayViewController) {
        if (self.statusBarHideChangeDelayViewController == self.topViewController) {
            [self updateCurrentNavigationAppearanceAnimated:animated];
        }
        self.statusBarHideChangeDelayViewController = nil;
    }

    if (self.didShowViewControllerBlock) {
        self.didShowViewControllerBlock(self, viewController, animated);
    }
}

#pragma mark - Transitioning

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {

    // Ask for a TransitionStyle
    BOOL usingToTransitionStyle = YES;
    if (self.preferSourceViewControllerTransitionStyle) {
        usingToTransitionStyle = !usingToTransitionStyle;
    }
    if (operation == UINavigationControllerOperationPop) {
        usingToTransitionStyle = !usingToTransitionStyle;
    }

    NSString *transitionClassName = usingToTransitionStyle? toVC.RFTransitioningStyle : fromVC.RFTransitioningStyle;
    if (!transitionClassName) {
        transitionClassName = navigationController.RFTransitioningStyle;
    }

    // Check class
    Class transitionClass = NSClassFromString(transitionClassName);
    if (!transitionClass
        || ![transitionClass isSubclassOfClass:RFAnimationTransitioning.class]) {
        return nil;
    }

    RFAnimationTransitioning *animationController = transitionClass.new;
    if (!animationController) {
        return nil;
    }

    // Addition setup
    if ([animationController respondsToSelector:@selector(setReverse:)]) {
        animationController.reverse = (UINavigationControllerOperationPop == operation);
    }

    if (operation == UINavigationControllerOperationPush) {
        @autoreleasepool {
            // Needs setup pop interaction controller to toVC.
            RFNavigationPopInteractionController *interactionController;
            if (animationController.interactionControllerType) {
                Class controllerClass = NSClassFromString(animationController.interactionControllerType);
                if (controllerClass && [controllerClass isSubclassOfClass:[RFNavigationPopInteractionController class]]) {
                    interactionController = [controllerClass new];
                }

                if (interactionController) {
                    interactionController.viewController = toVC;
                }
            }
        }
    }
    else {
        // Assign interactionController to animationController.
        // So we can get it in below delegate method.
        animationController.interactionController = fromVC.RFTransitioningInteractionController;
    }

    return animationController;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {

    if (![animationController respondsToSelector:@selector(interactionController)]) {
        return nil;
    }

    RFNavigationPopInteractionController *interactionController = [(RFAnimationTransitioning *)animationController interactionController];
    if (![interactionController conformsToProtocol:@protocol(UIViewControllerInteractiveTransitioning)]) {
        return nil;
    }

    if ([interactionController respondsToSelector:@selector(interactionInProgress)]) {
        if (!interactionController.interactionInProgress) {
            return nil;
        }
    }
    return interactionController;
}

- (void)setCurrentPopInteractionController:(RFNavigationPopInteractionController *)currentPopInteractionController {
    if (_currentPopInteractionController != currentPopInteractionController) {
        if ([_currentPopInteractionController isKindOfClass:RFNavigationPopInteractionController.class]) {
            [_currentPopInteractionController uninstallGestureRecognizer];
        }

        _currentPopInteractionController = currentPopInteractionController;

        if ([currentPopInteractionController isKindOfClass:RFNavigationPopInteractionController.class]) {
            [currentPopInteractionController installGestureRecognizer];
            self.currentPopInteractionGestureRecognizer = currentPopInteractionController.gestureRecognizer;
        }
        else {
            self.currentPopInteractionGestureRecognizer = nil;
        }
    }
}

@end

@implementation RFNavigationBottomBar
@end

@implementation UIViewController (RFNavigationBehaving)

- (void)updateNavigationAppearanceAnimated:(BOOL)animated {
    @autoreleasepool {
        RFNavigationController *nav = (id)self.navigationController;
        if ([nav respondsToSelector:@selector(updateNavigationAppearanceWithViewController:animated:)]) {
            [nav updateNavigationAppearanceWithViewController:(id)self animated:animated];
        }
    }
}

@end

RFDefineConstString(RFViewControllerPrefersNavigationBarHiddenAttribute);
RFDefineConstString(RFViewControllerPreferredNavigationBarTintColorAttribute);
RFDefineConstString(RFViewControllerPreferredNavigationBarItemColorAttribute);
RFDefineConstString(RFViewControllerPreferredNavigationBarTitleTextAttributes);
RFDefineConstString(RFViewControllerPrefersBottomBarShownAttribute);
RFDefineConstString(RFViewControllerPreferredNavigationBarBackgroundAlphaAttributes);
RFDefineConstString(RFViewControllerPreferredNavigationBarBackgroundImageAttribute);
