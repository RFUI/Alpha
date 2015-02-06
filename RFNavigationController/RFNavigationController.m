
#import "RFNavigationController.h"
#import "UIViewController+RFTransitioning.h"
#import "RFDelegateChain.h"
#import "UIView+RFAnimate.h"

static RFNavigationController *RFNavigationControllerGlobalInstance;

@interface RFNavigationBottomBar : UIView
@end

@interface RFNavigationController () <
    UINavigationControllerDelegate,
    UIGestureRecognizerDelegate
>
@property (strong, nonatomic) RFNavigationBottomBar *bottomBarHolder;
@property (weak, nonatomic) UIView *transitionView;
@end

@implementation RFNavigationController
RFUIInterfaceOrientationSupportNavigation
RFInitializingRootForUIViewController

- (void)onInit {
    _prefersStatusBarHidden = NO;
    _preferredStatusBarStyle = UIStatusBarStyleDefault;
    _preferredStatusBarUpdateAnimation = UIStatusBarAnimationFade;

    self.forwardDelegate = [RFNavigationControllerTransitionDelegate new];
    self.delegate = self.forwardDelegate;

    if (!RFNavigationControllerGlobalInstance) {
        RFNavigationControllerGlobalInstance = self;
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
        if (self.forwardDelegate.currentPopInteractionGestureRecognizer) {
            return NO;
        }
    }

    if ([gestureRecognizer.view respondsToSelector:@selector(gestureRecognizerShouldBegin:)]) {
        BOOL result = [gestureRecognizer.view gestureRecognizerShouldBegin:gestureRecognizer];
        return result;
    }
    return YES;
}

#pragma mark - Tab bar

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

- (void)updateNavigationAppearanceWithViewController:(id)viewController animated:(BOOL)animated {
    BOOL shouldHide = self.preferredNavigationBarHidden;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if ([viewController respondsToSelector:@selector(prefersNavigationBarHiddenForNavigationController:)]) {
        shouldHide = [(id<RFNavigationBehaving>)viewController prefersNavigationBarHiddenForNavigationController:self];
    }
#pragma clang diagnostic pop
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

    if (self.bottomBarHidden != shouldHide) {
        // If is interactive transitioning, use transitionDuration.
        NSTimeInterval transitionDuration = self.transitionCoordinator.isInteractive? self.transitionCoordinator.transitionDuration : 0.35;

        // Show, no animation for better visual effect if bottom bar is not translucent.
        BOOL shouldAnimatd = (!shouldHide && !self.translucentBottomBar)? NO : animated;
        [UIView animateWithDuration:transitionDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animated:shouldAnimatd beforeAnimations:^{
        } animations:^{
            self.bottomBarHidden = shouldHide;
        } completion:nil];
    }

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
            [[UIApplication sharedApplication] setStatusBarHidden:shouldStatusBarHidden withAnimation:animated? preferredStatusBarUpdateAnimation : UIStatusBarAnimationNone];
        }

        UIStatusBarStyle preferredStatusBarStyle = self.preferredStatusBarStyle;
        if ([viewController respondsToSelector:@selector(preferredStatusBarStyle)]) {
            UIStatusBarStyle vcStyle = [viewController preferredStatusBarStyle];
            if (vcStyle != UIStatusBarStyleDefault) {
                preferredStatusBarStyle = vcStyle;
            }
        }
        if (preferredStatusBarStyle != [UIApplication sharedApplication].statusBarStyle) {
            [[UIApplication sharedApplication] setStatusBarStyle:preferredStatusBarStyle animated:animated];
        }
    }
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
