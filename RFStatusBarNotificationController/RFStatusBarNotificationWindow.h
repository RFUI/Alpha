/*!
	RFUI
	RFStateBarViewController
 
	ver -.-.-
 */

#import <UIKit/UIKit.h>

@interface RFStatusBarNotificationWindow : UIWindow

/// If you want to display your customized view, add them to viewHolder.
@property (RF_STRONG, nonatomic) UIView *viewHolder;

/// By default, we offer a label to display a text.
@property (RF_STRONG, nonatomic) UILabel *messageLabel;

@property (assign, nonatomic) CGFloat barWidth;


+ (RFStatusBarNotificationWindow *)sharedInstance;
- (RFStatusBarNotificationWindow *)initWithBarWidth:(CGFloat)width;

/// After you initialize, call this to make bar visible.
- (void)makeVisible;

/// You don`t need call this manually.
- (void)updateOrientation;
@end

extern CGFloat RFStatusBarNotificationWindowDefauleBarWidth;
