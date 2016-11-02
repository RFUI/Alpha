
#import "RFSliderView.h"
#import "RFFullSizeCollectionViewFlowLayout.h"
#import "UIView+RFAnimate.h"
#import "RFTimer.h"

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
    self.pagingEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
}

- (void)afterInit {
    [self setupBuildInGestureRecognizer];
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
    return self.contentSize.width / self.width;
}

- (void)scrollToNextPage:(BOOL)allowInverted {
    NSInteger page = self.currentPage + 1;
    if (page < self.totalPage) {
        [self setCurrentPage:page animated:YES];
    }
    else {
        if (self.autoScrollAllowReverse) {
            // 由最后一页滑到第一页时使用动画，保证轮播方向的一致性。
            CATransition *scrollAnimation =[CATransition animation];
            scrollAnimation.duration = 0.35;
            scrollAnimation.type = kCATransitionPush;
            scrollAnimation.subtype = kCATransitionFromRight;
            [self.layer addAnimation:scrollAnimation forKey:nil];
            
            [self setCurrentPage:0 animated:NO];
        }
        else {
            [self invalidateAutoScrollTimer];
        }
    }
}

#pragma mark - Auto Scroll

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if (self.autoScrollEnable) {
        self.timer.suspended = !newWindow;
    }
}

- (void)setupBuildInGestureRecognizer {
    __block UIPanGestureRecognizer *gr;
    [self.gestureRecognizers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIPanGestureRecognizer class]]) {
            gr = obj;
            *stop = YES;
        }
    }];

    [gr addTarget:self action:@selector(onPanInSelf:)];
}

- (void)onPanInSelf:(UIPanGestureRecognizer *)gestureRecognizer {
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
        _autoScrollEnable = autoScrollEnable;

        if (!autoScrollEnable) {
            [self invalidateAutoScrollTimer];
            return;
        }

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

                [self scrollToNextPage:YES];
            }];
            self.timer = tm;
        }
    }
}

- (void)invalidateAutoScrollTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)setAutoScrollTimeInterval:(NSTimeInterval)autoScrollTimeInterval {
    _autoScrollTimeInterval = autoScrollTimeInterval;
    self.timer.timeInterval = autoScrollTimeInterval;
}

- (void)dealloc {
    [self invalidateAutoScrollTimer];
}

@end

@implementation RFSliderViewSimpleImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleSize;
}

@end
