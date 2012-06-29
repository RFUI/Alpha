#import "RFSidePanel.h"

static CGFloat kToggleAnimateDuration = 0.5f;

@implementation RFSidePanel
@synthesize masterView = _masterView;
@synthesize root = _root, isShow = _isShow;

- (id)initWithManagedView:(UIView *)root {
    self = [super initWithNibName:@"SidePanel" bundle:nil];
    if (self) {
        // Custom initialization
		self.root = root;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)show:(BOOL)animated {
	if(_isShow) return;
	
	if(animated) {
		[vBarButton setImage:[UIImage resourceName:@"SidePanel-off.active"] forState:UIControlStateNormal];
		
		[UIView animateWithDuration:kToggleAnimateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			[self.view moveToX:0 Y:CGFLOAT_MAX];
		} completion:^(BOOL finished) {
			[vBarButton setImage:[UIImage resourceName:@"SidePanel-on"] forState:UIControlStateNormal];
			[vBarButton setImage:[UIImage resourceName:@"SidePanel-on.active"] forState:UIControlStateHighlighted];
		}];
	}
	else {
		[self.view moveToX:0 Y:CGFLOAT_MAX];
		[vBarButton setImage:[UIImage resourceName:@"SidePanel-on"] forState:UIControlStateNormal];
		[vBarButton setImage:[UIImage resourceName:@"SidePanel-on.active"] forState:UIControlStateHighlighted];
	}
	_isShow = YES;
}

- (void)hide:(BOOL)animated {
	if(!_isShow) return;
	
	if(animated) {
		[vBarButton setImage:[UIImage resourceName:@"SidePanel-on.active"] forState:UIControlStateNormal];
		
		[UIView animateWithDuration:kToggleAnimateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			[self.view moveToX:-_masterView.bounds.size.width Y:CGFLOAT_MAX];
		} completion:^(BOOL finished) {
			[vBarButton setImage:[UIImage resourceName:@"SidePanel-off"] forState:UIControlStateNormal];
			[vBarButton setImage:[UIImage resourceName:@"SidePanel-off.active"] forState:UIControlStateHighlighted];
		}];
	}
	else {
		[self.view moveToX:-_masterView.bounds.size.width Y:CGFLOAT_MAX];
		[vBarButton setImage:[UIImage resourceName:@"SidePanel-off"] forState:UIControlStateNormal];
		[vBarButton setImage:[UIImage resourceName:@"SidePanel-off.active"] forState:UIControlStateHighlighted];
	}
	_isShow = NO;
}

- (BOOL)toggle {
	if(_isShow) {
		[self hide:YES];
	}
	else {
		[self show:YES];
	}
	return _isShow;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.masterView addSubview:self.root];
	
	// 默认认为自己是展开的
	_isShow = true;
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"RFSidePanel_isShow"]) {
		[self hide:NO];
	}
	
	[self performSelector:@selector(doAfterViewLoad) withObject:nil afterDelay:0.f];
}

-(void)doAfterViewLoad {
	UISwipeGestureRecognizer * recognizer;
	recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(show:)];
	recognizer.direction = UISwipeGestureRecognizerDirectionRight;
	[self.view addGestureRecognizer:recognizer];
    RF_RELEASE_OBJ(recognizer)
	
	recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hide:)];
	recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
	[self.view addGestureRecognizer:recognizer];
    RF_RELEASE_OBJ(recognizer)
	
	[vBarButton addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(savePreferences) name:@"MSGRFUISavePreferences" object:nil];
}

- (void)savePreferences {
	[[NSUserDefaults standardUserDefaults] setBool:_isShow forKey:@"RFSidePanel_isShow"];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.root = nil;
	self.masterView = nil;
	[RFKit rls:vBarBg, vBarButton];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

@end
