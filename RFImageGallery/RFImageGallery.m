
#import "RFImageGallery.h"

@interface RFImageGallery () {
    /// 滚动一页超过百分之多少时认为翻页，这可以避免在硬分界出现的抖动，默认80%
    CGFloat pageChangeTolerance;
    
    BOOL isFastMoving;
}
@property (assign, nonatomic) NSUInteger imageCountCached;
@property (assign, nonatomic) CGFloat cellWidthCached;
@end

@interface RFImageGalleryScrollContainer ()

- (void)layoutCells;
- (void)layoutExchangeCellToLeft;
- (void)layoutExchangeCellToRight;
@end

@interface RFImageGalleryCell ()
@end


@implementation RFImageGallery

#pragma mark -
- (RFImageGallery *)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setup];
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)setup {
    pageChangeTolerance = 0.8;
    _index = 0;
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if (newWindow) {
        [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:self forKeyPath:@"index" options:NSKeyValueObservingOptionNew context:NULL];
        @weakify(self);
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            @strongify(self);
            _douts(@"dispatch_once");
            _dout_rect(self.frame)
            self.cellWidthCached = self.frame.size.width;
            
            if (self.scrollContainer == nil) {
                self.scrollContainer = [[RFImageGalleryScrollContainer alloc] initWithMaster:self];
                self.scrollContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
                [self addSubview:self.scrollContainer];
            }
            
            [self reloadData];
        });
    }
    else {
        [self removeObserver:self forKeyPath:@"contentOffset"];
        [self removeObserver:self forKeyPath:@"frame"];
        [self removeObserver:self forKeyPath:@"index"];
    }
}

- (void)dealloc {
    doutwork()
}

/// 初始化时会调用
- (void)reloadData {
    _doutwork()
    if (![self checkDateSource]) return;
    _imageCountCached = [self.dataSource numberOfImageInGallery:self];
    _cellWidthCached = self.frame.size.width;
    
    [self scrollToIndex:0 animated:NO forced:YES];
}

#pragma mark 滑动方法
- (void)scrollToIndex:(NSUInteger)toIndex animated:(BOOL)animated {
    [self scrollToIndex:toIndex animated:animated forced:NO];
}

- (void)scrollToIndex:(NSUInteger)toIndex animated:(BOOL)animated forced:(BOOL)forced {
    NSAssert(_cellWidthCached > 0, @"Cell宽啥时候变成0的呢？");
    if (_imageCountCached == 0) {
        return;
    }
    
    // 非强制，检查重复性
    if (!forced) {
        if (self.index == toIndex) return;
    }
    
    if (toIndex == NSUIntegerMax) toIndex = 0;
    if (toIndex >= _imageCountCached) {
        [self scrollToIndex:(_imageCountCached-1) animated:animated];
        return;
    }
    
    if (animated) {
        isFastMoving = YES;
        [self setContentOffset:CGPointMake(_cellWidthCached*toIndex, 0) animated:YES];
    }
    else {
        [self setScrollContainerFrameForIndex:toIndex];
        
        if (toIndex < _index) [self.scrollContainer layoutExchangeCellToLeft];
        if (toIndex > _index) [self.scrollContainer layoutExchangeCellToRight];

        [self setupCellForIndex:toIndex];
    }
    _index = toIndex;
}

- (void)setScrollContainerFrameForIndex:(NSUInteger)toIndex {
    NSAssert(_cellWidthCached > 0, @"");
//    NSAssert(!CGRectEqualToRect(self.scrollContainer.lCell.frame, self.scrollContainer.rCell.frame) , @"");
    
    if (toIndex == 0) {
        self.scrollContainer.frame = CGRectMake(-_cellWidthCached, 0, _cellWidthCached*3, self.frame.size.height);
//        [self.scrollContainer moveToX:-_cellWidthCached Y:RFMathNotChange];
    }
    else if (toIndex == _imageCountCached) {
        self.scrollContainer.frame = CGRectMake(toIndex*_cellWidthCached, 0, _cellWidthCached*3, self.frame.size.height);

//        [self.scrollContainer moveToX:toIndex*_cellWidthCached Y:RFMathNotChange];
    }
    else {
        self.scrollContainer.frame = CGRectMake((toIndex-1)*_cellWidthCached, 0, _cellWidthCached*3, self.frame.size.height);

//        [self.scrollContainer moveToX:(toIndex-1)*_cellWidthCached Y:RFMathNotChange];
    }
//    NSAssert(!CGRectEqualToRect(self.scrollContainer.lCell.frame, self.scrollContainer.rCell.frame) , @"");
}

