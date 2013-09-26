
#import "RFImageCropperView.h"
#import "UIView+RFAnimate.h"

@interface RFImageCropperScrollView : UIScrollView
@end

@interface RFImageCropperFrameView ()
@property (assign, nonatomic) CGSize cropSize;
@end


#pragma mark -
static void *const RFImageCropperViewKVOContext = (void *)&RFImageCropperViewKVOContext;

@interface RFImageCropperView ()
<UIScrollViewDelegate>
@property (strong, nonatomic) RFImageCropperScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation RFImageCropperView
@dynamic minimumZoomScale, maximumZoomScale;

#pragma mark - init
- (id)init {
    self = [super init];
    if (self) {
        [self onInit];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self onInit];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self onInit];
    }
    return self;
}
- (void)onInit {
    self.cropSize = CGSizeMake(100, 100);
    self.clipsToBounds = YES;
    [self addObserver:self forKeyPath:@keypath(self, sourceImage) options:NSKeyValueObservingOptionNew context:RFImageCropperViewKVOContext];
    [self addObserver:self forKeyPath:@keypath(self, cropSize) options:NSKeyValueObservingOptionNew context:RFImageCropperViewKVOContext];
    [self.frameView bringAboveView:self.scrollView];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@keypath(self, sourceImage) context:RFImageCropperViewKVOContext];
    [self removeObserver:self forKeyPath:@keypath(self, cropSize) context:RFImageCropperViewKVOContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context != RFImageCropperViewKVOContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }

    if (object == self && [keyPath isEqualToString:@keypath(self, sourceImage)]) {
        [self onSourceImageChanged];
    }
    else if (object == self && [keyPath isEqualToString:@keypath(self, cropSize)]) {
        self.frameView.cropSize = self.cropSize;
        [self.frameView setNeedsDisplay];
        [self setNeedsLayout];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (RFImageCropperFrameView *)frameView {
    if (!_frameView) {
        RFImageCropperFrameView *fv = [[RFImageCropperFrameView alloc] initWithFrame:self.bounds];
        fv.autoresizingMask = UIViewAutoresizingFlexibleSize;
        [self addSubview:fv];
        fv.cropSize = self.cropSize;
        _frameView = fv;
    }
    return _frameView;
}

- (RFImageCropperScrollView *)scrollView {
    if (!_scrollView) {
        RFImageCropperScrollView *sv = [[RFImageCropperScrollView alloc] init];
        sv.autoresizingMask = UIViewAutoresizingFlexibleMargin;
        sv.delegate = self;
        [self addSubview:sv];
        sv.backgroundColor = [UIColor clearColor];
        
        sv.showsHorizontalScrollIndicator = NO;
        sv.showsVerticalScrollIndicator = NO;
        sv.decelerationRate = UIScrollViewDecelerationRateFast;
        sv.maximumZoomScale = 5;
        sv.minimumZoomScale = 0.01;
        sv.clipsToBounds = NO;
        self.scrollView = sv;
    }
    return _scrollView;
}

- (void)onSourceImageChanged {
    if (self.imageView) {
        [self.imageView removeFromSuperview];
    }
    
    self.imageView = [[UIImageView alloc] initWithImage:self.sourceImage];
    [self.scrollView addSubview:self.imageView];
    self.scrollView.contentSize = self.imageView.frame.size;
    self.scrollView.contentOffset = CGPointOfRectCenter(self.imageView.bounds);
}

- (UIImage *)cropedImage {
    CGFloat scale = self.scrollView.zoomScale;
    CGPoint imageOffset = self.scrollView.contentOffset;
    CGPoint imageOffsetAfterScale = CGPointMake(imageOffset.x*scale, imageOffset.y*scale);
    return [[self.sourceImage imageWithScale:scale] imageWithCropRect:(CGRect){imageOffsetAfterScale, self.cropSize}];
}

- (void)layoutSubviews {
    self.scrollView.size = self.cropSize;
    self.scrollView.center = CGPointOfRectCenter(self.bounds);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

// TODO: 处理缩放情形，当图片缩放过小时不正常
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
}

#pragma mark - Zoom Scale Properties
+ (NSSet *)keyPathsForValuesAffectingMinimumZoomScale {
    return [NSSet setWithObject:@keypathClassInstance(RFImageCropperView, scrollView.minimumZoomScale)];
}
+ (NSSet *)keyPathsForValuesAffectingMaximumZoomScale {
    return [NSSet setWithObject:@keypathClassInstance(RFImageCropperView, scrollView.maximumZoomScale)];
}

- (float)minimumZoomScale {
    return self.scrollView.minimumZoomScale;
}
- (float)maximumZoomScale {
    return self.scrollView.maximumZoomScale;
}

- (void)setMinimumZoomScale:(float)minimumZoomScale {
    self.scrollView.minimumZoomScale = minimumZoomScale;
}
- (void)setMaximumZoomScale:(float)maximumZoomScale {
    self.scrollView.maximumZoomScale = maximumZoomScale;
}

@end

@implementation RFImageCropperFrameView

- (id)init {
    self = [super init];
    if (self) {
        [self onInit];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self onInit];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self onInit];
    }
    return self;
}
- (void)onInit {
    // Default vaule
    self.maskColor = [UIColor colorWithRGBHex:0x000000 alpha:0.5];
    self.overlayColor = [UIColor clearColor];
    self.borderColor = [UIColor colorWithRGBHex:0x005555 alpha:1];
    
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
    self.userInteractionEnabled = NO;
}

- (void)drawRect:(CGRect)rect {
    CGRect viewFrame = self.bounds;
    CGRect cropFrame = CGRectMakeWithCenterAndSize(self.center, self.cropSize);
    
    CGPoint tmpPA = cropFrame.origin;
    CGPoint tmpPB = CGPointMake(CGRectGetMaxX(cropFrame), CGRectGetMaxY(cropFrame));
    // Outer mask
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(tmpPB.x, tmpPA.y)];
    [bezierPath addLineToPoint:tmpPA];
    [bezierPath addLineToPoint:CGPointMake(tmpPA.x, tmpPB.y)];
    [bezierPath addLineToPoint:tmpPB];
    [bezierPath addLineToPoint:CGPointMake(tmpPB.x, tmpPA.y)];
    [bezierPath closePath];
    
    tmpPA = viewFrame.origin;
    tmpPB = CGPointMake(CGRectGetMaxX(viewFrame), CGRectGetMaxY(viewFrame));
    [bezierPath moveToPoint:tmpPA];
    [bezierPath addLineToPoint:CGPointMake(tmpPB.x, tmpPA.y)];
    [bezierPath addLineToPoint:tmpPB];
    [bezierPath addLineToPoint:CGPointMake(tmpPA.x, tmpPB.y)];
    [bezierPath addLineToPoint:tmpPA];
    [bezierPath closePath];
    [self.maskColor setFill];
    [bezierPath fill];
    
    // Inside overlay
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect:cropFrame];
    [self.overlayColor setFill];
    [rectanglePath fill];
    [self.borderColor setStroke];
    rectanglePath.lineWidth = 2;
//    CGFloat rectanglePattern[] = {5, 1, 5, 1};
//    [rectanglePath setLineDash: rectanglePattern count: 4 phase: 0];
    [rectanglePath stroke];
}

@end


@implementation RFImageCropperScrollView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect expandFrame = [self convertRect:self.superview.bounds fromView:self.superview];
    return CGRectContainsPoint(expandFrame, point);
}

@end

