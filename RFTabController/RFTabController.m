
#import "RFTabController.h"
#import "RFDataSourceArray.h"


@interface RFTabController () <
    RFDataSourceArrayDataSource
>
@property (assign, nonatomic) NSUInteger _selectedIndex;
@property (strong, nonatomic) RFDataSourceArray *viewControllerStore;
@end


@implementation RFTabController {
    BOOL _transitingViewController;
}
@dynamic selectedIndex;
RFInitializingRootForUIViewController

- (void)onInit {
    __selectedIndex = NSNotFound;
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
    [self _setupAfterViewLoaded];
}

- (void)_setupAfterViewLoaded {
    if (self.selectedViewController
        && ![self.selectedViewController isViewLoaded]) {
        NSUInteger tmp = __selectedIndex;
        __selectedIndex = NSNotFound;
        self.selectedIndex = tmp;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Only rotate if all child view controllers agree on the new orientation.
    for (UIViewController *viewController in self.viewControllerStore) {
        if (![viewController shouldAutorotateToInterfaceOrientation:interfaceOrientation]) return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    if (self.dataSource) {
        if ([self.dataSource respondsToSelector:@selector(RFTabController:shouldUnlodadViewControllerAtIndex:)]) {
            NSMutableIndexSet *set = [NSMutableIndexSet new];
            for (NSUInteger i = 0; i < self.viewControllerStore.count; i++) {
                if ([self.dataSource RFTabController:self shouldUnlodadViewControllerAtIndex:i]) {
                    [set addIndex:i];
                }
            }
            [self.viewControllerStore removeObjectsAtIndexes:set];
        }
        else {
            [self.viewControllerStore reloadData];
        }
    }

    if ([self isViewLoaded] && !self.view.window) {
        self.view = nil;
    }
}

#pragma mark - Data Source

- (RFDataSourceArray *)viewControllerStore {
    if (_viewControllerStore) return _viewControllerStore;
    _viewControllerStore = [RFDataSourceArray new];
    _viewControllerStore.dataSource = self;
    return _viewControllerStore;
}

- (void)setDataSource:(id<RFTabControllerDataSource>)dataSource {
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        NSUInteger idx = __selectedIndex;
        __selectedIndex = NSNotFound;
        self.selectedIndex = idx;
    }
    [self.viewControllerStore reloadData];
}

- (NSUInteger)numberOfObjectInDataSourceArray:(RFDataSourceArray *)array {
    if (self.dataSource) {
        return [self.dataSource RFNumberOfViewControllerInTabController:self];
    }
    return self.viewControllers.count;
}

- (id)dataSourceArray:(RFDataSourceArray *)array objectAtIndex:(NSUInteger)index {
    if (self.dataSource) {
        return [self.dataSource RFTabController:self viewControllerAtIndex:index];
    }
    return self.viewControllers[index];
}

- (void)setViewControllers:(NSArray *)newViewControllers {
    id old = _viewControllers;
    _viewControllers = [newViewControllers copy];
    [self.viewControllerStore reloadData];
    [self didDataSourceUpdateFromArray:old toArray:newViewControllers];
}

- (void)didDataSourceUpdateFromArray:(NSArray *)oldViewControllers toArray:(NSArray *)newViewControllers {
    UIViewController *oldSelectedViewController = self.selectedViewController;

    // Remove the old child view controllers.
    for (UIViewController *vc in oldViewControllers) {
        [vc willMoveToParentViewController:nil];
        [vc removeFromParentViewController];
    }

    // This follows the same rules as UITabBarController for trying to
    // re-select the previously selected view controller.
    NSUInteger newIndex = [newViewControllers indexOfObject:oldSelectedViewController];
    if (newIndex == NSNotFound) {
        self.selectedIndex = 0;
    }
    else {
        self.selectedIndex = newIndex;
    }

    // Add the new child view controllers.
    for (UIViewController *vc in newViewControllers) {
        [self addChildViewController:vc];
        [vc didMoveToParentViewController:self];
    }
}

#pragma mark -

- (NSUInteger)indexForViewController:(UIViewController *)viewController {
    return [self.viewControllerStore indexOfObject:viewController];
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    return self.viewControllerStore[index];
}

#pragma mark -

- (NSUInteger)selectedIndex {
    return __selectedIndex;
}

- (void)setSelectedIndex:(NSUInteger)newSelectedIndex {
    [self setSelectedIndex:newSelectedIndex animated:NO completion:nil];
}

- (void)setSelectedIndex:(NSUInteger)newSelectedIndex animated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    if (newSelectedIndex >= self.viewControllerStore.count) {
        RFAssert(false, @"View controller index out of bounds");
        if (completion) completion(NO);
        return;
    }

    // Should not change selected view controller
    if (![self askDelegateShouldSelectViewController:self.viewControllerStore[newSelectedIndex] atIndex:newSelectedIndex]
        || __selectedIndex == newSelectedIndex
        || _transitingViewController) {
        if (completion) completion(NO);
        return;
    }

    // View not loadded, just change index vaule
    if (!self.isViewLoaded) {
        __selectedIndex = newSelectedIndex;
        if (completion) completion(NO);
        return;
    }

    // Prepare view controller
    UIViewController *fromViewController;
    UIViewController *toViewController;
    UIView *contentContainerView = self.wrapperView;

    if (__selectedIndex != NSNotFound) {
        fromViewController = self.selectedViewController;
    }

    NSUInteger oldSelectedIndex = __selectedIndex;
    __selectedIndex = newSelectedIndex;

    if (__selectedIndex != NSNotFound) {
        toViewController = self.selectedViewController;
    }

    if (!animated
        || !fromViewController
        || !toViewController) {
        dout_debug(@"No animation")
        if (toViewController) {
            [self noticeDelegateWillSelectViewController:toViewController atIndex:newSelectedIndex];
        }
        [fromViewController.view removeFromSuperview];

        if (toViewController) {
            toViewController.view.frame = contentContainerView.bounds;
            [contentContainerView addSubview:toViewController.view];
            [self noticeDelegateDidSelectViewController:toViewController atIndex:newSelectedIndex];
        }
        if (completion) completion(NO);
        return;
    }

    dout_debug(@"Animated transition")
    _transitingViewController = YES;

    UIView *fromView = fromViewController.view;
    UIView *toView = toViewController.view;
    CGRect rect = contentContainerView.bounds;
    rect.origin.x = (oldSelectedIndex < newSelectedIndex)? rect.size.width : -rect.size.width;
    toView.frame = rect;
    self.tabButtonsContainerView.userInteractionEnabled = NO;
    [self noticeDelegateWillSelectViewController:toViewController atIndex:newSelectedIndex];

    [self transitionFromViewController:fromViewController toViewController:toViewController duration:0.3f options:(UIViewAnimationOptions)(UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionCurveEaseOut) animations:^{
        CGRect rect = fromView.frame;
        rect.origin.x = (oldSelectedIndex < newSelectedIndex)? -rect.size.width : rect.size.width;
        fromView.frame = rect;
        toView.frame = contentContainerView.bounds;
    } completion:^(BOOL finished) {
        self->_transitingViewController = NO;
        self.tabButtonsContainerView.userInteractionEnabled = YES;
        [self noticeDelegateDidSelectViewController:toViewController atIndex:newSelectedIndex];
        if (completion) completion(finished);
    }];
}

