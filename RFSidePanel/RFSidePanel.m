#import "RFSidePanel.h"

static CGFloat kToggleAnimateDuration = 0.5f;

@interface RFSidePanel ()
@property (readwrite, nonatomic) BOOL isShow;

@property (RF_WEAK, nonatomic) IBOutlet UIImageView * vBarBg;
@property (RF_WEAK, nonatomic) IBOutlet UIButton * vBarButton;
@end

@implementation RFSidePanel
RFUIInterfaceOrientationSupportAll

- (void)setRootViewController:(UIViewController *)rootViewController {
    _dout_bool([self isViewLoaded])
    
    if (_rootViewController != rootViewController) {
        if (_rootViewController) {
            [_rootViewController removeFromParentViewControllerAndView];
        }
        
        if (rootViewController) {
            [self addChildViewController:rootViewController];
            [self.containerView addSubview:rootViewController.view resizeOption:RFViewResizeOptionFill];
        }
        
        _rootViewController = rootViewController;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isShow = (self.view.frame.origin.x < 0)? NO : YES;

    if (self.rootViewController) {
        [self.containerView addSubview:self.rootViewController.view resizeOption:RFViewResizeOptionFill];
    }
    
    UISwipeGestureRecognizer * recognizer;
	recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipRight:)];
	recognizer.direction = UISwipeGestureRecognizerDirectionRight;
	[self.view addGestureRecognizer:recognizer];
    RF_RELEASE_OBJ(recognizer)
	
	recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeLeft:)];
	recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
	[self.view addGestureRecognizer:recognizer];
    RF_RELEASE_OBJ(recognizer)
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)show:(BOOL)animated {
	if(self.isShow == YES && [self isViewLoaded]) return;
	
	if(animated) {
		[self.vBarButton setImage:[UIImage resourceName:@"SidePanel-off.active"] forState:UIControlStateNormal];
		
		[UIView animateWithDuration:kToggleAnimateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
			[self.view moveToX:0 Y:RFMathNotChange];
		} completion:^(BOOL finished) {
			[self.vBarButton setImage:[UIImage resourceName:@"SidePanel-on"] forState:UIControlStateNormal];
			[self.vBarButton setImage:[UIImage resourceName:@"SidePanel-on.active"] forState:UIControlStateHighlighted];
		}];
	}
	else {
		[self.view moveToX:0 Y:RFMathNotChange];
		[self.vBarButton setImage:[UIImage resourceName:@"SidePanel-on"] forState:UIControlStateNormal];
		[self.vBarButton setImage:[UIImage resourceName:@"SidePanel-on.active"] forState:UIControlStateHighlighted];
	}
	_isShow = YES;
}

- (void)hide:(BOOL)animated {
	if(self.isShow == NO && [self isViewLoaded]) return;
	
	if(animated) {
		[self.vBarButton setImage:[UIImage resourceName:@"SidePanel-on.active"] forState:UIControlStateNormal];
		
		[UIView animateWithDuration:kToggleAnimateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
			[self.view moveToX:-self.containerView.bounds.size.width Y:RFMathNotChange];
		} completion:^(BOOL finished) {
			[self.vBarButton setImage:[UIImage resourceName:@"SidePanel-off"] forState:UIControlStateNormal];
			[self.vBarButton setImage:[UIImage resourceName:@"SidePanel-off.active"] forState:UIControlStateHighlighted];
		}];
	}
	else {
		[self.view moveToX:-self.containerView.bounds.size.width Y:RFMathNotChange];
		[self.vBarButton setImage:[UIImage resourceName:@"SidePanel-off"] forState:UIControlStateNormal];
		[self.vBarButton setImage:[UIImage resourceName:@"SidePanel-off.active"] forState:UIControlStateHighlighted];
	}
	_isShow = NO;
}

- (BOOL)toggle:(BOOL)animated {
	if(_isShow) {
		[self hide:animated];
	}
	else {
		[self show:animated];
	}
	return _isShow;
}

- (IBAction)onSwipeLeft:(UISwipeGestureRecognizer *)sender {
    [self hide:YES];
}

- (IBAction)onSwipRight:(UISwipeGestureRecognizer *)sender {
    [self show:YES];
}

- (IBAction)onPanelDragging:(UIPanGestureRecognizer *)sender {
    CGFloat x = [sender translationInView:self.view].x;
    CGFloat wBounds = self.containerView.bounds.size.width;
    CGFloat xFrame = self.view.frame.origin.x;
    
    static CGFloat xStartFrame;
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            _douts(@"UIGestureRecognizerStateBegan")
            xStartFrame = xFrame;
            break;
            
        case UIGestureRecognizerStateChanged:
            _douts(@"UIGestureRecognizerStateChanged")
            if (xStartFrame+x < 0) {
                [self.view moveToX:xStartFrame+x Y:RFMathNotChange];
            }
            break;
            
        case UIGestureRecognizerStateFailed:            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            _douts(@"UIGestureRecognizerStateRecognized")
            if (ABS(x) > wBounds*0.5) {
                if (x > 0) {
                    [self show:YES];
                }
                else {
                    [self hide:YES];
                }
            }
            else {
                _isShow = !_isShow;
                [self toggle:YES];
            }
            break;
            
        default:
            break;
    }
}

- (IBAction)onBarButtonTapped:(id)sender {
    [self toggle:YES];
}

@end
