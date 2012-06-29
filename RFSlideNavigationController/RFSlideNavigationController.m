
#import "RFSlideNavigationController.h"
#import <QuartzCore/CALayer.h>

@interface RFSlideNavigationController ()
//@property (readwrite, nonatomic) UIScrollView * scrollContainer;
//@property (readwrite, nonatomic) NSMutableArray *stack;
@end

@implementation RFSlideNavigationController
@synthesize stack = _stack;
@synthesize scrollContainer = _scrollContainer;
@synthesize currentFocusedViewIndex = _ixCurrentFocused;


- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %d/%d %f>", NSStringFromClass([self class]),_ixCurrentFocused, self.stack.count, stackViewsWidthSum];
}

- (void)setup {
    self.stack = [NSMutableArray arrayWithCapacity:10];
}

- (void)setupView {
    
}

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
        [self performSelector:@selector(setupView) withObject:nil afterDelay:0];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.scrollContainer = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.scrollContainer.delegate = self;
    [self.view addSubview:self.scrollContainer];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
}

- (BOOL)hasView:(UIView *)view {
	return ([self.stack indexOfObject:view] != NSNotFound);
}

- (void)pushView:(UIView *)view animated:(BOOL)animated {    
    if (view == nil || view.superview == self.view) {
        return;
    }
    
    CGFloat width;
    if ([view respondsToSelector:@selector(viewWidthForRFSlideNavigationController:)]) {
        width = [((UIView<RFSlideNavigationControllerDelegate> *)view) viewWidthForRFSlideNavigationController:self];
    }
    else {
        width = view.bounds.size.width;
    }

    [self.stack addObject:view];
    _ixCurrentFocused = self.stack.count;
    
    view.hidden = YES;
    [self.scrollContainer insertSubview:view atIndex:0];
    
    CGFloat xFinal;
    CGFloat xBeforeAnimate;
    xFinal = stackViewsWidthSum;
    xBeforeAnimate = xFinal - view.bounds.size.width -50;
    view.frame = CGRectMake(xFinal, 0, width, self.scrollContainer.bounds.size.height);
    stackViewsWidthSum += width-1;
    
    self.scrollContainer.contentSize = CGSizeMake(stackViewsWidthSum, 0);
    _dout_size(self.scrollContainer.contentSize)
    
    if (animated) {
        view.hidden = NO;
        view.alpha = 0.5;
        [view moveToX:xBeforeAnimate Y:0];
        view.layer.shadowOpacity = 0.5f;
        CGPoint lastCenter = view.center;
        view.layer.transform = CATransform3DMakeScale(0.95, 0.95, 1);
        view.layer.shouldRasterize = YES;
        view.center = lastCenter;
        
        [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            view.alpha = 1.0;
            [view moveToX:xFinal Y:CGFLOAT_MAX];
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                view.layer.transform = CATransform3DMakeScale(1, 1, 1);
                [view moveToX:xFinal Y:CGFLOAT_MAX];
            } completion:^(BOOL finished) {
                view.layer.shadowOpacity = 0.f;
                view.layer.shouldRasterize = NO;
            }];
        }];
    }
    else {
        view.hidden = NO;
    }
}
- (UIView *)popViewAnimated:(BOOL)animated {
    if (self.stack.count == 0) {
        douts(@"Warning: No view to pop.")
        return nil;
    }
	
	UIView *viewWillPop = [_stack lastObject];
	
	// Update self
    CGFloat width;
    if ([viewWillPop respondsToSelector:@selector(viewWidthForRFSlideNavigationController:)]) {
        width = [((UIView<RFSlideNavigationControllerDelegate> *)viewWillPop) viewWidthForRFSlideNavigationController:self];
    }
    else {
        width = viewWillPop.bounds.size.width;
    }
    stackViewsWidthSum -= width;
    
    [self.stack removeLastObject];
    _ixCurrentFocused = self.stack.count;
	
	if (animated) {
		[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			[viewWillPop moveX:-100 Y:0];
            viewWillPop.alpha = 0.f;
			self.scrollContainer.contentSize = CGSizeMake(stackViewsWidthSum, 0);
		} completion:^(BOOL finished) {
			viewWillPop.hidden = YES;
            viewWillPop.alpha = 1.f;
			[viewWillPop removeFromSuperview];
		}];
	}
	else {
		[viewWillPop removeFromSuperview];
		self.scrollContainer.contentSize = CGSizeMake(stackViewsWidthSum, 0);
	}
    return viewWillPop;
}

- (void)popAllViewAnimated:(BOOL)animated {
	CGFloat tmp_delay = 0.f;
	CGFloat animationDelayIncrease = 0.2f;
	
	if (animated) {
		for (UIView * view in [self.stack reverseObjectEnumerator]) {
			if (view == nil) continue;
			
			[UIView animateWithDuration:0.2f delay:tmp_delay options:UIViewAnimationOptionCurveEaseOut animations:^{
				[view moveX:-100 Y:0];
				view.alpha = 0.f;
			} completion:^(BOOL finished) {
				view.hidden = YES;
				view.alpha = 1.f;
			}];
			tmp_delay += animationDelayIncrease;
		}
	}
	else {
		self.scrollContainer.contentSize = CGSizeZero;
	}
        
    // reset
    _ixCurrentFocused = 0;
    [self.stack removeAllObjects];
    stackViewsWidthSum = 0.f;
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    doutwork()
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    doutwork()
}

@end
