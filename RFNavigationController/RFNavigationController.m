
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
@property (strong, nonatomic) RFNavigationBottomBar *bottomBarHolder;
@property (weak, nonatomic) UIView *transitionView;

@property (readwrite, weak, nonatomic) RFNavigationPopInteractionController *currentPopInteractionController;
@property (readwrite, weak, nonatomic) UIGestureRecognizer *currentPopInteractionGestureRecognizer;
@property (assign, nonatomic) BOOL gestureRecognizerEnabled;
@end

@implementation RFNavigationController
RFUIInterfaceOrientationSupportNavigation
RFInitializingRootForUIViewController

- (void)onInit {
    [super setDelegate:self];

    _prefersStatusBarHidden = NO;
    _preferredStatusBarStyle = UIStatusBarStyleDefault;
    _preferredStatusBarUpdateAnimation = UIStatusBarAnimationFade;

    @synchronized([RFNavigationController class]) {
        if (!RFNavigationControllerGlobalInstance) {
            RFNavigationControllerGlobalInstance = self;
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.preferredNavigationBarHidden = self.navigationBarHidden;
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
    [self updateNavigationAppearanceWithViewController:self.topViewController animated:animated];
}

- (void)setPreferredNavigationBarHidden:(BOOL)preferredNavigationBarHidden {
    if (_preferredNavigationBarHidden != preferredNavigationBarHidden) {
        _preferredNavigationBarHidden = preferredNavigationBarHidden;
        [self updateNavigationAppearanceWithViewController:self.topViewController animated:NO];
    }
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

- (void)updateNavigationAppearanceWithViewController:(UIViewController<RFNavigationBehaving> *)viewController animated:(BOOL)animated {
    // Handel status bar appearance
    if (self.handelViewControllerBasedStatusBarAppearance) {
        BOOL shouldStatusBarHidden = self.prefersStatusBarHidden;
        if ([viewController respondsToSelector:@selector(prefersStatusBarHidden)]) {
            shouldStatusBarHidden = [viewController prefersStatusBarHidden];
        }

        if (shouldStatusBarHidden != [UIApplication sharedApplication].statusBarHidden) {
            UIStatusBarAnimation preferredStatusBarUpdateAnimation = self.preferredStatusBarUpdateAnimation;
            if ([viewController respondsToSelector:@selector(preferredStatusBarUpdateAnimation)]) {
                preferredStatusBarUpdateAnimation = [viewController preferredStatusBarUpdateAnimation];
            }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [[UIApplication sharedApplication] setStatusBarHidden:shouldStatusBarHidden withAnimation:animated? preferredStatusBarUpdateAnimation : UIStatusBarAnimationNone];
#pragma clang diagnostic pop
        }

        UIStatusBarStyle preferredStatusBarStyle = self.preferredStatusBarStyle;
        if ([viewController respondsToSelector:@selector(preferredStatusBarStyle)]) {
            UIStatusBarStyle vcStyle = [viewController preferredStatusBarStyle];
            if (vcStyle != UIStatusBarStyleDefault) {
                preferredStatusBarStyle = vcStyle;
            }
        }
        
        if (preferredStatusBarStyle != [UIApplication sharedApplication].statusBarStyle) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [[UIApplication sharedApplication] setStatusBarStyle:preferredStatusBarStyle animated:animated];
#pragma clang diagnostic pop
        }
    }

    if (viewController.navigationController == self) {
        BOOL shouldHide = self.preferredNavigationBarHidden;

        if ([viewController respondsToSelector:@selector(prefersNavigationBarHidden)]) {
            shouldHide = [(id<RFNavigationBehaving>)viewController prefersNavigationBarHidden];
        }

        if (self.navigationBarHidden != shouldHide) {
            [self setNavigationBarHidden:shouldHide animated:animated];
        }

        // Handel bottom bar appearance
        shouldHide = YES;
        if ([viewController respondsToSelector:@selector(prefersBottomBarShown)]) {
            shouldHide = ![(id)viewController prefersBottomBarShown];
        }

        // If is interactive transitioning, use transitionDuration.
        NSTimeInterval transitionDuration = self.transitionCoordinator.isInteractive? self.transitionCoordinator.transitionDuration : 0.35;
        if (self.bottomBarHidden != shouldHide) {
            // Show, no animation for better visual effect if bottom bar is not translucent.
            BOOL shouldAnimatd = (!shouldHide && !self.translucentBottomBar)? NO : animated;
            [UIView animateWithDuration:transitionDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animated:shouldAnimatd beforeAnimations:^{
            } animations:^{
                self.bottomBarHidden = shouldHide;
            } completion:nil];
        }

        [UIView animateWithDuration:transitionDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animated:animated beforeAnimations:^{
        } animations:^{

            UINavigationBar *bar = self.navigationBar;
            if ([viewController respondsToSelector:@selector(preferredNavigationBarTintColor)]) {
                UIColor *barColor = [viewController preferredNavigationBarTintColor];

                bar.barTintColor = barColor;
            }
            if ([viewController respondsToSelector:@selector(preferredNavigationBarItemColor)]) {
                UIColor *itemColor = [viewController preferredNavigationBarItemColor];
                bar.tintColor = itemColor;
            }
            if ([viewController respondsToSelector:@selector(preferredNavigationBarTitleTextAttributes)]) {
                NSDictionary *ta = [viewController preferredNavigationBarTitleTextAttributes];
                bar.titleTextAttributes = ta;
            }
        } completion:nil];
    }



    doutwork()
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

    [self updateNavigationAppearanceWithViewController:viewController animated:animated];
    [self.transitionCoordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if (context.isCancelled) {
            [self updateNavigationAppearanceWithViewController:self.topViewController animated:context.isAnimated];
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
