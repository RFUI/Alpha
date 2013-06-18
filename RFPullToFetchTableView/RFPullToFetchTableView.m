
#import "RFPullToFetchTableView.h"
#import "UIView+RFAnimate.h"

static void *const RFPullToFetchTableViewKVOContext = (void *)&RFPullToFetchTableViewKVOContext;

@interface RFPullToFetchTableView ()
@property (readwrite, nonatomic) BOOL headerProcessing;
@property (readwrite, nonatomic) BOOL footerProcessing;

@property (weak, nonatomic) UIPanGestureRecognizer *buildInPanGestureRecognizer;
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
    self.footerStyle = RFAutoFetchTableContainerStyleStatic;
    
    self.headerFetchingEnabled = YES;
    self.footerFetchingEnabled = YES;
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
// TODO: 结束时需要额外清理
- (void)setHeaderFetchingEnabled:(BOOL)headerFetchingEnabled {
    if (_headerFetchingEnabled != headerFetchingEnabled) {
        [self willChangeValueForKey:@keypath(self, headerFetchingEnabled)];
        _headerFetchingEnabled = headerFetchingEnabled;
        
        if (headerFetchingEnabled) {
            [self addObserver:self forKeyPath:@keypath(self, distanceBetweenContentAndTop) options:NSKeyValueObservingOptionNew context:RFPullToFetchTableViewKVOContext];
        }
        else {
            [self removeObserver:self forKeyPath:@keypath(self, distanceBetweenContentAndBottom) context:RFPullToFetchTableViewKVOContext];
        }
        [self didChangeValueForKey:@keypath(self, headerFetchingEnabled)];
    }
}

- (void)setFooterFetchingEnabled:(BOOL)footerFetchingEnabled {
    if (_footerFetchingEnabled != footerFetchingEnabled) {
        [self willChangeValueForKey:@keypath(self, footerFetchingEnabled)];
        _footerFetchingEnabled = footerFetchingEnabled;
        
        if (footerFetchingEnabled) {
            [self addObserver:self forKeyPath:@keypath(self, distanceBetweenContentAndBottom) options:NSKeyValueObservingOptionNew context:RFPullToFetchTableViewKVOContext];
        }
        else {
            [self removeObserver:self forKeyPath:@keypath(self, distanceBetweenContentAndTop) context:RFPullToFetchTableViewKVOContext];
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
            [self onDistanceBetweenContentAndTopChanged];
            return;
        }
        
        if ([keyPath isEqualToString:@keypath(self, distanceBetweenContentAndBottom)]) {
            [self onDistanceBetweenContentAndBottomChanged];
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
                    [self onHeaderEventTriggered];
                }
            }
            else {
                _douts(@"Drag up");
                if (self.footerFetchingEnabled && !self.isFetching && self.distanceBetweenContentAndBottom > self.footerContainer.height) {
                    [self onFooterEventTriggered];
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

    self.headerContainer.hidden = (self.distanceBetweenContentAndTop < 0);
}

- (void)onDistanceBetweenContentAndBottomChanged {
    _dout_float(self.distanceBetweenContentAndBottom);
    self.footerContainer.hidden = (self.distanceBetweenContentAndBottom < 0);
}

- (void)onHeaderEventTriggered {
    doutwork()
    if (self.headerProccessBlock) {
        self.headerProccessBlock();
        self.headerProcessing = YES;
    }
}

- (void)onFooterEventTriggered {
    doutwork()    
    if (self.footerProccessBlock) {
        self.footerProccessBlock();
        self.footerProcessing = YES;
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
}


#pragma mark - Layout
- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.footerContainer.hidden == NO) {
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
                
            default:
                break;
        }
    }
}

- (void)setHeaderContainerVisible:(BOOL)isVisible animated:(BOOL)animated {
    // TODO: layout
    self.headerContainer.hidden = !isVisible;
    
//    [self setNeedsLayout];
}

- (void)setFooterContainerVisible:(BOOL)isVisible animated:(BOOL)animated {
    self.footerContainer.hidden = !isVisible;
//    
//    if (self.footerStyle == RFAutoFetchTableContainerStyleStatic) {
//        [self setContentBottomInset:(isVisible? self.footerContainer.bounds.size.height : 0) animated:animated];
//    }
//    
//    [self setNeedsLayout];
}

#pragma mark - Tool
- (void)setContentBottomInset:(CGFloat)bottom animated:(BOOL)animated {
    [UIView animateWithDuration:.2f delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animated:animated beforeAnimations:nil animations:^{
        UIEdgeInsets edge = self.contentInset;
        self.contentInset = UIEdgeInsetsMake(edge.top, edge.left, bottom, edge.right);
    } completion:nil];
}

- (void)setContentTopInset:(CGFloat)top animated:(BOOL)animated {
    [UIView animateWithDuration:.2f delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animated:animated beforeAnimations:nil animations:^{
        UIEdgeInsets edge = self.contentInset;
        self.contentInset = UIEdgeInsetsMake(top, edge.left, edge.bottom, edge.right);
    } completion:nil];
}

#pragma mark - Other Status
- (BOOL)isFetching {
    return (self.headerProcessing || self.footerProcessing);
}

+ (NSSet *)keyPathsForValuesAffectingFetching {
    return [NSSet setWithObjects:@keypathClassInstance(RFPullToFetchTableView, headerProcessing), @keypathClassInstance(RFPullToFetchTableView, footerProcessing), nil];
}



@end
