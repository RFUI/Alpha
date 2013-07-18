#import "RFImageTimeTunnel.h"

@implementation RFImageTimeTunnel
@synthesize vImage1, vImage2, vImage3, tunnelSlider;
//@synthesize tunnelSlider;
@synthesize imageArray, isAlphaTransformEnable;

- (id)init {
    self = [super initWithNibName:@"RFImageTimeTunnel" bundle:nil];
    if (self) {
		isImageSet = NO;
		isAlphaTransformEnable = YES;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self onSliderValueChange:nil];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
	
	self.vImage2 = nil;
	self.vImage3 = nil;
	self.vImage1 = nil;
	self.tunnelSlider = nil;
	
	self.imageArray = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

// TODO: Check UIImageArray
- (void)setImagesWithUIImageArray:(NSArray *)UIImageArray {
	self.imageArray = UIImageArray;
	imageCount = [UIImageArray count];
	
	isImageSet = YES;
	
	ixCurrent = 0;
	tunnelSlider.value = 0;
	[vImage2 bringToFront];
	[vImage1 bringToFront];
	
	if (imageCount > 0) {
		vImage1.image = [self.imageArray objectAtIndex:0];
	}
	if (imageCount > 1) {
		vImage2.image = [self.imageArray objectAtIndex:1];
	}
}

- (UIImageView *)getImageView:(int)inImageView {
	// 防止负值
	switch ((inImageView+3)%3) {
		case 0:
			return vImage1;
			break;
			
		case 1:
			return vImage2;
			break;
			
		case 2:
			return vImage3;
			break;
	}
	return nil;
}

- (void)changeImage:(UIImageView *)vImage to:(int)ixImageArray {
	if (ixImageArray < 0 || ixImageArray >= imageArray.count) {
		vImage.image = nil;
		return;
	}
	vImage.image = [self.imageArray objectAtIndex:ixImageArray];
}

// f, float value;
// if, index float;
// ix, index 0~n;
// in, index 1~n;
- (IBAction)onSliderValueChange:(UISlider *)sender {
	if (!isImageSet) return;
	
	float fBlockLength = 100.f / (imageCount - 1);
	float fSlider	= tunnelSlider.value;
	int   ixShould	= (int)(fSlider / fBlockLength);
	
	UIImageView *vPrev, *vCt, *vNext;
	
	if (ixShould != ixCurrent) {
		vPrev = [self getImageView:ixShould-1];
		vCt   = [self getImageView:ixShould];
		vNext = [self getImageView:ixShould+1];
		
		if (ixShould >= ixCurrent) {
			// 向右
			[self changeImage:vNext to:ixShould+1];
		}
		else {
			// 向左
			[self changeImage:vPrev to:ixShould-1];
		}
		[vCt bringToFront];
		ixCurrent = ixShould;
	}
	else {
		vPrev = [self getImageView:ixCurrent-1];
		vCt   = [self getImageView:ixCurrent];
		vNext = [self getImageView:ixCurrent+1];
	}

	if (isAlphaTransformEnable) {
		float fAlpha = fmodf(fSlider, fBlockLength) / fBlockLength;
		vCt.alpha = 1.f - fAlpha;
		vNext.alpha = fAlpha;
	}
	
    if (RFDEBUG) {
        t1.text = [NSString stringWithFormat:@"v = %f", fSlider];
        t2.text = [NSString stringWithFormat:@"iShould = %d", ixShould];
        t7.text = [NSString stringWithFormat:@"ixCurrent = %d", ixCurrent];
        //	t6.text = [NSString stringWithFormat:@"nx = %d", ixNext];
        t3.text = [NSString stringWithFormat:@"v1 = %f", vImage1.alpha];
        t4.text = [NSString stringWithFormat:@"v2 = %f", vImage2.alpha];
        t5.text = [NSString stringWithFormat:@"v3 = %f", vImage3.alpha];        
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	// 只处理一只手指
    if ([[event touchesForView:self.view] count] == 1) {
		tcStart = [[touches anyObject] locationInView:self.view];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	// 只处理一只手指
    if ([[event touchesForView:self.view] count] == 1) {
		tcLast = [[touches anyObject] locationInView:self.view];
		if (gestureMode == RFImageTimeTunnelGestureModePosition) {
			tunnelSlider.value = tcLast.x/self.view.bounds.size.width*tunnelSlider.maximumValue;
		}
		else {
			tunnelSlider.value += (tcLast.x - tcStart.x)/self.view.bounds.size.width * 1.5;
		}
		[self onSliderValueChange:nil];
    }
}

@end


