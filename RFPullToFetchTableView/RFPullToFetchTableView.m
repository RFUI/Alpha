
#import "RFPullToFetchTableView.h"

static void *const RFPullToFetchTableViewKVOContext = (void *)&RFPullToFetchTableViewKVOContext;

@interface RFPullToFetchTableView ()
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
}

- (void)afterInit {
    [self setupObserversForScrollChange];
}

- (void)dealloc {
    [self uninstallObserversForScrollChange];
}

- (void)setupObserversForScrollChange {
    [self addObserver:self forKeyPath:@keypath(self, distanceBetweenContentAndTop) options:NSKeyValueObservingOptionNew context:RFPullToFetchTableViewKVOContext];
    [self addObserver:self forKeyPath:@keypath(self, distanceBetweenContentAndBottom) options:NSKeyValueObservingOptionNew context:RFPullToFetchTableViewKVOContext];
}

- (void)uninstallObserversForScrollChange {
    [self removeObserver:self forKeyPath:@keypath(self, distanceBetweenContentAndBottom) context:RFPullToFetchTableViewKVOContext];
    [self removeObserver:self forKeyPath:@keypath(self, distanceBetweenContentAndTop) context:RFPullToFetchTableViewKVOContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context != RFPullToFetchTableViewKVOContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if (object == self && [keyPath isEqualToString:@keypath(self, distanceBetweenContentAndTop)]) {
        [self onDistanceBetweenContentAndTopChanged];
        return;
    }
    
    if (object == self && [keyPath isEqualToString:@keypath(self, distanceBetweenContentAndBottom)]) {
        [self onDistanceBetweenContentAndBottomChanged];
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

- (void)onDistanceBetweenContentAndTopChanged {
    if (!self.isHeaderFetchingEnabled) return;
    
    if (self.isDecelerating && self.headerContainer.frame.size.height && !self.headerProcessing) {
        [self onHeaderEventTriggered];
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
    self.headerProcessing = YES;
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
