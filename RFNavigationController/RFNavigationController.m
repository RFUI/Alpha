
#import "RFNavigationController.h"
#import "UIViewController+RFTransitioning.h"
#import "RFDelegateChain.h"

static RFNavigationController *RFNavigationControllerGlobalInstance;

@interface RFNavigationController () <
    UINavigationControllerDelegate
>
@property (weak, nonatomic) id<UINavigationControllerDelegate> trueDelegate;
@end

@implementation RFNavigationController
RFUIInterfaceOrientationSupportNavigation

+ (instancetype)globalNavigationController {
    return RFNavigationControllerGlobalInstance;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    [super setDelegate:self];
    self.preferredNavigationBarHidden = self.navigationBarHidden;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!RFNavigationControllerGlobalInstance) {
        RFNavigationControllerGlobalInstance = self;
    }
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

#pragma mark - Delegate Forward

RFDelegateChainForwordMethods(self, self.trueDelegate)

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate {
    self.trueDelegate = delegate;
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {

    BOOL shouldHide = self.preferredNavigationBarHidden;
    if ([viewController respondsToSelector:@selector(prefersNavigationBarHiddenForNavigationController:)]) {
        shouldHide = [(id<RFNavigationBehaving>)viewController prefersNavigationBarHiddenForNavigationController:self];
    }

    if (self.navigationBarHidden != shouldHide) {
        [self setNavigationBarHidden:shouldHide animated:animated];
    }

    if ([self.trueDelegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
        [self.trueDelegate navigationController:navigationController willShowViewController:viewController animated:animated];
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
