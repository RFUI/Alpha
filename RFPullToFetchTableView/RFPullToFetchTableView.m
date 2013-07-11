
#import "RFPullToFetchTableView.h"
#import "UIView+RFAnimate.h"

static void *const RFPullToFetchTableViewKVOContext = (void *)&RFPullToFetchTableViewKVOContext;

@interface RFPullToFetchTableView ()
@property (readwrite, nonatomic) BOOL headerProcessing;
@property (readwrite, nonatomic) BOOL footerProcessing;

@property (weak, nonatomic) UIPanGestureRecognizer *buildInPanGestureRecognizer;
@property (strong, nonatomic) NSIndexPath *lastVisibleRowBeforeTriggeIndexPath;
@end

@implementation RFPullToFetchTableView

#pragma mark - RFInitializing
- (id)init {
    self = [super init];
    if (self) {
        [self onInit];
        [self performSelector:@selector(afterInit) withObject:self afterDelay:0];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self onInit];
        [self performSelector:@selector(afterInit) withObject:self afterDelay:0];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self onInit];
        [self performSelector:@selector(afterInit) withObject:self afterDelay:0];
    }
    return self;
}

- (void)onInit {
    self.headerStyle = RFAutoFetchTableContainerStyleStatic;
    self.footerStyle = RFAutoFetchTableContainerStyleStatic;
    
    self.headerFetchingEnabled = YES;
    self.footerFetchingEnabled = YES;
    self.shouldScrollToTopWhenHeaderEventTrigged = YES;
    self.shouldScrollToLastVisibleRowBeforeTriggeAfterFooterProccessFinished = YES;
}

- (void)afterInit {
    for (id gr in self.gestureRecognizers) {
        if ([gr isKindOfClass:[UIPanGestureRecognizer class]]) {
            self.buildInPanGestureRecognizer = gr;
        }
    }
    
    [self.buildInPanGestureRecognizer addObserver:self forKeyPath:@keypath(self.buildInPanGestureRecognizer, state) options:NSKeyValueObservingOptionNew context:RFPullToFetchTableViewKVOContext];
}

- (void)dealloc {
    [self.buildInPanGestureRecognizer removeObserver:self forKeyPath:@keypath(self.buildInPanGestureRecognizer, state) context:RFPullToFetchTableViewKVOContext];
    self.headerFetchingEnabled = NO;
    self.footerFetchingEnabled = NO;
}

#pragma mark - KVO
- (void)setHeaderFetchingEnabled:(BOOL)headerFetchingEnabled {
    if (_headerFetchingEnabled != headerFetchingEnabled) {
        [self willChangeValueForKey:@keypath(self, headerFetchingEnabled)];
        _headerFetchingEnabled = headerFetchingEnabled;
        
        if (headerFetchingEnabled) {
            [self addObserver:self forKeyPath:@keypath(self, distanceBetweenContentAndTop) options:NSKeyValueObservingOptionOld context:RFPullToFetchTableViewKVOContext];
        }
        else {
            [self removeObserver:self forKeyPath:@keypath(self, distanceBetweenContentAndTop) context:RFPullToFetchTableViewKVOContext];
            [self setHeaderContainerVisible:NO animated:NO];
        }
        [self didChangeValueForKey:@keypath(self, headerFetchingEnabled)];
    }
}

