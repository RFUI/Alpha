
#import "RFPageTabController.h"
#import "RFDataSourceArray.h"

@interface RFTabController (Private)
@property (assign, nonatomic) NSUInteger _selectedIndex;
@property (strong, nonatomic) RFDataSourceArray *viewControllerStore;

- (void)noticeDelegateWillSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index;
- (void)noticeDelegateDidSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index;
- (BOOL)askDelegateShouldSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index;

- (void)_setupAfterViewLoaded;

@end

@interface RFPageTabController () <
    UIPageViewControllerDataSource,
    UIPageViewControllerDelegate
>
@property (strong, readwrite, nonatomic) UIPageViewController *pageViewController;
@property (assign, nonatomic) BOOL pageScrollViewScrollEnabledNeedsResetAfterViewLoadded;
@property (weak, nonatomic) UIScrollView *pageScrollView;
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
    UIView *pv = self.pageViewController.view;
    pv.autoresizingMask = UIViewAutoresizingFlexibleSize;
    [self.wrapperView addSubview:pv resizeOption:RFViewResizeOptionFill];

    [super viewDidLoad];

    if (self.pageScrollViewScrollEnabledNeedsResetAfterViewLoadded) {
        self.scrollEnabled = _scrollEnabled;
    }
}

- (void)_setupAfterViewLoaded {
    UIViewController *selectedViewController = self.selectedViewController;
    if (!selectedViewController) {
        return;
    }

    if (![self.pageViewController.viewControllers containsObject:selectedViewController]) {
        BOOL noticeDelegate = self.noticeDelegateWhenSelectionChangedProgrammatically;
        NSUInteger index = self.selectedIndex;
        if (noticeDelegate) {
            [self noticeDelegateWillSelectViewController:selectedViewController atIndex:index];
        }
        @weakify(self);
        [self.pageViewController setViewControllers:@[ selectedViewController ] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:^(BOOL finished) {
            @strongify(self);
            if (noticeDelegate) {
                [self noticeDelegateDidSelectViewController:selectedViewController atIndex:index];
            }
        }];
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
        if (completion) completion(NO);
        return;
    }

    _dout_int(self.viewControllerStore.count);
    UIViewController *svc = [self.viewControllerStore rf_objectAtIndex:newSelectedIndex];
    if (!svc) {
        if (completion) completion(NO);
        return;
    }

    BOOL noticeDelegate = self.noticeDelegateWhenSelectionChangedProgrammatically;
    if (noticeDelegate) {
        if (![self askDelegateShouldSelectViewController:svc atIndex:newSelectedIndex]) {
            if (completion) completion(NO);
            return;
        }
    }

    if (!self.isViewLoaded) {
        self._selectedIndex = newSelectedIndex;
        if (completion) completion(NO);
        return;
    }

    UIPageViewControllerNavigationDirection direction = (self._selectedIndex > newSelectedIndex)? UIPageViewControllerNavigationDirectionReverse : UIPageViewControllerNavigationDirectionForward;
    self._selectedIndex = newSelectedIndex;

    __weak UIView *tabContainer = self.tabButtonsContainerView;
    tabContainer.userInteractionEnabled = NO;
    if (noticeDelegate) {
        [self noticeDelegateWillSelectViewController:svc atIndex:newSelectedIndex];
    }
    @weakify(self);
    [self.pageViewController setViewControllers:@[ svc ] direction:direction animated:animated completion:^(BOOL finished) {
        @strongify(self);
        tabContainer.userInteractionEnabled = YES;
        if (noticeDelegate) {
            [self noticeDelegateDidSelectViewController:svc atIndex:newSelectedIndex];
        }
        if (completion) completion(finished);
    }];
}

#pragma mark - Scroll View Property

- (UIScrollView *)pageScrollView {
    if (_pageScrollView) return _pageScrollView;

    for (UIScrollView *v in self.pageViewController.view.subviews) {
        if ([v isKindOfClass:[UIScrollView class]]) {
            _pageScrollView = v;
            break;
        }
    }
    return _pageScrollView;
}

- (BOOL)scrollEnabled {
    if (![self.pageViewController isViewLoaded]) return _scrollEnabled;
    return self.pageScrollView.scrollEnabled;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _scrollEnabled = scrollEnabled;
    if (![self.pageViewController isViewLoaded]) {
        self.pageScrollViewScrollEnabledNeedsResetAfterViewLoadded = YES;
        return;
    }
    self.pageScrollView.scrollEnabled = scrollEnabled;
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger idx = [self.viewControllerStore indexOfObject:viewController];
    idx--;

    UIViewController *vc = [self.viewControllerStore rf_objectAtIndex:idx];
    if (!vc) return nil;

    if (![self askDelegateShouldSelectViewController:vc atIndex:idx]) {
        return nil;
    }
    return vc;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger idx = [self.viewControllerStore indexOfObject:viewController];
    idx++;

    UIViewController *vc = [self.viewControllerStore rf_objectAtIndex:idx];
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
    UIViewController *ct = pendingViewControllers.firstObject;
    NSUInteger idx = [self.viewControllerStore indexOfObject:ct];
    [self noticeDelegateWillSelectViewController:ct atIndex:idx];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    _doutwork()
    self.tabButtonsContainerView.userInteractionEnabled = YES;
    UIViewController *ct = pageViewController.viewControllers.firstObject;
    NSUInteger idx = [self.viewControllerStore indexOfObject:ct];
    self._selectedIndex = idx;
    [self noticeDelegateDidSelectViewController:ct atIndex:idx];
}

@end
