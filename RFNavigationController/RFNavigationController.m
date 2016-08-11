
#import "RFNavigationController.h"
#import "UIViewController+RFTransitioning.h"
#import "RFDelegateChain.h"
#import "UIView+RFAnimate.h"
#import "RFAnimationTransitioning.h"

static RFNavigationController *RFNavigationControllerGlobalInstance;

@interface RFNavigationBottomBar : UIView
@end

@interface RFNavigationController () <
    UIGestureRecognizerDelegate
>
@property (nonatomic, strong) RFNavigationBottomBar *bottomBarHolder;
@property (nonatomic, weak) UIView *transitionView;
@property (nonatomic, weak) UIViewController *statusBarHideChangeDelayViewController;

@property (readwrite, weak, nonatomic) RFNavigationPopInteractionController *currentPopInteractionController;
@property (readwrite, weak, nonatomic) UIGestureRecognizer *currentPopInteractionGestureRecognizer;
@property (assign, nonatomic) BOOL gestureRecognizerEnabled;
@end

@implementation RFNavigationController
RFUIInterfaceOrientationSupportNavigation
RFInitializingRootForUIViewController

- (void)onInit {
    [super setDelegate:self];

    @synchronized([RFNavigationController class]) {
        if (!RFNavigationControllerGlobalInstance) {
            RFNavigationControllerGlobalInstance = self;
        }
    }
}

- (void)afterInit {
    self.interactivePopGestureRecognizer.delegate = self;
}

+ (instancetype)globalNavigationController {
    return RFNavigationControllerGlobalInstance;
}

