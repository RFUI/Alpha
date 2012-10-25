/*!
	RFUI SidePanel
	ver 0.3.0
 */

#import "RFKit.h"

@interface RFSidePanel : UIViewController
<UIGestureRecognizerDelegate>
{
	IBOutlet UIImageView * vBarBg;
	IBOutlet UIButton * vBarButton;
}

@property (RF_WEAK, nonatomic) IBOutlet UIView * masterView;
@property (readonly, nonatomic) BOOL isShow;

- (id)initWithRootController:(UIViewController *)parent;

- (void)show:(BOOL)animated;
- (void)hide:(BOOL)animated;
- (BOOL)toggle:(BOOL)animated;
- (IBAction)onSwipeLeft:(UISwipeGestureRecognizer *)sender;
- (IBAction)onSwipRight:(UISwipeGestureRecognizer *)sender;
- (IBAction)onPanelDragging:(UIPanGestureRecognizer *)sender;

@end