- (UIViewController *)selectedViewController {
    return [self.viewControllerStore rf_objectAtIndex:self.selectedIndex];
}

- (void)setSelectedViewController:(UIViewController *)newSelectedViewController {
    [self setSelectedViewController:newSelectedViewController animated:NO completion:nil];
}

- (void)setSelectedViewController:(UIViewController *)newSelectedViewController animated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    NSUInteger index = [self.viewControllerStore indexOfObject:newSelectedViewController];
    if (index != NSNotFound) {
        [self setSelectedIndex:index animated:animated completion:completion];
    }
}

#pragma mark -

- (void)noticeDelegateWillSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index {
    if (![self.delegate respondsToSelector:@selector(RFTabController:willSelectViewController:atIndex:)]) return;
    [self.delegate RFTabController:self willSelectViewController:viewController atIndex:index];
}

- (void)noticeDelegateDidSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index {
    if (![self.delegate respondsToSelector:@selector(RFTabController:didSelectViewController:atIndex:)]) return;
    [self.delegate RFTabController:self didSelectViewController:viewController atIndex:index];
}

- (BOOL)askDelegateShouldSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index {
    if (![self.delegate respondsToSelector:@selector(RFTabController:shouldSelectViewController:atIndex:)]) return YES;
    return [self.delegate RFTabController:self shouldSelectViewController:viewController atIndex:index];
}

@end
