
#import "RFPullToFetchTableView.h"

@interface RFPullToFetchTableView ()
@property (assign, nonatomic) CGFloat distanceBetweenContentAndBottom;
@end

@implementation RFPullToFetchTableView
#pragma mark - @property
- (CGFloat)distanceBetweenContentAndBottom {
    static CGFloat lastDistance;
    CGFloat ctDistance = self.bounds.size.height + self.contentOffset.y - self.contentSize.height;
    if (lastDistance != ctDistance) {
        lastDistance = ctDistance;
        [self onDistanceBetweenContentAndBottomChanged];
    }
    return ctDistance;
}

#pragma mark -

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.footerStyle = RFAutoFetchTableContainerStyleStatic;
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    if (newWindow) {
        [self setupObserversForScrollChange];
    }
    else {
        [self uninstallObserversForScrollChange];
    }
}

- (void)setupObserversForScrollChange {
    [self addObserver:self forKeyPath:@keypath(self, contentSize) options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@keypath(self, contentOffset) options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@keypath(self, bounds) options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)uninstallObserversForScrollChange {
    [self removeObserver:self forKeyPath:@keypath(self, contentSize)];
    [self removeObserver:self forKeyPath:@keypath(self, contentOffset)];
    [self removeObserver:self forKeyPath:@keypath(self, bounds)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self && ([keyPath isEqualToString:@keypath(self, contentOffset)] || [keyPath isEqualToString:@keypath(self, contentSize)] || [keyPath isEqualToString:@keypath(self, bounds)])) {
        [self distanceBetweenContentAndBottom];
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.distanceBetweenContentAndBottom > self.footerContainer.frame.size.height && self.footerStyle != RFAutoFetchTableContainerStyleStatic) {
        
    }
    else {
        [self.footerContainer moveToX:RFMathNotChange Y:self.contentSize.height];
    }
}

- (void)onDistanceBetweenContentAndBottomChanged {
    _dout_float(self.distanceBetweenContentAndBottom);
    if (!self.isFooterFetchingEnabled) return;
    
    if (self.isDecelerating && self.distanceBetweenContentAndBottom > self.footerContainer.frame.size.height && !self.footerProcessing) {
        [self onFooterEventTriggered];
    }
}

- (void)onFooterEventTriggered {
    self.footerProcessing = YES;
    doutwork()
    
    if (self.footerStyle == RFAutoFetchTableContainerStyleStatic) {
        [self setFooterContainerVisible:YES animated:YES];
    }
    
    if (self.footerProccessBlock) {
        self.footerProccessBlock();
    }
}

- (void)onFooterProccessFinshed {
    self.footerProcessing = NO;
    [self setFooterContainerVisible:NO animated:YES];
}

- (void)onHeaderEventTriggered {
    doutwork()
}

- (void)setFooterContainerVisible:(BOOL)isVisible animated:(BOOL)animated {
    if (self.footerStyle == RFAutoFetchTableContainerStyleStatic) {
        [self setContentBottomInset:(isVisible? self.footerContainer.bounds.size.height : 0) animated:animated];
    }
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

@end
