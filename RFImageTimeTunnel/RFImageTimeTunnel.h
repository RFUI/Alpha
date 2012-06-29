/*!
	 RFUI ImageTimeTunnel
	 ver 0.0.1
 */

#import <UIKit/UIKit.h>

enum RFImageTimeTunnelGestureMode {
	RFImageTimeTunnelGestureModePosition = 0,
	RFImageTimeTunnelGestureModeSpeed = 1
};

@interface RFImageTimeTunnel : UIViewController {
	
	IBOutlet UIImageView * vImage1;
	IBOutlet UIImageView * vImage2;
	IBOutlet UIImageView * vImage3;
	
	IBOutlet UISlider * tunnelSlider;
	
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
@property (nonatomic, strong) NSArray * imageArray;

@property (nonatomic, strong) UIImageView * vImage1;
@property (nonatomic, strong) UIImageView * vImage2;
@property (nonatomic, strong) UIImageView * vImage3;
@property (nonatomic, strong) UISlider * tunnelSlider;
@property (nonatomic, assign) BOOL isAlphaTransformEnable;

- (id)init;
- (void)setImagesWithUIImageArray:(NSArray *)UIImageArray;
- (IBAction)onSliderValueChange:(UISlider *)sender;
@end