- (void)setFooterFetchingEnabled:(BOOL)footerFetchingEnabled {
    if (_footerFetchingEnabled != footerFetchingEnabled) {
        [self willChangeValueForKey:@keypath(self, footerFetchingEnabled)];
        _footerFetchingEnabled = footerFetchingEnabled;
        
        if (footerFetchingEnabled) {
            [self addObserver:self forKeyPath:@keypath(self, distanceBetweenContentAndBottom) options:NSKeyValueObservingOptionOld context:RFPullToFetchTableViewKVOContext];
        }
        else {
            [self removeObserver:self forKeyPath:@keypath(self, distanceBetweenContentAndBottom) context:RFPullToFetchTableViewKVOContext];
            [self setFooterContainerVisible:NO animated:NO];
        }
        [self didChangeValueForKey:@keypath(self, footerFetchingEnabled)];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context != RFPullToFetchTableViewKVOContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if (object == self) {
        if ([keyPath isEqualToString:@keypath(self, distanceBetweenContentAndTop)]) {
            if ([change[NSKeyValueChangeOldKey] floatValue] != self.distanceBetweenContentAndTop) {
                [self onDistanceBetweenContentAndTopChanged];
            }
            return;
        }
        
        if ([keyPath isEqualToString:@keypath(self, distanceBetweenContentAndBottom)]) {
            if ([change[NSKeyValueChangeOldKey] floatValue] != self.distanceBetweenContentAndBottom) {
                [self onDistanceBetweenContentAndBottomChanged];
            }
            return;
        }
    }
    
    if (object == self.buildInPanGestureRecognizer && [keyPath isEqualToString:@keypathClassInstance(UIPanGestureRecognizer, state)]) {
        [self onBuildInPanGestureRecognizerStateChanged];
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - Handel content distance change

- (void)onBuildInPanGestureRecognizerStateChanged {
    static CGFloat startOffset;
    
    switch (self.buildInPanGestureRecognizer.state) {
            
        case UIGestureRecognizerStateBegan:
            startOffset = self.contentOffset.y;
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            if (self.contentOffset.y < startOffset) {
                _douts(@"Drag down");
                if (self.headerFetchingEnabled && !self.isFetching && self.distanceBetweenContentAndTop > self.headerContainer.height) {
                    [self triggerHeaderProccess];
                }
            }
            else {
                _douts(@"Drag up");
                if (self.footerFetchingEnabled && !self.footerReachEnd && !self.isFetching && self.distanceBetweenContentAndBottom > self.footerContainer.height) {
                    [self triggerFooterProccess];
                }
            }
            break;
            
        case UIGestureRecognizerStatePossible:
        default:
            break;
    }
}

- (void)onDistanceBetweenContentAndTopChanged {
    _dout_float(self.distanceBetweenContentAndTop);

    BOOL isVisible = (self.distanceBetweenContentAndTop >= 0 && !self.footerProcessing);
    self.headerContainer.hidden = !isVisible;
    
    if (self.headerVisibleChangeBlock) {
        CGFloat dst = self.distanceBetweenContentAndTop;
        self.headerVisibleChangeBlock(isVisible, dst, (dst >= self.headerContainer.height), self.isHeaderProcessing);
    }
}

- (void)onDistanceBetweenContentAndBottomChanged {
    _dout_float(self.distanceBetweenContentAndBottom);
    
    BOOL isVisible = (self.distanceBetweenContentAndBottom > 0 && !self.headerProcessing);
    // 解决内容过少总是显示 footer 的问题
    if (!self.headerContainer.hidden && !self.footerProcessing && !self.footerReachEnd) {
        isVisible = NO;
    }
//    if (!(self.isDragging || self.isDecelerating) || self.footerProcessing) {
//        isVisible = NO;
//    }
    self.footerContainer.hidden = !isVisible;
    
    if (self.footerVisibleChangeBlock) {
        CGFloat dst = self.distanceBetweenContentAndBottom;
        self.footerVisibleChangeBlock(isVisible, dst, (dst >= self.footerContainer.height), self.isFooterProcessing, self.footerReachEnd);
    }
}

- (void)triggerHeaderProccess {
    _doutwork()
    if (self.headerProcessing) return;
    self.headerProcessing = YES;
    self.footerReachEnd = NO;
    
    if (self.headerProccessBlock) {
        self.headerProccessBlock();
    }
    
    // The proccess may finished immediately after process block executed.
    if (self.headerProcessing) {
        [self setHeaderContainerVisible:YES animated:YES];
        if (self.shouldScrollToTopWhenHeaderEventTrigged) {
            CGPoint conentOffset = self.contentOffset;
            conentOffset.y = -self.headerContainer.height;
            [self setContentOffset:conentOffset animated:YES];
        }
    }
}

- (void)triggerFooterProccess {
    _doutwork()
    if (self.footerProcessing) return;
    self.footerProcessing = YES;
    
    if (self.footerProccessBlock) {
        self.footerProccessBlock();
    }
    
    // The proccess may finished immediately after process block executed.
    if (self.footerProcessing) {
        [self setFooterContainerVisible:YES animated:YES];
        if (self.shouldScrollToLastVisibleRowBeforeTriggeAfterFooterProccessFinished) {
            self.lastVisibleRowBeforeTriggeIndexPath = [[self indexPathsForVisibleRows] lastObject];
        }
    }
}

- (void)headerProccessFinshed {
    if (!self.headerProcessing) return;
    
    self.headerProcessing = NO;
    [self setHeaderContainerVisible:NO animated:YES];
}

- (void)footerProccessFinshed {
    if (!self.footerProcessing) return;

    self.footerProcessing = NO;
    [self setFooterContainerVisible:NO animated:YES];
    if (self.shouldScrollToLastVisibleRowBeforeTriggeAfterFooterProccessFinished && self.lastVisibleRowBeforeTriggeIndexPath) {
        [self scrollToRowAtIndexPath:self.lastVisibleRowBeforeTriggeIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}


#pragma mark - Layout
- (void)layoutSubviews {
    [super layoutSubviews];

//    [UIView beginAnimations:@"RFGridViewLayoutAnimation" context:nil];
//    [UIView setAnimationDuration:0.1];
    
    if (self.headerContainer && !self.headerContainer.hidden) {
        switch (self.headerStyle) {
            case RFAutoFetchTableContainerStyleStatic:
                self.headerContainer.y = -self.headerContainer.height;
                break;
            case RFAutoFetchTableContainerStyleFloat:
                
                break;
                
            case RFAutoFetchTableContainerStyleFloatFixed:
                self.headerContainer.x = 0;
                break;
                
            case RFAutoFetchTableContainerStyleNone:
                self.headerContainer.hidden = YES;
                break;
        }
    }
    
    if (self.footerContainer && !self.footerContainer.hidden) {
        switch (self.footerStyle) {
            case RFAutoFetchTableContainerStyleFloatFixed:
                self.footerContainer.bottomMargin = 0;
                break;
                
            case RFAutoFetchTableContainerStyleStatic:
                self.footerContainer.y = self.contentSize.height;
                break;
                
            case RFAutoFetchTableContainerStyleFloat:
                if (self.footerContainer.bottomMargin > 0) {
                    self.footerContainer.bottomMargin = 0;
                }
                break;
                
            case RFAutoFetchTableContainerStyleNone:
                self.footerContainer.hidden = YES;
                break;
        }
    }
    
//    [UIView commitAnimations];
}

- (void)setHeaderContainerVisible:(BOOL)isVisible animated:(BOOL)animated {
    if (isVisible) {
        self.headerContainer.hidden = NO;
    }
    [UIView animateWithDuration:.2f delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animated:animated beforeAnimations:nil animations:^{
        switch (self.headerStyle) {
            case RFAutoFetchTableContainerStyleStatic: {
                UIEdgeInsets edge = self.contentInset;
                edge.top = (isVisible? self.headerContainer.height : 0);
                self.contentInset = edge;
                break;
            }
            case RFAutoFetchTableContainerStyleFloatFixed:
            case RFAutoFetchTableContainerStyleFloat:
            case RFAutoFetchTableContainerStyleNone:
                break;
        }
    } completion:^(BOOL finished) {
        self.headerContainer.hidden = !isVisible;
        [self onDistanceBetweenContentAndTopChanged];   // fix after finish fetching header not show. ugly
    }];
}

- (void)setFooterContainerVisible:(BOOL)isVisible animated:(BOOL)animated {
    if (isVisible) {
        self.footerContainer.hidden = NO;
    }
    [UIView animateWithDuration:.2f delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animated:animated beforeAnimations:nil animations:^{
        switch (self.footerStyle) {
            case RFAutoFetchTableContainerStyleStatic: {
                UIEdgeInsets edge = self.contentInset;
                edge.bottom = (isVisible? self.footerContainer.height : 0);
                self.contentInset = edge;
                break;
            }
            case RFAutoFetchTableContainerStyleFloatFixed:
            case RFAutoFetchTableContainerStyleFloat:
            case RFAutoFetchTableContainerStyleNone:
                break;
        }
    } completion:^(BOOL finished) {
        self.footerContainer.hidden = !isVisible;
        [self onDistanceBetweenContentAndTopChanged];   // fix after finish fetching header not show. ugly
    }];
}

#pragma mark - Other Status

- (BOOL)isFetching {
    return (self.headerProcessing || self.footerProcessing);
}

+ (NSSet *)keyPathsForValuesAffectingFetching {
    return [NSSet setWithObjects:@keypathClassInstance(RFPullToFetchTableView, headerProcessing), @keypathClassInstance(RFPullToFetchTableView, footerProcessing), nil];
}



@end
