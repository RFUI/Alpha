/*!
 */
#import "RFUI.h"

@interface RFWindow : UIWindow

@property (assign, nonatomic) CGRect orientationNormalizedFrame;
@property (assign, nonatomic) RFAlignmentAnchor alignment;

@end

@interface UIWindow (RFWindow)
- (void)bringAboveWindow:(UIWindow *)window;
- (void)sendBelowWindow:(UIWindow *)window;
@end
