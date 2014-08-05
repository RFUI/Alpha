
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
    self.forwardDelegate = [RFNavigationControllerTransitionDelegate new];
    self.delegate = self.forwardDelegate;
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
    if (!RFNavigationControllerGlobalInstance) {
        RFNavigationControllerGlobalInstance = self;
    }

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
    [self updateNavigationAppearanceWithViewController:self.topViewController animated:NO];
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
    bottomBarHolder.alpha = bottomBarHidden? 0 : 1;
    transitionView.height = self.view.height - transitionView.y - (bottomBarHidden? 0 : barHeight);
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
        bar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight;
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
    }
}

- (void)updateNavigationAppearanceWithViewController:(id)viewController animated:(BOOL)animated {
    BOOL shouldHide = self.preferredNavigationBarHidden;
    if ([viewController respondsToSelector:@selector(prefersNavigationBarHiddenForNavigationController:)]) {
        shouldHide = [(id<RFNavigationBehaving>)viewController prefersNavigationBarHiddenForNavigationController:self];
    }

    if (self.navigationBarHidden != shouldHide) {
        [self setNavigationBarHidden:shouldHide animated:YES];
    }

    shouldHide = YES;
    if ([viewController respondsToSelector:@selector(prefersBottomBarShown)]) {
        shouldHide = ![(id)viewController prefersBottomBarShown];
    }

    if (self.bottomBarHidden != shouldHide) {
        // If is interactive transitioning, use transitionDuration.
        // Show, no animation for better visual effect.
        NSTimeInterval transitionDuration = (self.transitionCoordinator.isInteractive || shouldHide)? self.transitionCoordinator.transitionDuration : 0;
        [UIView animateWithDuration:transitionDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animated:animated beforeAnimations:^{
        } animations:^{
            self.bottomBarHidden = shouldHide;
        } completion:nil];
    }
}

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
    RFNavigationController *nav = (id)self.navigationController;
    [nav updateNavigationAppearanceWithViewController:(id)self animated:animated];
}

@end
