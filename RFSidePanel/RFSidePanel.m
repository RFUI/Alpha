#import "RFSidePanel.h"
#import <RFKit/UIViewController+RFInterfaceOrientation.h>

static const CGFloat RFSidePanelToggleAnimateDurationDefault = 0.5;

@interface RFSidePanel ()
@property (assign, nonatomic) CGFloat toggleAnimateDuration;
@property (readwrite, nonatomic) BOOL isShow;

@end

@implementation RFSidePanel

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
    
    self.isShow = (self.view.frame.origin.x < 0)? NO : YES;

    if (self.rootViewController) {
        [self.containerView addSubview:self.rootViewController.view resizeOption:RFViewResizeOptionFill];
    }
    
    self.toggleAnimateDuration = RFSidePanelToggleAnimateDurationDefault;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    douts(@"Load in org");
}

- (void)show:(BOOL)animated {	
    if ([self.delegate respondsToSelector:@selector(sidePanelWillShow:)]) {
        [self.delegate sidePanelWillShow:self];
    }
    
	if(animated) {
        self.separatorButtonOFF.hidden = NO;
        self.separatorButtonON.highlighted = YES;
        [self.separatorButtonON bringAboveView:self.separatorButtonOFF];
		
		[UIView animateWithDuration:self.toggleAnimateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
			[self.view moveToX:0 Y:RFMathNotChange];
		} completion:^(BOOL finished) {
            self.separatorButtonON.highlighted = NO;
            self.separatorButtonON.hidden = YES;
            // Avoid two button was hidden at the same time, for a long animat duration.
            self.separatorButtonOFF.hidden = NO;
            self.toggleAnimateDuration = RFSidePanelToggleAnimateDurationDefault;
            if ([self.delegate respondsToSelector:@selector(sidePanelDidShow:)]) {
                [self.delegate sidePanelDidShow:self];
            }
		}];
	}
	else {
		[self.view moveToX:0 Y:RFMathNotChange];
		self.separatorButtonOFF.hidden = NO;
        self.separatorButtonON.hidden = YES;
        if ([self.delegate respondsToSelector:@selector(sidePanelDidShow:)]) {
            [self.delegate sidePanelDidShow:self];
        }
	}
	_isShow = YES;
}

- (void)hide:(BOOL)animated {	
    if ([self.delegate respondsToSelector:@selector(sidePanelWillHidden:)]) {
        [self.delegate sidePanelWillHidden:self];
    }
	if(animated) {
		self.separatorButtonON.hidden = NO;
        self.separatorButtonOFF.highlighted = YES;
        [self.separatorButtonOFF bringAboveView:self.separatorButtonON];
        
		[UIView animateWithDuration:self.toggleAnimateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
			[self.view moveToX:-self.containerView.bounds.size.width Y:RFMathNotChange];
		} completion:^(BOOL finished) {
			self.separatorButtonOFF.highlighted = NO;
            self.separatorButtonOFF.hidden = YES;
            self.separatorButtonON.hidden = NO;
            self.toggleAnimateDuration = RFSidePanelToggleAnimateDurationDefault;
            if ([self.delegate respondsToSelector:@selector(sidePanelDidHidden:)]) {
                [self.delegate sidePanelDidHidden:self];
            }
		}];
	}
	else {
		[self.view moveToX:-self.containerView.bounds.size.width Y:RFMathNotChange];
		self.separatorButtonOFF.hidden = YES;
        self.separatorButtonON.hidden = NO;
        if ([self.delegate respondsToSelector:@selector(sidePanelDidHidden:)]) {
            [self.delegate sidePanelDidHidden:self];
        }
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
            _dout_float(x)

            if (xStartFrame+x < 0) {
                [self.view moveToX:xStartFrame+x Y:RFMathNotChange];
            }
            break;
            
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            _douts(@"UIGestureRecognizerStateRecognized")
            _dout_float(v);
            if (ABS(x+v*0.1) > wBounds*0.5) {
                if (v != 0) {
                    self.toggleAnimateDuration = MIN(ABS(wBounds/v)*3, RFSidePanelToggleAnimateDurationDefault*1.2);
                    _dout_float(toggleAnimateDuration)
                }
                
                if (x+v*0.1 > 0) {
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
