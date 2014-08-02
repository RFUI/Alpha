
#import "RFNavigationController.h"
#import "UIViewController+RFTransitioning.h"

static RFNavigationController *RFNavigationControllerGlobalInstance;

@interface RFNavigationController ()
@end

@implementation RFNavigationController
RFUIInterfaceOrientationSupportNavigation

+ (instancetype)globalNavigationController {
    return RFNavigationControllerGlobalInstance;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!RFNavigationControllerGlobalInstance) {
        RFNavigationControllerGlobalInstance = self;
    }
}

#pragma mark - UINavigationControllerDelegate

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
