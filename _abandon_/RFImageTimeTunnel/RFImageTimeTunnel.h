/*!
	 RFUI ImageTimeTunnel
	 ver 0.0.1
 */

#import "RFUI.h"

enum RFImageTimeTunnelGestureMode {
	RFImageTimeTunnelGestureModePosition = 0,
	RFImageTimeTunnelGestureModeSpeed = 1
};

@interface RFImageTimeTunnel : UIViewController {
	NSUInteger ixCurrent;
	NSUInteger imageCount;

	BOOL isImageSet;
	BOOL isAlphaTransformEnable;
	enum RFImageTimeTunnelGestureMode gestureMode;
	
	IBOutlet UILabel * t1;
	IBOutlet UILabel * t2;
	IBOutlet UILabel * t3;
	IBOutlet UILabel * t4;
	IBOutlet UILabel * t5;
	IBOutlet UILabel * t6;
	IBOutlet UILabel * t7;
	
	CGPoint tcStart;
	CGPoint tcLast;
}
@property(nonatomic, strong) NSArray * imageArray;

@property(nonatomic, weak) IBOutlet UIImageView * vImage1;
@property(nonatomic, weak) IBOutlet UIImageView * vImage2;
@property(nonatomic, weak) IBOutlet UIImageView * vImage3;
@property(nonatomic, weak) IBOutlet UISlider * tunnelSlider;
@property(nonatomic, assign) BOOL isAlphaTransformEnable;

- (void)setImagesWithUIImageArray:(NSArray *)UIImageArray;
- (IBAction)onSliderValueChange:(UISlider *)sender;
@end

