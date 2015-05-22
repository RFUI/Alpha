
#import "RFPageTabController.h"

@interface RFPageTabController () <
    UIPageViewControllerDataSource,
    UIPageViewControllerDelegate
>
@property (strong, readwrite, nonatomic) UIPageViewController *pageViewController;

@end

@implementation RFPageTabController

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
}

- (void)didDataSourceUpdateFromArray:(NSArray *)oldViewControllers toArray:(NSArray *)newViewControllers {
    UIViewController *oldSelectedViewController = self.selectedViewController;
    NSUInteger newIndex = [newViewControllers indexOfObject:oldSelectedViewController];
    if (newIndex != NSNotFound) {
        self.selectedIndex = newIndex;
    }
    else if (newIndex < newViewControllers.count) {
        self.selectedIndex = newIndex;
    }
    else {
        self.selectedIndex = 0;
    }
}

- (void)setSelectedIndex:(NSUInteger)newSelectedIndex animated:(BOOL)animated {
    UIViewController *svc = [self.viewControllers rf_objectAtIndex:newSelectedIndex];
    if (!svc) {
        return;
    }

    if (![self askDelegateShouldSelectViewController:svc atIndex:newSelectedIndex]) {
        return;
    }

    UIPageViewControllerNavigationDirection direction = (_selectedIndex > newSelectedIndex)? UIPageViewControllerNavigationDirectionReverse : UIPageViewControllerNavigationDirectionForward;
    _selectedIndex = newSelectedIndex;

    @weakify(self);
    UIView *tabContainer = self.tabButtonsContainerView;
    tabContainer.userInteractionEnabled = NO;
    [self.pageViewController setViewControllers:@[ svc ] direction:direction animated:animated completion:^(BOOL finished) {
        @strongify(self);
        tabContainer.userInteractionEnabled = YES;
        [self noticeDelegateDidSelectViewController:svc atIndex:newSelectedIndex];
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
    _selectedIndex = [self.viewControllers indexOfObject:pageViewController.viewControllers.firstObject];
}

@end
