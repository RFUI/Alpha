/*!
	RFUI
	RFStateBarViewController
 
	ver -.-.-
 */

#import <RFKit/RFKit.h>

@interface RFStatusBarNotificationWindow : UIWindow

/// If you want to display your customized view, add them to viewHolder.
@property (strong, nonatomic) UIView *viewHolder;

/// By default, we offer a label to display a text.
@property (strong, nonatomic) UILabel *messageLabel;

@property (assign, nonatomic) CGFloat barWidth;

- (RFStatusBarNotificationWindow *)initWithBarWidth:(CGFloat)width;

/// After you initialize, call this to make bar visible.
- (void)makeVisible;

/// You don`t need call this manually.
- (void)updateOrientation;
@end

extern CGFloat RFStatusBarNotificationWindowDefauleBarWidth;
