#import "RFGridView.h"

@implementation RFGridView
RFInitializingRootForUIView

- (void)onInit {
    self.clipsToBounds = YES;
    self.cellSize = (CGSize){20, 20};
    self.layoutOrientation = RFUIOrientationVertical;
    self.padding = RFEdgeMake(0, 0, 0, 0);
}

- (void)afterInit {
}

- (void)awakeFromNib {
    [super awakeFromNib];
    if (RFEdgeEqualToEdge(self.padding, RFEdgeZero) && self.container != nil) {
        self.padding = RFEdgeMakeWithRects(self.bounds, self.container.frame);
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; contentOffset:%@; contentSize:%@; layoutOrientation:%@; cellSize:%@>",
            NSStringFromClass([self class]),
            (void *)self,
            NSStringFromCGPoint(self.contentOffset),
            NSStringFromCGSize(self.contentSize),
            ((self.layoutOrientation == RFUIOrientationHorizontal)? @"RFUIOrientationHorizontal": @"RFUIOrientationVertical"),
            NSStringFromCGSize(self.cellSize)];
}

@synthesize container = _container;

- (RFGridViewCellContainer *)container {
    if (_container) return _container;
    _container = [[RFGridViewCellContainer alloc] initWithFrame:self.bounds];
    _container.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self addSubview:_container];
    return _container;
}

- (void)setContainer:(RFGridViewCellContainer *)container {
    _container = container;
    container.master = self;
}

- (void)setNeedsLayout {
    [self.container setNeedsLayout];
    [super setNeedsLayout];
}

@end


#pragma mark - RFGridViewCellContainer

@interface RFGridViewCellContainer () {
    NSUInteger lastRowCount;
}
@end

@implementation RFGridViewCellContainer

- (void)layoutSubviews {
    RFGridView *master = self.master;
    if (!master) {
        [super layoutSubviews];
        return;
    }

    BOOL _layoutAnimated = master.layoutAnimated;
    if (_layoutAnimated) {
        [UIView beginAnimations:@"RFGridViewLayoutAnimation" context:nil];
        [UIView setAnimationDuration:0.5];
    }

    CGFloat wCell = master.cellSize.width;
    CGFloat hCell = master.cellSize.height;
    
    if (!!!(wCell > 0 && hCell > 0)) {
        dout_warning(@"RFGridView >> invaild cell size, use default size instead.")
        wCell = 20;
        hCell = 20;
    }
    
    RFEdge margin = master.cellMargin;
    RFEdge padding = master.containerPadding;
    
    // Cell margin may bigger than container padding
    RFEdge trueEdge = RFEdgeMake(MAX(margin.top, padding.top), MAX(margin.right, padding.right), MAX(margin.bottom, padding.bottom), MAX(margin.left, padding.left));
    
    CGSize masterSize = master.bounds.size;
    CGRect containerFrameWillBe = CGRectMake(master.padding.left, master.padding.top, masterSize.width-master.padding.left-master.padding.right, masterSize.height-master.padding.top-master.padding.bottom);
    
    CGPoint offset = master.contentOffset;
    
    // For cell layout not box model content
    // Cell 本身能处的范围，不含边距
    CGRect contentBox = CGRectMake(trueEdge.left, trueEdge.top, containerFrameWillBe.size.width-trueEdge.left-trueEdge.right, containerFrameWillBe.size.height-trueEdge.top-trueEdge.bottom);
    CGPoint basePoint = contentBox.origin;
    
    CGFloat xMMargin = MAX(margin.left, margin.right);
    CGFloat yMMargin = MAX(margin.bottom, margin.top);
    
    NSUInteger nCount = self.subviews.count;
    NSUInteger ixCol = 0;
    NSUInteger ixRow = 0;
    
    UIView *tmp_view;
    if (master.layoutOrientation == RFUIOrientationVertical) {
        NSUInteger nWidth = (contentBox.size.width + xMMargin) / (wCell + xMMargin);
        if (nWidth == 0) {
            nWidth = 1;
        }
        
        containerFrameWillBe.size.height = ceilf((float)nCount/(float)nWidth)*(hCell+yMMargin)-yMMargin + trueEdge.top + trueEdge.bottom;
        self.frame = containerFrameWillBe;
        
        basePoint.x += (contentBox.size.width - (nWidth-1)*(wCell+xMMargin) - wCell)/2;
        
        for (NSUInteger i = 0; i < nCount; i++) {
            tmp_view = [self.subviews objectAtIndex:i];
            ixCol = i%nWidth;
            ixRow = i/nWidth;
            tmp_view.frame = CGRectMake(basePoint.x + ixCol*(wCell+xMMargin), basePoint.y + ixRow*(hCell+yMMargin), wCell, hCell);
        }

        master.contentSize = CGSizeMake(CGRectGetMaxX(self.frame), CGRectGetMaxY(self.frame) + master.padding.bottom);
        offset.y = offset.y * lastRowCount / nWidth;
        lastRowCount = nWidth;
    }
    else {
        NSUInteger nHeight = (contentBox.size.height + yMMargin) / (hCell + yMMargin);
        if (nHeight == 0) nHeight = 1;

        containerFrameWillBe.size.width = ceilf((float)nCount/(float)nHeight)*(wCell+xMMargin)-xMMargin + trueEdge.left + trueEdge.right;
        self.frame = containerFrameWillBe;
        
        basePoint.y += (contentBox.size.height - (nHeight-1)*(hCell+yMMargin) - hCell)/2;
        
        for (NSUInteger i = 0; i < nCount; i++) {
            tmp_view = [self.subviews objectAtIndex:i];
            ixRow = i%nHeight;
            ixCol = i/nHeight;
            tmp_view.frame = CGRectMake(basePoint.x + ixCol*(wCell+xMMargin), basePoint.y + ixRow*(hCell+yMMargin), wCell, hCell);
        }

        master.contentSize = CGSizeMake(CGRectGetMaxX(self.frame) + master.padding.right, CGRectGetMaxY(self.frame));
        offset.x = offset.x * lastRowCount / nHeight;
        lastRowCount = nHeight;
    }
    master.contentOffset = offset;
    
    if (_layoutAnimated) {
        [UIView commitAnimations];
    }
	[super layoutSubviews];
}

@end
