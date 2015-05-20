
#import "RFTabController.h"

@interface RFTabController ()
@end

@implementation RFTabController
RFInitializingRootForUIViewController

- (void)onInit {
    _selectedIndex = NSNotFound;
}

- (void)afterInit {

}

- (UIView *)wrapperView {
    if (_wrapperView) return _wrapperView;

    UIView *w = [[UIView alloc] initWithFrame:self.view.bounds];
    w.autoresizingMask = UIViewAutoresizingFlexibleSize;
    [self.view addSubview:w];
    _wrapperView = w;
    return _wrapperView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Only rotate if all child view controllers agree on the new orientation.
    for (UIViewController *viewController in self.viewControllers) {
        if (![viewController shouldAutorotateToInterfaceOrientation:interfaceOrientation]) return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    if (self.forceUnloadInvisibleWhenMemoryWarningReceived) {
        UIViewController *selectedVC = self.selectedViewController;
        for (UIViewController *subVC in self.viewControllers) {
            if (subVC != selectedVC) {
                subVC.view = nil;
            }
        }
    }

    if ([self isViewLoaded] && !self.view.window) {
        self.view = nil;
    }
}

- (void)setViewControllers:(NSArray *)newViewControllers {

    UIViewController *oldSelectedViewController = self.selectedViewController;

    // Remove the old child view controllers.
    for (UIViewController *viewController in _viewControllers) {
        [viewController willMoveToParentViewController:nil];
        [viewController removeFromParentViewController];
    }

    _viewControllers = [newViewControllers copy];

    // This follows the same rules as UITabBarController for trying to
    // re-select the previously selected view controller.
    NSUInteger newIndex = [_viewControllers indexOfObject:oldSelectedViewController];
    if (newIndex != NSNotFound) {
        self.selectedIndex = newIndex;
    }
    else if (newIndex < [_viewControllers count]) {
        self.selectedIndex = newIndex;
    }
    else {
        self.selectedIndex = 0;
    }

    // Add the new child view controllers.
    for (UIViewController *viewController in _viewControllers) {
        [self addChildViewController:viewController];
        [viewController didMoveToParentViewController:self];
    }
}

- (void)setSelectedIndex:(NSUInteger)newSelectedIndex {
    [self setSelectedIndex:newSelectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSUInteger)newSelectedIndex animated:(BOOL)animated {
    if (newSelectedIndex >= self.viewControllers.count) {
        RFAssert(false, @"View controller index out of bounds");
        return;
    }

    if ([self.delegate respondsToSelector:@selector(RFTabController:shouldSelectViewController:atIndex:)]) {
        UIViewController *toViewController = (self.viewControllers)[newSelectedIndex];
        if (![self.delegate RFTabController:self shouldSelectViewController:toViewController atIndex:newSelectedIndex])
            return;
    }

    if (!self.isViewLoaded) {
        _selectedIndex = newSelectedIndex;
        return;
    }

    if (_selectedIndex == newSelectedIndex) {
        return;
    }

    UIViewController *fromViewController;
    UIViewController *toViewController;
    UIView *contentContainerView = self.wrapperView;

    if (_selectedIndex != NSNotFound) {
        fromViewController = self.selectedViewController;
    }

    NSUInteger oldSelectedIndex = _selectedIndex;
    _selectedIndex = newSelectedIndex;

    if (_selectedIndex != NSNotFound) {
        toViewController = self.selectedViewController;
    }

    if (!toViewController) {
        dout_debug(@"No toViewController")
        // Don't animate
        [fromViewController.view removeFromSuperview];
    }
    else if (!fromViewController) {
        dout_debug(@"No fromViewController")
        // Don't animate
        toViewController.view.frame = contentContainerView.bounds;
        [contentContainerView addSubview:toViewController.view];

        if ([self.delegate respondsToSelector:@selector(RFTabController:didSelectViewController:atIndex:)])
            [self.delegate RFTabController:self didSelectViewController:toViewController atIndex:newSelectedIndex];
    }
    else if (animated) {
        dout_debug(@"Animated transition")
        CGRect rect = contentContainerView.bounds;
        if (oldSelectedIndex < newSelectedIndex)
            rect.origin.x = rect.size.width;
        else
            rect.origin.x = -rect.size.width;

        toViewController.view.frame = rect;
        self.tabButtonsContainerView.userInteractionEnabled = NO;

        [self transitionFromViewController:fromViewController toViewController:toViewController duration:0.3f options:(UIViewAnimationOptions)(UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionCurveEaseOut) animations:^{
            CGRect rect = fromViewController.view.frame;
            if (oldSelectedIndex < newSelectedIndex)
                rect.origin.x = -rect.size.width;
            else
                rect.origin.x = rect.size.width;

            fromViewController.view.frame = rect;
            toViewController.view.frame = contentContainerView.bounds;
        } completion:^(BOOL finished) {
            self.tabButtonsContainerView.userInteractionEnabled = YES;

            if ([self.delegate respondsToSelector:@selector(RFTabController:didSelectViewController:atIndex:)])
                [self.delegate RFTabController:self didSelectViewController:toViewController atIndex:newSelectedIndex];
        }];
    }
    else {
        dout_debug(@"No animation")
        // not animated
        [fromViewController.view removeFromSuperview];

        toViewController.view.frame = contentContainerView.bounds;
        [contentContainerView addSubview:toViewController.view];

        if ([self.delegate respondsToSelector:@selector(RFTabController:didSelectViewController:atIndex:)])
            [self.delegate RFTabController:self didSelectViewController:toViewController atIndex:newSelectedIndex];
    }
}

- (UIViewController *)selectedViewController {
    return [self.viewControllers rf_objectAtIndex:self.selectedIndex];
}

- (void)setSelectedViewController:(UIViewController *)newSelectedViewController {
    [self setSelectedViewController:newSelectedViewController animated:NO];
}

- (void)setSelectedViewController:(UIViewController *)newSelectedViewController animated:(BOOL)animated {
    NSUInteger index = [self.viewControllers indexOfObject:newSelectedViewController];
    if (index != NSNotFound) {
        [self setSelectedIndex:index animated:animated];
    }
}

@end
