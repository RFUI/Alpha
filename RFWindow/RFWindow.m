
#import "RFWindow.h"

@implementation RFWindow

@synthesize orientationNormalizedFrame = _orientationNormalizedFrame;
@synthesize alignment;


- (void)setOrientationNormalizedFrame:(CGRect)orientationNormalizedFrame {
    _dout(@"--------------------")
    
//    dout(@"mask: %x",self.autoresizingMask);
//    if (self.autoresizingMask & UIViewAutoresizingFlexibleLeftMargin) {
//        douts(@"on?")
//    }
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    _orientationNormalizedFrame = orientationNormalizedFrame;
    _dout_rect(_orientationNormalizedFrame)
    
    _dout(@"old frame: %@", NSStringFromCGRect(self.frame))
    switch ([[UIApplication sharedApplication] statusBarOrientation]) {
		case UIInterfaceOrientationPortrait:
            self.frame = _orientationNormalizedFrame;
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
            
            self.frame = CGRectMake(screenSize.width-_orientationNormalizedFrame.size.width-_orientationNormalizedFrame.origin.x,
                                    screenSize.height-_orientationNormalizedFrame.size.height-_orientationNormalizedFrame.origin.y,
                                    _orientationNormalizedFrame.size.width, _orientationNormalizedFrame.size.height);
			break;
		case UIInterfaceOrientationLandscapeLeft:
            self.frame = CGRectMake(_orientationNormalizedFrame.origin.y,
                                    screenSize.height-_orientationNormalizedFrame.size.width-_orientationNormalizedFrame.origin.x,
                                    _orientationNormalizedFrame.size.height, _orientationNormalizedFrame.size.width);
			break;
		case UIInterfaceOrientationLandscapeRight:
            self.frame = CGRectMake(screenSize.width-_orientationNormalizedFrame.size.height-_orientationNormalizedFrame.origin.y,
                                    _orientationNormalizedFrame.origin.x,
                                    _orientationNormalizedFrame.size.height, _orientationNormalizedFrame.size.width);
			break;
	}
    _dout(@"new frame: %@", NSStringFromCGRect(self.frame))
}

- (void)setup {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOrientation) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onStatusBarFrameChanged) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.orientationNormalizedFrame = self.frame;
        [self setup];
    }
    return self;
}

- (void)onStatusBarFrameChanged {
//    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    _dout_rect(statusBarFrame)
}

- (void)updateOrientation {    
	CGAffineTransform rotation;
    
    _dout(@"---- %@", NSStringFromCGRect(self.frame));
    dout(@"---- rt%@", NSStringFromCGRect(self.rootViewController.view.frame));

    _dout_rect([self convertRect:self.frame toWindow:self]);
	
	switch ([[UIApplication sharedApplication] statusBarOrientation]) {
		case UIInterfaceOrientationPortrait:
			douts(@"UIInterfaceOrientationPortrait")
			rotation = CGAffineTransformMakeRotation(0);
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			douts(@"UIInterfaceOrientationPortraitUpsideDown")       
			rotation = CGAffineTransformMakeRotation(M_PI);
			break;	
		case UIInterfaceOrientationLandscapeLeft:
			douts(@"UIInterfaceOrientationLandscapeLeft")
			rotation = CGAffineTransformMakeRotation(-M_PI_2);
			break;
		case UIInterfaceOrientationLandscapeRight:
			douts(@"UIInterfaceOrientationLandscapeRight")
			rotation = CGAffineTransformMakeRotation(M_PI_2);
			break;
	}
	self.transform = rotation;
    self.orientationNormalizedFrame = self.orientationNormalizedFrame;

    [self setNeedsDisplay];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _doutwork()
}

- (void)bringAboveWindow:(UIWindow *)window {
    UIWindowLevel level = window.windowLevel;
    self.windowLevel = ++level;
}
- (void)sendBelowWindow:(UIWindow *)window {
    UIWindowLevel level = window.windowLevel;
    self.windowLevel = --level;
}

@end


