
#import "RFSliderView.h"
#import "RFFullSizeCollectionViewFlowLayout.h"
#import "RFTimer.h"
#import <RFKit/UIView+RFKit.h>
#import <RFKit/UIView+RFAnimate.h>

@interface RFSliderView ()
@property (strong, nonatomic) RFTimer *timer;
@end

@implementation RFSliderView
@dynamic totalPage;
RFInitializingRootForUIView

- (void)onInit {
    if (![self.collectionViewLayout isKindOfClass:[RFFullSizeCollectionViewFlowLayout class]]) {
        RFFullSizeCollectionViewFlowLayout *layout = [[RFFullSizeCollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionViewLayout = layout;
    }

    self.scrollsToTop = NO;
    self.clipsToBounds = YES;
    self.pagingEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
}

- (void)afterInit {
    [self _RFSliderView_setupBuildInGestureRecognizer];
}

- (void)setBounds:(CGRect)bounds {
    CGFloat oldWidth = self.width;
    CGFloat newWidth = CGRectGetWidth(bounds);
    NSUInteger page = self.currentPage;

    _dout_debug(@"Update bounds: %@", NSStringFromCGRect(bounds))
    [super setBounds:bounds];

    if (oldWidth == newWidth) return;
    if (self.isDragging) return;

    self.contentOffset = CGPointMake(page * newWidth, self.contentOffset.y);
}

- (CGSize)intrinsicContentSize {
    return self.collectionViewLayout.collectionViewContentSize;
}

#pragma mark - Page

- (NSInteger)currentPage {
    CGFloat width = CGRectGetWidth(self.bounds);
    if (width > 0) {
        return self.contentOffset.x / width + 0.5;
    }
    return -1;
}

- (void)setCurrentPage:(NSInteger)currentPage {
    [self setCurrentPage:currentPage animated:NO];
}

- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated {
    CGPoint offset = self.contentOffset;
    offset.x = currentPage * self.width;
    [self setContentOffset:offset animated:animated];
}

- (NSInteger)totalPage {
    CGFloat width = CGRectGetWidth(self.bounds);
    if (width > 0) {
        return self.contentSize.width / width;
    }
    return -1;
}

- (void)_RFSliderView_scrollToNextPage:(BOOL)allowInverted {
    if (self.totalPage < 2) return;
    NSInteger page = self.currentPage + 1;
    if (page < self.totalPage) {
        [self setCurrentPage:page animated:YES];
    }
    else if (allowInverted) {
        if (self.autoScrollAllowReverse) {
            // Keep scroll direction from left to right on last page.
            CATransition *scrollAnimation = [CATransition animation];
            scrollAnimation.duration = 0.35;
            scrollAnimation.type = kCATransitionPush;
            scrollAnimation.subtype = kCATransitionFromRight;
            [self.layer addAnimation:scrollAnimation forKey:nil];
            
            [self setCurrentPage:0 animated:NO];
        }
        else {
            self.autoScrollEnable = NO;
        }
    }
}

#pragma mark - Auto Scroll

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if (self.autoScrollEnable) {
        self.timer.suspended = !newWindow;
        NSInteger page = self.currentPage;
        if (page >= 0) {
            [self setCurrentPage:page animated:NO];
        }
    }
}

- (void)_RFSliderView_setupBuildInGestureRecognizer {
    __block UIPanGestureRecognizer *gr;
    [self.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIPanGestureRecognizer class]]) {
            gr = obj;
            *stop = YES;
        }
    }];

    [gr addTarget:self action:@selector(_RFSliderView_onPanInSelf:)];
}

- (void)_RFSliderView_onPanInSelf:(UIPanGestureRecognizer *)gestureRecognizer {
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.timer.suspended = YES;
            break;

        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            self.timer.suspended = NO;
            break;

        default:
            break;
    }
}

- (void)setAutoScrollEnable:(BOOL)autoScrollEnable {
    if (_autoScrollEnable != autoScrollEnable) {
        if (_autoScrollEnable) {
            if (self.timer) {
                [self.timer invalidate];
                self.timer = nil;
            }
        }
        _autoScrollEnable = autoScrollEnable;
        if (autoScrollEnable) {
            if (self.timer) {
                [self.timer scheduleInRunLoop:nil forMode:nil];
            }
            else {
                @weakify(self);
                RFTimer *tm = [RFTimer scheduledTimerWithTimeInterval:self.autoScrollTimeInterval repeats:YES fireBlock:^(RFTimer *timer, NSUInteger repeatCount) {
                    @strongify(self);
                    if (!self) {
                        _douts(@"Timer no self")
                        [timer invalidate];
                    }
                    [self _RFSliderView_scrollToNextPage:YES];
                }];
                self.timer = tm;
            }
        }
    }
}

- (void)setAutoScrollTimeInterval:(NSTimeInterval)autoScrollTimeInterval {
    _autoScrollTimeInterval = autoScrollTimeInterval;
    self.timer.timeInterval = autoScrollTimeInterval;
}

- (void)dealloc {
    self.autoScrollEnable = NO;
}

@end

@implementation RFSliderViewSimpleImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleSize;
}

@end
