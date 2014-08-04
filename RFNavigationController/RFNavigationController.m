
#import "RFNavigationController.h"
#import "UIViewController+RFTransitioning.h"
#import "RFDelegateChain.h"
#import "UIView+RFAnimate.h"

static RFNavigationController *RFNavigationControllerGlobalInstance;

@interface RFNavigationBottomBar : UIView
@end

@interface RFNavigationController () <
    UINavigationControllerDelegate
>
@property (weak, nonatomic) id<UINavigationControllerDelegate> trueDelegate;
@property (strong, nonatomic) RFNavigationBottomBar *bottomBarHolder;
@property (weak, nonatomic) UIView *transitionView;
@end

@implementation RFNavigationController
RFUIInterfaceOrientationSupportNavigation
RFInitializingRootForUIViewController

- (void)onInit {
    [super setDelegate:self];
    [self.view addSubview:self.bottomBarHolder];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.preferredNavigationBarHidden = self.navigationBarHidden;
}


- (void)afterInit {
    // Nothing
}

+ (instancetype)globalNavigationController {
    return RFNavigationControllerGlobalInstance;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!RFNavigationControllerGlobalInstance) {
        RFNavigationControllerGlobalInstance = self;
    }

    self.transitionView = self.view.subviews.firstObject;
}

- (void)setPreferredNavigationBarHidden:(BOOL)preferredNavigationBarHidden {
    _preferredNavigationBarHidden = preferredNavigationBarHidden;
    BOOL shouldHide = preferredNavigationBarHidden;

    id<RFNavigationBehaving> vc = (id<RFNavigationBehaving>)self.topViewController;
    if ([vc respondsToSelector:@selector(prefersNavigationBarHiddenForNavigationController:)]) {
        shouldHide = [vc prefersNavigationBarHiddenForNavigationController:self];
    }

    if (self.navigationBarHidden != shouldHide) {
        [self setNavigationBarHidden:shouldHide animated:NO];
    }
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
        RFNavigationBottomBar *bar = [[RFNavigationBottomBar alloc] initWithFrame:self.view.bounds];
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
        self.bottomBarHolder.height = bottomBar.height;
        [self.bottomBarHolder addSubview:bottomBar resizeOption:RFViewResizeOptionFill];
        _bottomBar = bottomBar;
    }
}

#pragma mark - Delegate Forward

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate {
    self.trueDelegate = delegate;
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {

    BOOL shouldHide = self.preferredNavigationBarHidden;
    if ([viewController respondsToSelector:@selector(prefersNavigationBarHiddenForNavigationController:)]) {
        shouldHide = [(id<RFNavigationBehaving>)viewController prefersNavigationBarHiddenForNavigationController:self];
    }

    if (self.navigationBarHidden != shouldHide) {
        self.navigationBarHidden = shouldHide;
    }

    shouldHide = YES;
    if ([viewController respondsToSelector:@selector(prefersBottomBarShown)]) {
        shouldHide = ![(id)viewController prefersBottomBarShown];
    }

    if (self.bottomBarHidden != shouldHide) {
        // Show, no animation for better visual effect.
        [UIView animateWithDuration:shouldHide? 0.1 : 0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animated:animated beforeAnimations:^{
        } animations:^{
            self.bottomBarHidden = shouldHide;
        } completion:nil];
    }

    if ([self.trueDelegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
        [self.trueDelegate navigationController:navigationController didShowViewController:viewController animated:animated];
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