/// 当index改变时调整图像
- (void)setupCellForIndex:(NSUInteger)index {
    _doutwork()
    [self.scrollContainer.lCell setImage:[self imageForIndex:index-1]];
    [self.scrollContainer.mCell setImage:[self imageForIndex:index]];
    [self.scrollContainer.rCell setImage:[self imageForIndex:index+1]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        // 仅当拖拽
        if (self.isDragging || isFastMoving) {
            if (_cellWidthCached == 0) return;
            
            CGFloat pageDiff = self.contentOffset.x/_cellWidthCached - _index;
            //            dout_float(self.contentOffset.x)
            //            _dout_float(pageDiff)
            //            dout_int(_index)
            //            dout_float(_cellWidthCached)
            //            dout_rect(self.scrollContainer.frame)
            //            dout_size(self.contentSize)
            //            douto(self.scrollContainer.subviews)
            
            if (ABS(pageDiff) > pageChangeTolerance) {
                if (pageDiff > 0) {
                    [self scrollToIndex:(_index+1) animated:NO];
                }
                if (pageDiff < 0) {
                    [self scrollToIndex:(_index-1) animated:NO];
                }
            }
            
            NSAssert(_index >= 0, @"");
        }
        return;
    }
    
    if ([keyPath isEqualToString:@"frame"]) {
        CGRect frame = self.frame;
        _douts(@"KVO : frame")
        _dout_rect(frame);
        if (frame.size.width > 0) {
            _cellWidthCached = frame.size.width;
            _dout_float(_cellWidthCached)
            
            self.contentSize = CGSizeMake(_imageCountCached*_cellWidthCached, 0);
            [self setContentOffset:CGPointMake(_index*_cellWidthCached, 0) animated:NO];
            [self setScrollContainerFrameForIndex:_index];
//            [self.scrollContainer layoutCells];
        }
        return;
        
    }
    
    if ([keyPath isEqualToString:@"index"]) {
        [self scrollToIndex:self.index animated:NO];
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - tool
/// 带边界检查的返回
- (UIImage *)imageForIndex:(NSUInteger)index {
    if (index < _imageCountCached && self.dataSource && [self.dataSource respondsToSelector:@selector(imageGallery:imageAtIndex:)]) {
        return [self.dataSource imageGallery:self imageAtIndex:index];
    }
    return nil;
}

- (BOOL)checkDateSource {
    if (self.dataSource == nil) return NO;
    
    if (![self.dataSource respondsToSelector:@selector(numberOfImageInGallery:)]
        || ![self.dataSource respondsToSelector:@selector(imageGallery:imageAtIndex:)]) {
        dout_error(@"dataSource must confirm RFImageGalleryDataSource protocol.")
        return NO;
    }
    
    return YES;
}

@end

#pragma mark - RFImageGalleryScrollContainer
@implementation RFImageGalleryScrollContainer

- (id)initWithMaster:(RFImageGallery *)master {
    CGRect frame = master.bounds;
    frame.size.width = frame.size.width*3;
    
    self = [super initWithFrame:frame];
    if (self) {
        if (RFUIDebugEnableRandomBackgroundColor) {
            self.backgroundColor = [UIColor colorWithRGBHex:0xFFFFFF alpha:0.5];
        }
        
        [self setupCellFromNib:NO];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupCellFromNib:YES];
}

- (void)setupCellFromNib:(BOOL)isLoadFromNib {
    CGRect frame = self.bounds;
    CGFloat wCell = frame.size.width/3;
    CGFloat hCell = frame.size.height;
    
    if (!self.lCell) {
        self.lCell = [[RFImageGalleryCell alloc] initWithFrame:CGRectMake(0, 0, wCell, hCell)];
        [self addSubview:_lCell];
    }
    if (!self.mCell) {
        self.mCell = [[RFImageGalleryCell alloc] initWithFrame:CGRectMake(wCell, 0, wCell, hCell)];
        [self addSubview:_mCell];
    }
    if (!self.rCell) {
        self.rCell = [[RFImageGalleryCell alloc] initWithFrame:CGRectMake(wCell*2, 0, wCell, hCell)];
        [self addSubview:_rCell];
    }
    
    if (!isLoadFromNib) {
        if (RFUIDebugEnableRandomBackgroundColor) {
            _lCell.backgroundColor = [UIColor randColorWithAlpha:.5];
            _mCell.backgroundColor = [UIColor randColorWithAlpha:.5];
            _rCell.backgroundColor = [UIColor randColorWithAlpha:.5];
        }
        
        UIViewAutoresizing mask = (UIViewAutoresizing)(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);
        _lCell.autoresizingMask = mask;
        _mCell.autoresizingMask = mask;
        _rCell.autoresizingMask = mask;
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    _douto(newSuperview)
    CGRect frame = newSuperview.bounds;
    frame.size.width = frame.size.width*3;
    self.frame = frame;
}

- (void)layoutCells {
    NSAssert(self.bounds.size.width > 0, @"");
    _dout_rect(self.bounds)
    _dout_rect(self.frame)
    CGRect frame = self.bounds;
    CGFloat cellWidth = frame.size.width/3;
    CGFloat cellHeight = frame.size.height;
    
    self.lCell.frame = CGRectMake(0, 0, cellWidth, cellHeight);
    self.mCell.frame = CGRectMake(cellWidth, 0, cellWidth, cellHeight);
    self.rCell.frame = CGRectMake(cellWidth*2, 0, cellWidth, cellHeight);
    _douto(self.subviews)
}

- (void)layoutExchangeCellToLeft {
    __strong RFImageGalleryCell *tmpCell = self.mCell;
    self.mCell = self.lCell;
    self.lCell = self.rCell;
    self.rCell = tmpCell;
    
    CGRect tmpFrame = self.mCell.frame;
    self.mCell.frame = self.rCell.frame;
    self.rCell.frame = self.lCell.frame;
    self.lCell.frame = tmpFrame;
}
- (void)layoutExchangeCellToRight {
    __strong RFImageGalleryCell *tmpCell = self.mCell;
    self.mCell = self.rCell;
    self.rCell = self.lCell;
    self.lCell = tmpCell;
    
    CGRect tmpFrame = self.mCell.frame;
    self.mCell.frame = self.lCell.frame;
    self.lCell.frame = self.rCell.frame;
    self.rCell.frame = tmpFrame;
}

@end


@implementation RFImageGalleryCell

- (RFImageGalleryCell *)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.frame];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_imageView resizeOption:RFViewResizeOptionFill];
        self.minimumZoomScale = 0.5;
        self.maximumZoomScale = 2.0;
        self.delegate = self;
        
        self.delaysContentTouches = YES;
        self.contentSize = self.bounds.size;
        _dout_size(self.contentSize)
        _douts(@"RFImageGalleryCell init end")
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if (newWindow) {
        [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
    }
    else {
        [self removeObserver:self forKeyPath:@"frame"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"frame"]) {
        self.contentSize = CGSizeScaled(self.frame.size, self.zoomScale);
//        douts(@"KVO : frame")
//        dout_rect(frame);
//        if (frame.size.width > 0) {
//            _cellWidthCached = frame.size.width;
//            dout_float(_cellWidthCached)
//            
//            self.contentSize = CGSizeMake(_imageCountCached*_cellWidthCached, 0);
//            [self setContentOffset:CGPointMake(_index*_cellWidthCached, 0) animated:NO];
//            [self setScrollContainerFrameForIndex:_index];
//            //            [self.scrollContainer layoutCells];

        return;
        
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    dout_float(scale)
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _dout_size(self.contentSize)
}

- (void)setImage:(UIImage *)image {    
    if (self.imageView == nil) {
        _dout_warning(@"no view image!")
    }
    
    if (self.imageView.image != image) {
        self.imageView.image = image;
        
        _dout_size(image.size);
        _dout_size(self.bounds.size)
        _dout_float(self.zoomScale)
        self.zoomScale = 1;
        self.contentSize = self.bounds.size;
    }
}

@end