+ (void)setGlobalNavigationController:(__kindof RFNavigationController *)navigationController {
    @synchronized([RFNavigationController class]) {
        RFNavigationControllerGlobalInstance = navigationController;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.transitionView = self.view.subviews.firstObject;

    self.bottomBarHolder.frame = self.view.bounds;
    [self.view addSubview:self.bottomBarHolder];

    UIView *bottomBar = self.bottomBar;
    if (bottomBar) {
        self.bottomBarHolder.height = bottomBar.height;
        [self.bottomBarHolder addSubview:bottomBar resizeOption:RFViewResizeOptionFill];

        NSDictionary *dic = NSDictionaryOfVariableBindings(bottomBar);
        bottomBar.translatesAutoresizingMaskIntoConstraints = NO;
        [self.bottomBarHolder addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[bottomBar]-0-|" options:0 metrics:nil views:dic]];
        [self.bottomBarHolder addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[bottomBar]-0-|" options:0 metrics:nil views:dic]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateCurrentNavigationAppearanceAnimated:animated];
}

//! REF: http://stackoverflow.com/a/20923477
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.transitionCoordinator isAnimated]) {
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

#pragma mark - Bottom bar

- (void)setBottomBarHidden:(BOOL)bottomBarHidden {
    _bottomBarHidden = bottomBarHidden;

    UIView *bottomBarHolder = self.bottomBarHolder;
    CGFloat barHeight = bottomBarHolder.height;
    UIView *transitionView = self.transitionView;

    bottomBarHolder.y = self.view.height - (bottomBarHidden? 0 : barHeight);
    if (self.bottomBarFadeAnimation) {
        bottomBarHolder.alpha = bottomBarHidden? 0 : 1;
    }
    transitionView.height = self.view.height - transitionView.y - ((!bottomBarHidden && !self.translucentBottomBar)? barHeight: 0);
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
        bar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
        _bottomBarHolder = bar;
    }
    return _bottomBarHolder;
}

- (void)setBottomBar:(UIView *)bottomBar {
    if (_bottomBar != bottomBar) {
        if (_bottomBar.superview == self.bottomBarHolder) {
            [_bottomBar removeFromSuperview];
        }

        if (bottomBar && self.isViewLoaded) {
            self.bottomBarHolder.height = bottomBar.height;
            [self.bottomBarHolder addSubview:bottomBar resizeOption:RFViewResizeOptionFill];

            NSDictionary *dic = NSDictionaryOfVariableBindings(bottomBar);
            bottomBar.translatesAutoresizingMaskIntoConstraints = NO;
            [self.bottomBarHolder addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[bottomBar]-0-|" options:0 metrics:nil views:dic]];
            [self.bottomBarHolder addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[bottomBar]-0-|" options:0 metrics:nil views:dic]];
        }

        _bottomBar = bottomBar;
        self.bottomBarHidden = self.bottomBarHidden;
    }
}

#pragma mark - Appearance update

@synthesize defaultAppearanceAttributes = _defaultAppearanceAttributes;

- (NSDictionary<NSString *,id> *)defaultAppearanceAttributes {
    if (_defaultAppearanceAttributes) return _defaultAppearanceAttributes;

    UINavigationBar *nb = self.navigationBar;
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:10];
    dic[RFViewControllerPrefersNavigationBarHiddenAttribute] = @(self.navigationBarHidden);
    dic[RFViewControllerPreferredNavigationBarTintColorAttribute] = nb.barTintColor?: [NSNull null];
    dic[RFViewControllerPreferredNavigationBarItemColorAttribute] = nb.tintColor?: [NSNull null];
    dic[RFViewControllerPreferredNavigationBarTitleTextAttributes] = nb.titleTextAttributes?: [NSNull null];
    dic[RFViewControllerPrefersBottomBarShownAttribute] = @(!self.bottomBarHidden);
    dic[RFViewControllerPrefersStatusBarHiddenAttribute] = @([UIApplication sharedApplication].statusBarHidden);
    dic[RFViewControllerPreferredStatusBarUpdateAnimationAttribute] = @(UIStatusBarAnimationFade);
    dic[RFViewControllerPreferredStatusBarStyleAttribute] = @([UIApplication sharedApplication].statusBarStyle);

    _defaultAppearanceAttributes = dic.copy;
    return _defaultAppearanceAttributes;
}

- (void)setDefaultAppearanceAttributes:(NSDictionary<NSString *,id> *)defaultAppearanceAttributes {
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
        || (value == [NSNull null] && ![kind isSubclassOfClass:[NSNumber class]])) {
        return YES;
    }

    if (![value isKindOfClass:kind]) {
        if (*outError) {
            *outError = [NSError errorWithDomain:@"RFNavigationController" code:2 localizedDescription:[NSString stringWithFormat:@"Expect %@ attribute is kind of %@", key, kind]];
        }
        return NO;
    }
    return YES;
}

- (BOOL)validateAppearanceAttributes:(NSDictionary<NSString *,id> *)attributes error:(out NSError *_Nullable *)error {
#define _expect_kind(KEY, CLASS)\
    if (!_attributeCheck(attributes, KEY, [CLASS class], error)) {\
        return NO;\
    }

    _expect_kind(RFViewControllerPrefersNavigationBarHiddenAttribute, NSNumber)
    _expect_kind(RFViewControllerPreferredNavigationBarTintColorAttribute, UIColor)
    _expect_kind(RFViewControllerPreferredNavigationBarItemColorAttribute, UIColor)
    _expect_kind(RFViewControllerPreferredNavigationBarTitleTextAttributes, NSDictionary)
    _expect_kind(RFViewControllerPrefersBottomBarShownAttribute, NSNumber)
    _expect_kind(RFViewControllerPrefersStatusBarHiddenAttribute, NSNumber)
    _expect_kind(RFViewControllerPreferredStatusBarUpdateAnimationAttribute, NSNumber)
    _expect_kind(RFViewControllerPreferredStatusBarStyleAttribute, NSNumber)
    return YES;
}

static bool rf_isNull(id value) {
    return !value || value == [NSNull null];
}

- (void)updateNavigationAppearanceWithAppearanceAttributes:(NSDictionary<NSString *, id> *)attributes  animationDuration:(NSTimeInterval)animationDuration animated:(BOOL)animated {
    id value = nil;
    if ((value = attributes[RFViewControllerPrefersNavigationBarHiddenAttribute])) {
        BOOL shouldHide = [value boolValue];
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
        BOOL shouldHide = ![value boolValue];
        if (self.bottomBarHidden != shouldHide) {
            // Show, no animation for better visual effect if bottom bar is not translucent.
            BOOL shouldAnimatd = (!shouldHide && !self.translucentBottomBar)? NO : animated;
            [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animated:shouldAnimatd beforeAnimations:nil animations:^{
                self.bottomBarHidden = shouldHide;
            } completion:nil];
        }
    }

    if (!self.handelViewControllerBasedStatusBarAppearance) return;
    if ((value = attributes[RFViewControllerPrefersStatusBarHiddenAttribute])) {
        BOOL shouldStatusBarHidden = [value boolValue];
        if (shouldStatusBarHidden != [UIApplication sharedApplication].statusBarHidden) {
            UIStatusBarAnimation preferredStatusBarUpdateAnimation = UIStatusBarAnimationNone;
            if (animated
                && attributes[RFViewControllerPrefersStatusBarHiddenAttribute]) {
                preferredStatusBarUpdateAnimation = [attributes[RFViewControllerPrefersStatusBarHiddenAttribute] integerValue];
            }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [[UIApplication sharedApplication] setStatusBarHidden:shouldStatusBarHidden withAnimation:animated? preferredStatusBarUpdateAnimation : UIStatusBarAnimationNone];
#pragma clang diagnostic pop
        }
    }

    if ((value = attributes[RFViewControllerPreferredStatusBarStyleAttribute])) {
        UIStatusBarStyle preferredStatusBarStyle = [value integerValue];
        if (preferredStatusBarStyle != [UIApplication sharedApplication].statusBarStyle) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [[UIApplication sharedApplication] setStatusBarStyle:preferredStatusBarStyle animated:animated];
#pragma clang diagnostic pop
        }
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

    NSMutableDictionary *attributes = [self.defaultAppearanceAttributes mutableCopy];
    [attributes addEntriesFromDictionary:vcAttributes];

    if (viewController.navigationController != self) {
        [attributes removeObjectForKey:RFViewControllerPrefersNavigationBarHiddenAttribute];
        [attributes removeObjectForKey:RFViewControllerPreferredNavigationBarTintColorAttribute];
        [attributes removeObjectForKey:RFViewControllerPreferredNavigationBarItemColorAttribute];
        [attributes removeObjectForKey:RFViewControllerPreferredNavigationBarTitleTextAttributes];
    }
    if (!self.handelViewControllerBasedStatusBarAppearance) {
        [attributes removeObjectForKey:RFViewControllerPrefersStatusBarHiddenAttribute];
        [attributes removeObjectForKey:RFViewControllerPreferredStatusBarUpdateAnimationAttribute];
        [attributes removeObjectForKey:RFViewControllerPreferredStatusBarStyleAttribute];
    }

    BOOL navigationBarHiddenChanged = NO;
    if (attributes[RFViewControllerPrefersNavigationBarHiddenAttribute]
        && [attributes[RFViewControllerPrefersNavigationBarHiddenAttribute] boolValue] != self.navigationBarHidden) {
        navigationBarHiddenChanged = YES;
    }

    BOOL shouldStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    if (attributes[RFViewControllerPrefersStatusBarHiddenAttribute]) {
        shouldStatusBarHidden = [attributes[RFViewControllerPrefersStatusBarHiddenAttribute] boolValue];
    }

    if (animated
        && self.handelViewControllerBasedStatusBarAppearance
        && navigationBarHiddenChanged
        && !immediately
        && (!self.navigationBarHidden || (shouldStatusBarHidden && navigationBarHiddenChanged && self.navigationBarHidden))) {
        // If status bar hidden changed and navigationBar keep showing, it will result in a awful animation.
        // Change status bar animation later to avoid this.
        self.statusBarHideChangeDelayViewController = viewController;
        [attributes removeObjectForKey:RFViewControllerPrefersStatusBarHiddenAttribute];
    }

    // If is interactive transitioning, use transitionDuration.
    NSTimeInterval transitionDuration = self.transitionCoordinator.isInteractive? self.transitionCoordinator.transitionDuration : 0.35;
    [self updateNavigationAppearanceWithAppearanceAttributes:attributes animationDuration:transitionDuration animated:animated];
}

- (void)updateCurrentNavigationAppearanceAnimated:(BOOL)animated {
    [self _updateNavigationAppearanceWithViewController:(id)self.topViewController animated:animated allEffectTakeImmediately:YES];
}

#pragma mark - Back button

//! REF: https://github.com/onegray/UIViewController-BackButtonHandler
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {

	if (self.viewControllers.count < navigationBar.items.count) {
		return YES;
	}

	BOOL shouldPop = YES;
	UIViewController<RFNavigationBehaving>* vc = (id)[self topViewController];
	if([vc respondsToSelector:@selector(shouldPopOnBackButtonTappedForNavigationController:)]) {
		shouldPop = [vc shouldPopOnBackButtonTappedForNavigationController:self];
	}

	if (shouldPop) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self popViewControllerAnimated:YES];
		});
	}
    else {
		// Workaround for iOS7.1. Thanks to @boliva - http://stackoverflow.com/posts/comments/34452906
        [UIView animateWithDuration:.25 animations:^{
            for (UIView *subview in [navigationBar subviews]) {
                if (subview.alpha < 1.) {
                    subview.alpha = 1.;
                }
            }
        }];
	}

	return NO;
}

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
        self.gestureRecognizerEnabled = gr.enabled;
        gr.enabled = NO;
    }

    if (self.willShowViewControllerBlock) {
        self.willShowViewControllerBlock(self, viewController, animated);
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (navigationController != self) return;

    if (self.currentPopInteractionGestureRecognizer && self.gestureRecognizerEnabled) {
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
        || ![transitionClass isSubclassOfClass:[RFAnimationTransitioning class]]) {
        return nil;
    }

    RFAnimationTransitioning *animationController = [transitionClass new];
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
        if ([_currentPopInteractionController isKindOfClass:[RFNavigationPopInteractionController class]]) {
            [_currentPopInteractionController uninstallGestureRecognizer];
        }

        _currentPopInteractionController = currentPopInteractionController;

        if ([currentPopInteractionController isKindOfClass:[RFNavigationPopInteractionController class]]) {
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
RFDefineConstString(RFViewControllerPrefersStatusBarHiddenAttribute);
RFDefineConstString(RFViewControllerPreferredStatusBarUpdateAnimationAttribute);
RFDefineConstString(RFViewControllerPreferredStatusBarStyleAttribute);
