
#import "RFSlideNavigationController.h"
#import <QuartzCore/CALayer.h>

@interface RFSlideNavigationController ()
@property (assign, nonatomic) CGFloat stackViewsWidthSum;
@property (RF_WEAK, readwrite, nonatomic) UIScrollView *container;
@property (RF_STRONG, nonatomic) NSMutableArray *viewControllers;
@property (RF_STRONG, nonatomic) NSMutableArray *viewControllerWidths;
@end

@implementation RFSlideNavigationController

#define _RFSlideNavigationControllerSendWillShowDelegete(v, a) \
    if (self.delegate && [self.delegate respondsToSelector:@selector(RFSlideNavigationController:willShowViewController:animated:)]) {\
        [self.delegate RFSlideNavigationController:self willShowViewController:v animated:a];\
    }

#define _RFSlideNavigationControllerSendDidShowDelegete(v, a) \
    if (self.delegate && [self.delegate respondsToSelector:@selector(RFSlideNavigationController:didShowViewController:animated:)]) {\
        [self.delegate RFSlideNavigationController:self didShowViewController:v animated:a];\
    }

#pragma mark - Property
- (NSArray *)viewControllers {
    return [NSArray arrayWithArray:_viewControllers];
}

- (UIScrollView *)container {
    if (!_container) {
        UIScrollView *view = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        view.delegate = self;
        [self.view addSubview:view];
        _container = view;
    }
    return _container;
}

#pragma mark -
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p viewControllers:%lu %f>", NSStringFromClass([self class]), self, self.viewControllers.count, self.stackViewsWidthSum];
}

- (id)init {
    self = [super init];
    if (self) {
        self.viewControllers = [NSMutableArray arrayWithCapacity:10];
        self.viewControllerWidths = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

#pragma mark - Push & Pop
- (void)pushViewController:(UIViewController<RFSlideNavigationControllerDelegate> *)viewController animated:(BOOL)animated {
    if (viewController == nil || viewController.parentViewController == self) {
        return;
    }
    
    UIView *view = viewController.view;
    [self addChildViewController:viewController];
    [_viewControllers addObject:viewController];
    
    CGFloat width = ([viewController respondsToSelector:@selector(viewWidthForRFSlideNavigationController:)])?
        [viewController viewWidthForRFSlideNavigationController:self] : view.bounds.size.width;
    [_viewControllerWidths addObject:@(width)];
    
    _RFSlideNavigationControllerSendWillShowDelegete(viewController, animated)
    CGFloat xFinal = _stackViewsWidthSum;
    CGFloat xBeforeAnimate = xFinal - view.bounds.size.width -50;
    _stackViewsWidthSum += width-1;
    view.frame = CGRectMake(xFinal, 0, width, self.container.bounds.size.height);
    [self.container insertSubview:view atIndex:0];
    
    self.container.contentSize = CGSizeMake(_stackViewsWidthSum, 0);
    _dout_size(self.scrollContainer.contentSize)
    
    if (animated) {
        CALayer *layer = view.layer;
        view.alpha = 0.5;
        [view moveToX:xBeforeAnimate Y:0];
        layer.shadowOpacity = 0.5f;
        CGPoint lastCenter = view.center;
        layer.transform = CATransform3DMakeScale(0.95, 0.95, 1);
        layer.shouldRasterize = YES;
        view.center = lastCenter;
        
        [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            view.alpha = 1.0;
            [view moveToX:xFinal Y:RFMathNotChange];
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                layer.transform = CATransform3DMakeScale(1, 1, 1);
                [view moveToX:xFinal Y:RFMathNotChange];
            } completion:^(BOOL finished) {
                layer.shadowOpacity = 0.f;
                layer.shouldRasterize = NO;
                _RFSlideNavigationControllerSendDidShowDelegete(viewController, YES);
            }];
        }];
    }
    else {
        _RFSlideNavigationControllerSendDidShowDelegete(viewController, NO);
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    if (self.viewControllers.count == 0) {
        dout_warning(@"No ViewController to pop.")
        return nil;
    }
	
    UIViewController *viewControllerWillRemove = [_viewControllers lastObject];
    UIViewController *viewControllerWillShow = (_viewControllers.count > 1)? [_viewControllers objectAtIndex:(_viewControllers.count-2)] : nil;
    [_viewControllers removeLastObject];
    
	UIView *viewWillPop = viewControllerWillRemove.view;
    CGFloat width = [[_viewControllerWidths lastObject] floatValue];
    self.stackViewsWidthSum -= width;
	
    _RFSlideNavigationControllerSendWillShowDelegete(viewControllerWillShow, animated)
	if (animated) {
		[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			[viewWillPop moveX:-100 Y:0];
            viewWillPop.alpha = 0.f;
			self.container.contentSize = CGSizeMake(_stackViewsWidthSum, 0);
		} completion:^(BOOL finished) {
			viewWillPop.hidden = YES;
            viewWillPop.alpha = 1.f;
			[viewWillPop removeFromSuperview];
            [viewControllerWillRemove removeFromParentViewController];
            _RFSlideNavigationControllerSendDidShowDelegete(viewControllerWillShow, YES);
		}];
	}
	else {
		[viewWillPop removeFromSuperview];
		self.container.contentSize = CGSizeMake(_stackViewsWidthSum, 0);
        [viewControllerWillRemove removeFromParentViewController];
        _RFSlideNavigationControllerSendDidShowDelegete(viewControllerWillShow, NO);
	}
    return viewControllerWillRemove;
}

- (NSArray *)popAllViewControllersAnimated:(BOOL)animated {
	CGFloat tmp_delay = 0.f;
	CGFloat animationDelayIncrease = 0.2f;
	
    _RFSlideNavigationControllerSendWillShowDelegete(nil, animated)
	if (animated) {
        UIView *view;
		for (UIViewController *viewController in [self.viewControllers reverseObjectEnumerator]) {
            view = viewController.view;
			
			[UIView animateWithDuration:0.2f delay:tmp_delay options:UIViewAnimationOptionCurveEaseOut animations:^{
				[view moveX:-100 Y:0];
				view.alpha = 0.f;
			} completion:^(BOOL finished) {
				view.hidden = YES;
				view.alpha = 1.f;
			}];
			tmp_delay += animationDelayIncrease;
		}
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, tmp_delay * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            _RFSlideNavigationControllerSendDidShowDelegete(nil, YES);
        });
	}
	else {
		self.container.contentSize = CGSizeZero;
        _RFSlideNavigationControllerSendDidShowDelegete(nil, NO);
	}
    
    // reset
    [_viewControllers removeAllObjects];
    self.stackViewsWidthSum = 0.f;
    return nil;
}


#pragma mark - index
- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    if (index < _viewControllers.count) {
        return _viewControllers[index];
    }
    else
        return nil;
}

- (NSUInteger)indexForViewController:(UIViewController *)viewController {
    return [_viewControllers indexOfObject:viewController];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    doutwork()
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    doutwork()
}

@end
