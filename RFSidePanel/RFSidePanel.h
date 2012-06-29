/*!
	RFUI SidePanel
	ver 0.2.0
 */

#import "RFKit.h"

@interface RFSidePanel : UIViewController {
	IBOutlet UIImageView * vBarBg;
	IBOutlet UIButton * vBarButton;
}

@property (RF_STRONG, nonatomic) IBOutlet UIView * masterView;
@property ( nonatomic, assign) IBOutlet UIView * root;
@property (nonatomic, assign) BOOL isShow;

- (id)initWithManagedView:(UIView *)root;

- (void)show:(BOOL)animated;
- (void)hide:(BOOL)animated;

// 返回是否显示
- (BOOL)toggle;
- (void)savePreferences;
@end
