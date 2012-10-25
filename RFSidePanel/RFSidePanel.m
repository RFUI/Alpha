#import "RFSidePanel.h"

static CGFloat kToggleAnimateDuration = 0.5f;

@interface RFSidePanel ()
@property (readwrite, nonatomic) BOOL isShow;
@end

@implementation RFSidePanel
RFUIInterfaceOrientationSupportAll

- (id)initWithRootController:(UIViewController *)parent {
    self = [super initWithNibName:@"RFSidePanel" bundle:nil];
    if (self) {
        // Custom initialization
        [parent addChildViewController:self];
        self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
        [parent.view addSubview:self.view resizeOption:RFViewResizeOptionOnlyHeight];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _isShow = !_isShow;
        [self toggle:NO];
    });
}

- (void)show:(BOOL)animated {
	if(_isShow) return;
	
	if(animated) {
		[vBarButton setImage:[UIImage resourceName:@"SidePanel-off.active"] forState:UIControlStateNormal];
		
		[UIView animateWithDuration:kToggleAnimateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
			[self.view moveToX:0 Y:RFMathNotChange];
		} completion:^(BOOL finished) {
			[vBarButton setImage:[UIImage resourceName:@"SidePanel-on"] forState:UIControlStateNormal];
			[vBarButton setImage:[UIImage resourceName:@"SidePanel-on.active"] forState:UIControlStateHighlighted];
		}];
	}
	else {
		[self.view moveToX:0 Y:RFMathNotChange];
		[vBarButton setImage:[UIImage resourceName:@"SidePanel-on"] forState:UIControlStateNormal];
		[vBarButton setImage:[UIImage resourceName:@"SidePanel-on.active"] forState:UIControlStateHighlighted];
	}
	_isShow = YES;
}

- (void)hide:(BOOL)animated {
	if(!_isShow) return;
	
	if(animated) {
		[vBarButton setImage:[UIImage resourceName:@"SidePanel-on.active"] forState:UIControlStateNormal];
		
		[UIView animateWithDuration:kToggleAnimateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
			[self.view moveToX:-_masterView.bounds.size.width Y:RFMathNotChange];
		} completion:^(BOOL finished) {
			[vBarButton setImage:[UIImage resourceName:@"SidePanel-off"] forState:UIControlStateNormal];
			[vBarButton setImage:[UIImage resourceName:@"SidePanel-off.active"] forState:UIControlStateHighlighted];
		}];
	}
	else {
		[self.view moveToX:-_masterView.bounds.size.width Y:RFMathNotChange];
		[vBarButton setImage:[UIImage resourceName:@"SidePanel-off"] forState:UIControlStateNormal];
		[vBarButton setImage:[UIImage resourceName:@"SidePanel-off.active"] forState:UIControlStateHighlighted];
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
    CGFloat wBounds = self.masterView.bounds.size.width;
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
