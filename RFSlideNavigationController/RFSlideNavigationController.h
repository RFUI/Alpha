/*!
    RFUI
    RFSlideNavigationController
 
    ver -.-.-
 */

#import "RFKit.h"

@protocol RFSlideNavigationControllerDelegate;

@interface RFSlideNavigationController : UIViewController<UIScrollViewDelegate> {
    CGFloat stackViewsWidthSum;
}
@property (strong, nonatomic) IBOutlet UIScrollView * scrollContainer;
@property (strong, nonatomic) NSMutableArray *stack;
@property (assign, nonatomic) NSUInteger currentFocusedViewIndex;

- (void)pushView:(UIView *)view animated:(BOOL)animated;
- (UIView *)popViewAnimated:(BOOL)animated;
- (void)popAllViewAnimated:(BOOL)animated;
- (BOOL)hasView:(UIView *)view;                               
@end



@protocol RFSlideNavigationControllerDelegate <NSObject>

- (CGFloat)viewWidthForRFSlideNavigationController:(RFSlideNavigationController *)sender;
@end
