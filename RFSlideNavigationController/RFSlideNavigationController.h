/*!
    RFUI
    RFSlideNavigationController
 
    ver -.-.-
 */

#import "RFUI.h"

@protocol RFSlideNavigationControllerDelegate;

@interface RFSlideNavigationController : UIViewController
<UIScrollViewDelegate, RFNotSupportLoadFromNib, RFSupportIOS5_0>

@property (RF_WEAK, readonly, nonatomic) UIScrollView *container;

- (id)init;
//- (id)initWithRootViewController:(UIViewController *)rootViewController;
//@property(nonatomic, readonly, retain) UIViewController *topViewController
//@property(nonatomic, readonly, retain) UIViewController *visibleViewController
//@property(nonatomic, copy) NSArray *viewControllers
//- (NSArray *)viewControllers;
//- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
- (NSArray *)popAllViewControllersAnimated:(BOOL)animated;
//- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated

/// index
- (NSArray *)viewControllers;
- (UIViewController *)viewControllerAtIndex:(NSUInteger)index;
- (NSUInteger)indexForViewController:(UIViewController *)viewController;
//- (NSArray *)visibleViewControllers;
//- (NSArray *)indexsForVisibleViewControllers;

/// Scrolling
//- (void)scrollToViewControllerAtIndex:(NSUInteger)index atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;

@property(nonatomic, assign) id<RFSlideNavigationControllerDelegate> delegate;
@end



@protocol RFSlideNavigationControllerDelegate <NSObject>

@optional
- (void)RFSlideNavigationController:(RFSlideNavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (void)RFSlideNavigationController:(RFSlideNavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (CGFloat)viewWidthForRFSlideNavigationController:(RFSlideNavigationController *)sender;

@end
