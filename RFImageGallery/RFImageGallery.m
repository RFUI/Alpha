
#import "RFImageGallery.h"

@interface RFImageGallery () {
    /// 滚动一页超过百分之多少时认为翻页，这可以避免在硬分界出现的抖动，默认80%
    CGFloat pageChangeTolerance;
}
@property (assign, nonatomic) NSUInteger imageCountCached;
@property (assign, nonatomic) CGFloat cellWidthCached;

@end

@interface RFImageGalleryScrollContainer ()

- (void)layoutExchangeCellToLeft;
- (void)layoutExchangeCellToRight;
@end

@interface RFImageGalleryCell ()
@end


@implementation RFImageGallery

#pragma mark -
- (RFImageGallery *)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
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
    
    if (self.scrollContainer == nil) {
        self.scrollContainer = [[RFImageGalleryScrollContainer alloc] initWithMaster:self];
        self.scrollContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:self.scrollContainer];
    }
    
    _index = 1;
    [self reloadData];
    
    [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"index" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
}

#pragma mark 滑动方法
- (void)scrollToIndex:(NSUInteger)toIndex animated:(BOOL)animated {
    if (self.index == toIndex) {
        return;
    }
    
    if (self.index >= _imageCountCached) {
        [self scrollToIndex:(_imageCountCached-1) animated:animated];
        return;
    }
    NSUInteger ogIndex = _index;
    _index = toIndex;
    
    if (animated) {
//        CGSize contentSize = self.frame.size;
//        
//        CGFloat wCell = self.frame.size.width;
//        CGRect bounds = self.scrollContainer.bounds;
        
//        [self setupCellForIndex:toIndex];
    }
    else {
        if (toIndex == 0) {
            [self.scrollContainer moveToX:-_cellWidthCached Y:RFMathNotChange];
        }
        else if (toIndex == _imageCountCached) {
            [self.scrollContainer moveToX:toIndex*_cellWidthCached Y:RFMathNotChange];
        }
        else {
            [self.scrollContainer moveToX:(toIndex-1)*_cellWidthCached Y:RFMathNotChange];
        }
        
        if (toIndex < ogIndex) {
            [self.scrollContainer layoutExchangeCellToLeft];
        }
        else {
            [self.scrollContainer layoutExchangeCellToRight];
        }
        [self setupCellForIndex:toIndex];
    }
}

/// 当index改变时调整图像和子视图位置
- (void)setupCellForIndex:(NSUInteger)index {
    _doutwork()
    [self.scrollContainer.lCell setImage:[self imageForIndex:index-1]];
    [self.scrollContainer.mCell setImage:[self imageForIndex:index]];
    [self.scrollContainer.rCell setImage:[self imageForIndex:index+1]];
}

- (UIImage *)imageForIndex:(NSUInteger)index {
    if (index < _imageCountCached && self.dataSource && [self.dataSource respondsToSelector:@selector(imageGallery:imageAtIndex:)]) {
        return [self.dataSource imageGallery:self imageAtIndex:index];
    }
    return nil;
}

/// 初始化时会调用
- (void)reloadData {
    doutwork()
    if (![self checkDateSource]) return;
    
    // 更新缓存变量
    _imageCountCached = [self.dataSource numberOfImageInGallery:self];
    _cellWidthCached = self.frame.size.width;
    dout_int(_imageCountCached)
    
    [self scrollToIndex:0 animated:NO];
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGFloat pageDiff = self.contentOffset.x/_cellWidthCached - _index;
        
        if (ABS(pageDiff) > pageChangeTolerance) {
            if (pageDiff > 0) {
                [self scrollToIndex:(_index+1) animated:NO];
            }
            else {
                [self scrollToIndex:(_index-1) animated:NO];
            }
        }
        return;
    }
    
    if ([keyPath isEqualToString:@"frame"]) {
        dout_int(_imageCountCached)
        dout_float(_cellWidthCached)
        self.contentSize = CGSizeMake(_imageCountCached*_cellWidthCached, 0);
        return;
    }
    
    if ([keyPath isEqualToString:@"index"]) {
        [self scrollToIndex:self.index animated:YES];
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end

#pragma mark - RFImageGalleryScrollContainer
@implementation RFImageGalleryScrollContainer

- (id)initWithMaster:(RFImageGallery *)master {
    CGRect frame = master.bounds;
    CGFloat wCell = frame.size.width;
    CGFloat hCell = frame.size.height;
    frame.size.width = frame.size.width*3;
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRGBHex:0xFFFFFF alpha:0.5];
        
        self.lCell = [[RFImageGalleryCell alloc] initWithFrame:CGRectMake(0, 0, wCell, hCell)];
        self.mCell = [[RFImageGalleryCell alloc] initWithFrame:CGRectMake(wCell, 0, wCell, hCell)];
        self.rCell = [[RFImageGalleryCell alloc] initWithFrame:CGRectMake(wCell*2, 0, wCell, hCell)];
        
        if (RFUIDebugEnableRandomBackgroundColor) {
            _lCell.backgroundColor = [UIColor randColorWithAlpha:.5];
            _mCell.backgroundColor = [UIColor randColorWithAlpha:.5];
            _rCell.backgroundColor = [UIColor randColorWithAlpha:.5];
        }
        
        UIViewAutoresizing mask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _lCell.autoresizingMask = mask;
        _mCell.autoresizingMask = mask;
        _rCell.autoresizingMask = mask;

        [self addSubview:_lCell];
        [self addSubview:_mCell];
        [self addSubview:_rCell];

    }
    return self;
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

- (void)layoutSubviews {
    [super layoutSubviews];
    
    dout_rect(self.frame);
}

@end


@implementation RFImageGalleryCell

- (RFImageGalleryCell *)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.frame];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_imageView resizeOption:RFViewResizeOptionFill];
        self.minimumZoomScale = 0.5;
        self.maximumZoomScale = 2.0;
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    if (image == nil) {
        dout_info(@"nil image!")
    }
    if (self.imageView == nil) {
        dout_info(@"no view image!")
    }
    self.imageView.image = image;
}

@end
