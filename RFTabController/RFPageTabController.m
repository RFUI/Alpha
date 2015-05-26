
#import "RFPageTabController.h"

@interface RFTabController (Private)
@property (assign, nonatomic) NSUInteger _selectedIndex;
@end

@interface RFPageTabController () <
    UIPageViewControllerDataSource,
    UIPageViewControllerDelegate
>
@property (strong, readwrite, nonatomic) UIPageViewController *pageViewController;
@property (assign, nonatomic) BOOL scrollEnabledStatusNeedsResetAfterViewLoadded;
@end

@implementation RFPageTabController
@synthesize scrollEnabled = _scrollEnabled;

- (void)onInit {
    [super onInit];

    UIPageViewController *pc = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    pc.dataSource = self;
    pc.delegate = self;
    [self addChildViewController:pc];
    self.pageViewController = pc;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIView *pv = self.pageViewController.view;
    pv.autoresizingMask = UIViewAutoresizingFlexibleSize;
    [self.wrapperView addSubview:pv resizeOption:RFViewResizeOptionFill];

    if (self.scrollEnabledStatusNeedsResetAfterViewLoadded) {
        self.scrollEnabled = _scrollEnabled;
    }
}

- (void)didDataSourceUpdateFromArray:(NSArray *)oldViewControllers toArray:(NSArray *)newViewControllers {
    UIViewController *oldSelectedViewController = self.selectedViewController;
    NSUInteger newIndex = [newViewControllers indexOfObject:oldSelectedViewController];
    if (newIndex == NSNotFound) {
        self.selectedIndex = 0;
    }
    else {
        self.selectedIndex = newIndex;
    }
}

- (void)setSelectedIndex:(NSUInteger)newSelectedIndex animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    if (self._selectedIndex == newSelectedIndex) {
        return;
    }
    
    UIViewController *svc = [self.viewControllers rf_objectAtIndex:newSelectedIndex];
    if (!svc) {
        if (completion) completion(NO);
        return;
    }

    if (![self askDelegateShouldSelectViewController:svc atIndex:newSelectedIndex]) {
        if (completion) completion(NO);
        return;
    }

    UIPageViewControllerNavigationDirection direction = (self._selectedIndex > newSelectedIndex)? UIPageViewControllerNavigationDirectionReverse : UIPageViewControllerNavigationDirectionForward;
    self._selectedIndex = newSelectedIndex;

    __weak UIView *tabContainer = self.tabButtonsContainerView;
    tabContainer.userInteractionEnabled = NO;
    [self.pageViewController setViewControllers:@[ svc ] direction:direction animated:animated completion:^(BOOL finished) {
        tabContainer.userInteractionEnabled = YES;
        if (completion) completion(finished);
    }];
}

#pragma mark - Scroll Enabled

- (BOOL)scrollEnabled {
    if (![self.pageViewController isViewLoaded]) return _scrollEnabled;
    return [self pageViewControllerScrollEnabled];
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _scrollEnabled = scrollEnabled;
    if (![self.pageViewController isViewLoaded]) {
        self.scrollEnabledStatusNeedsResetAfterViewLoadded = YES;
        return;
    }
    [self setPageViewControllerScrollEnabled:scrollEnabled];
}

- (BOOL)pageViewControllerScrollEnabled {
    __block BOOL se = YES;
    [self.pageViewController.view.subviews enumerateObjectsUsingBlock:^(UIScrollView *view, NSUInteger idx, BOOL *stop) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            se = view.scrollEnabled;
            *stop = YES;
        }
    }];
    return se;
}

- (void)setPageViewControllerScrollEnabled:(BOOL)scrollEnabled {
    [self.pageViewController.view.subviews enumerateObjectsUsingBlock:^(UIScrollView *view, NSUInteger idx, BOOL *stop) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            view.scrollEnabled = scrollEnabled;
            *stop = YES;
        }
    }];
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger idx = [self.viewControllers indexOfObject:viewController];
    idx--;

    UIViewController *vc = [self.viewControllers rf_objectAtIndex:idx];
    if (!vc) return nil;

    if (![self askDelegateShouldSelectViewController:vc atIndex:idx]) {
        return nil;
    }
    return vc;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger idx = [self.viewControllers indexOfObject:viewController];
    idx++;

    UIViewController *vc = [self.viewControllers rf_objectAtIndex:idx];
    if (!vc) return nil;

    if (![self askDelegateShouldSelectViewController:vc atIndex:idx]) {
        return nil;
    }
    return vc;
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    _doutwork()
    self.tabButtonsContainerView.userInteractionEnabled = NO;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    _doutwork()
    self.tabButtonsContainerView.userInteractionEnabled = YES;
    UIViewController *ct = pageViewController.viewControllers.firstObject;
    NSUInteger idx = [self.viewControllers indexOfObject:ct];
    self._selectedIndex = idx;
    [self noticeDelegateDidSelectViewController:ct atIndex:idx];
}

@end
