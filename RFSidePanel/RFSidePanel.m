#import "RFSidePanel.h"

static const CGFloat RFSidePanelToggleAnimateDurationDefault = 0.5;

@interface RFSidePanel () {
    CGFloat toggleAnimateDuration;
}
@property (readwrite, nonatomic) BOOL isShow;

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
    
    toggleAnimateDuration = RFSidePanelToggleAnimateDurationDefault;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    douts(@"Load in org");
}

- (void)show:(BOOL)animated {
	if(self.isShow == YES && [self isViewLoaded]) return;
	
	if(animated) {
        self.separatorButtonOFF.hidden = NO;
        self.separatorButtonON.highlighted = YES;
        [self.separatorButtonON bringAboveView:self.separatorButtonOFF];
		
		[UIView animateWithDuration:toggleAnimateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
			[self.view moveToX:0 Y:RFMathNotChange];
		} completion:^(BOOL finished) {
            self.separatorButtonON.highlighted = NO;
            self.separatorButtonON.hidden = YES;
            toggleAnimateDuration = RFSidePanelToggleAnimateDurationDefault;
		}];
	}
	else {
		[self.view moveToX:0 Y:RFMathNotChange];
		self.separatorButtonOFF.hidden = NO;
        self.separatorButtonON.hidden = YES;
	}
	_isShow = YES;
}

- (void)hide:(BOOL)animated {
	if(self.isShow == NO && [self isViewLoaded]) return;
	
	if(animated) {
		self.separatorButtonON.hidden = NO;
        self.separatorButtonOFF.highlighted = YES;
        [self.separatorButtonOFF bringAboveView:self.separatorButtonON];
        
		[UIView animateWithDuration:toggleAnimateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
			[self.view moveToX:-self.containerView.bounds.size.width Y:RFMathNotChange];
		} completion:^(BOOL finished) {
			self.separatorButtonOFF.highlighted = NO;
            self.separatorButtonOFF.hidden = YES;
            toggleAnimateDuration = RFSidePanelToggleAnimateDurationDefault;
		}];
	}
	else {
		[self.view moveToX:-self.containerView.bounds.size.width Y:RFMathNotChange];
		self.separatorButtonOFF.hidden = YES;
        self.separatorButtonON.hidden = NO;
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

- (IBAction)onHide:(UIButton *)sender {
    [self hide:YES];
}

- (IBAction)onShow:(UIButton *)sender {
    [self show:YES];
}

- (IBAction)onPanelDragging:(UIPanGestureRecognizer *)sender {
    CGFloat x = [sender translationInView:self.view].x;
    CGFloat v = [sender velocityInView:sender.view].x;
    _dout_float(v);
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
            if (ABS(x*3+v) > wBounds*3) {
                if (v != 0) {
                    toggleAnimateDuration = ABS(wBounds/v)*2;
                }
                
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

@end
