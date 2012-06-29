#import "RFGridView.h"

CGSize DEFAULT_RFGridViewCellSize = {20, 20};

@implementation RFGridView
@synthesize cellSize, cellMargin, containerPadding;
@synthesize padding;
@synthesize cellLayoutAlignment;
@synthesize layoutOrientation;
@synthesize layoutAnimated;
@synthesize container = _container;

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; contentOffset:%@; contentSize:%@; layoutOrientation:%@; cellSize:%@>",
            NSStringFromClass([self class]),
            self,
            NSStringFromCGPoint(self.contentOffset),
            NSStringFromCGSize(self.contentSize),
            ((self.layoutOrientation == RFUIOrientationHorizontal)? @"RFUIOrientationHorizontal": @"RFUIOrientationVertical"),
            NSStringFromCGSize(self.cellSize)];
}

- (void)setupView {
	self.clipsToBounds = YES;
}

- (void)applyDefaultSettings {    
    if (self.container == nil) {
        _douts(@"new container creat")
        self.container = [[RFGridViewCellContainer alloc] initWithFrame:self.bounds];
        _container.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_container];
        _container.backgroundColor = [UIColor clearColor];
        
        self.padding = RFPaddingMake(0, 0, 0, 0);
    }
    self.container.master = self;
    
    self.cellSize = DEFAULT_RFGridViewCellSize;
    self.layoutOrientation = RFUIOrientationVertical;
    self.layoutAnimated = YES;
}

- (id)initWithFrame:(CGRect)aRect {
	self = [super initWithFrame:aRect];
	if (self) {
		[self setupView];
        [self applyDefaultSettings];
	}
	return self;
}

- (void)awakeFromNib {
    if (RFPaddingEqualToPadding(self.padding, RFPaddingZero) && self.container != nil) {
        self.padding = RFPaddingMakeWithRects(self.bounds, self.container.frame);
    }
    [self applyDefaultSettings];
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
@synthesize master = _master;

- (void)layoutSubviews {
    _doutwork()
    BOOL _layoutAnimated = self.master.layoutAnimated;
    if (_layoutAnimated) {
        [UIView beginAnimations:@"RFGridViewLayoutAnimation" context:nil];
        [UIView setAnimationDuration:0.5];
    }
    
    RFGridView *master = self.master;
    _douto(master)
    _dout_point(master.contentOffset)
    
    CGFloat wCell = master.cellSize.width;
    CGFloat hCell = master.cellSize.height;
    
    if (!!!(wCell > 0 && hCell > 0)) {
        NSLog(@"Warning: RFGridView >> invaild cell size, use default size instead.");
        wCell = DEFAULT_RFGridViewCellSize.width;
        hCell = DEFAULT_RFGridViewCellSize.height;
    }
    
    RFMargin margin = master.cellMargin;
    RFPadding padding = master.containerPadding;
    
    // Cell margin may bigger than container padding
    RFPadding trueEdge = RFPaddingMake(MAX(margin.top, padding.top), MAX(margin.right, padding.right), MAX(margin.bottom, padding.bottom), MAX(margin.left, padding.left));
    
    CGSize masterSize = master.bounds.size;
    _dout_rect(master.bounds);
    CGRect containerFrameWillBe = CGRectMake(master.padding.left, master.padding.top, masterSize.width-master.padding.left-master.padding.right, masterSize.height-master.padding.top-master.padding.bottom);
    _dout_rect(containerFrameWillBe);
    
    CGPoint offset = self.master.contentOffset;
    
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
    if (self.master.layoutOrientation == RFUIOrientationVertical) {
        _douts(@"is RFUIOrientationVertical")
        
        NSUInteger nWidth = (contentBox.size.width + xMMargin) / (wCell + xMMargin);
        if (nWidth == 0) {
            nWidth = 1;
        }
        
        containerFrameWillBe.size.height = ceilf((float)nCount/(float)nWidth)*(hCell+yMMargin)-yMMargin + trueEdge.top + trueEdge.bottom;
        self.frame = containerFrameWillBe;
        
        basePoint.x += (contentBox.size.width - (nWidth-1)*(wCell+xMMargin) - wCell)/2;
        
        for (int i = 0; i < nCount; i++) {
            tmp_view = [self.subviews objectAtIndex:i];
            ixCol = i%nWidth;
            ixRow = i/nWidth;
            tmp_view.frame = CGRectMake(basePoint.x + ixCol*(wCell+xMMargin), basePoint.y + ixRow*(hCell+yMMargin), wCell, hCell);
            _dout_rect(tmp_view.frame)
        }
        
        _dout_rect(self.frame)
        self.master.contentSize = CGSizeMake(CGRectGetMaxX(self.frame), CGRectGetMaxY(self.frame) + master.padding.bottom);
        offset.y = offset.y * lastRowCount / nWidth;
        lastRowCount = nWidth;
    }
    else {
        NSUInteger nHeight = (contentBox.size.height + yMMargin) / (hCell + yMMargin);
        if (nHeight == 0) nHeight = 1;
        
        _dout_rect(master.bounds)
        containerFrameWillBe.size.width = ceilf((float)nCount/(float)nHeight)*(wCell+xMMargin)-xMMargin + trueEdge.left + trueEdge.right;
        self.frame = containerFrameWillBe;
        _dout_rect(self.frame)
        
        basePoint.y += (contentBox.size.height - (nHeight-1)*(hCell+yMMargin) - hCell)/2;
        
        for (int i = 0; i < nCount; i++) {
            tmp_view = [self.subviews objectAtIndex:i];
            ixRow = i%nHeight;
            ixCol = i/nHeight;
            tmp_view.frame = CGRectMake(basePoint.x + ixCol*(wCell+xMMargin), basePoint.y + ixRow*(hCell+yMMargin), wCell, hCell);
            _dout_rect(tmp_view.frame)
        }

        master.contentSize = CGSizeMake(CGRectGetMaxX(self.frame) + master.padding.right, CGRectGetMaxY(self.frame));
        _douto(self.master)
        offset.x = offset.x * lastRowCount / nHeight;
        lastRowCount = nHeight;
    }
    master.contentOffset = offset;
    _dout_point(master.contentOffset);
    
    if (_layoutAnimated) {
        [UIView commitAnimations];
    }
	[super layoutSubviews];
}

@end
