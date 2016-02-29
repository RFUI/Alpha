
#import "RFStatusBarNotificationWindow.h"

CGFloat RFStatusBarNotificationWindowDefauleBarWidth = 200.f;

@implementation RFStatusBarNotificationWindow
@synthesize barWidth;
@synthesize viewHolder;
@synthesize messageLabel;

+ (RFStatusBarNotificationWindow *)sharedInstance {
	static RFStatusBarNotificationWindow *sharedInstance = nil;
	
	if (sharedInstance == nil) {
		@synchronized(self) {
			if (sharedInstance == nil) {
				sharedInstance = [[self alloc] initWithBarWidth:RFStatusBarNotificationWindowDefauleBarWidth];
			}
		}
	}
	return sharedInstance;
}

- (RFStatusBarNotificationWindow *)initWithFrame:(CGRect)frame {
	douts(@"Warning: frame will be ignored, you can call  initWithBarWidth: instead");
	return [[RFStatusBarNotificationWindow alloc] initWithBarWidth:RFStatusBarNotificationWindowDefauleBarWidth];
}

- (RFStatusBarNotificationWindow *)initWithBarWidth:(CGFloat)width {
	self = [super initWithFrame:CGRectZero];
	if(self){
		self.windowLevel = UIWindowLevelStatusBar + 1.f;
		self.barWidth = width;
		
//		self.backgroundColor = [UIColor redColor];
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(updateOrientation) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
		[nc addObserver:self selector:@selector(updateOrientation) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
		
		self.viewHolder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, barWidth, 20)];
		self.viewHolder.backgroundColor = [UIColor blackColor];
//		self.viewHolder.backgroundColor = [UIColor colorWithRGBHex:0xFFFFFF alpha:0.5];
//		self.viewHolder.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		[self addSubview:self.viewHolder];
		
		self.messageLabel = [[UILabel alloc] initWithFrame:self.viewHolder.frame];
		self.messageLabel.textColor = [UIColor whiteColor];
		self.messageLabel.backgroundColor = [UIColor clearColor];
		self.messageLabel.font = [UIFont systemFontOfSize:14];
		
		[self.viewHolder addSubview:self.messageLabel];
		[self updateOrientation];
	}
	return self;
}

- (void)makeVisible {
	self.hidden = NO;
	[self updateOrientation];	// No doubt this, you can try remove it. But Why?
}

- (void)updateOrientation {
	CGAffineTransform rotation;
	CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
	_dout_rect(statusBarFrame)
	
	switch ([[UIApplication sharedApplication] statusBarOrientation]) {
		case UIInterfaceOrientationPortrait:
			_douts(@"UIInterfaceOrientationPortrait")
//			statusBarFrame.origin.x = self.barWidth;
			statusBarFrame.origin.x = statusBarFrame.size.width - self.barWidth;
			statusBarFrame.size.width = self.barWidth;
			rotation = CGAffineTransformMakeRotation(0);
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			_douts(@"UIInterfaceOrientationPortraitUpsideDown")
			statusBarFrame.size.width = self.barWidth;
//			statusBarFrame.origin.y = self.barWidth;
			rotation = CGAffineTransformMakeRotation(M_PI);
			break;	
		case UIInterfaceOrientationLandscapeLeft:
			_douts(@"UIInterfaceOrientationLandscapeLeft")
			statusBarFrame.size.height = self.barWidth;
			rotation = CGAffineTransformMakeRotation(-M_PI_2);
			break;
		case UIInterfaceOrientationLandscapeRight:
			_douts(@"UIInterfaceOrientationLandscapeRight")
//			statusBarFrame.size.height = self.barWidth;
			statusBarFrame.origin.y = statusBarFrame.size.height - self.barWidth;
			statusBarFrame.size.height = self.barWidth;
			rotation = CGAffineTransformMakeRotation(M_PI_2);
			break;
	}
	self.frame = statusBarFrame;
//	self.viewHolder.frame = statusBarFrame;
	self.transform = rotation;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
