
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
RFInitializingRootForUIView

- (void)onInit {
    self.cropSize = CGSizeMake(100, 100);
    self.clipsToBounds = YES;
    
    [self rac_addObserver:self forKeyPath:@keypath(self, sourceImage) options:NSKeyValueObservingOptionNew queue:nil block:^(RFImageCropperView *observer, NSDictionary *change) {
        [observer onSourceImageChanged];
    }];
    
    [self rac_addObserver:self forKeyPath:@keypath(self, cropSize) options:NSKeyValueObservingOptionNew queue:nil block:^(RFImageCropperView *observer, NSDictionary *change) {
        observer.frameView.cropSize = observer.cropSize;
        [observer.frameView setNeedsDisplay];
        [observer setNeedsLayout];
    }];
    
    [self.frameView bringAboveView:self.scrollView];
}

- (void)afterInit {
    // Nothing
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
RFInitializingRootForUIView

- (void)onInit {
    // Default vaule
    self.maskColor = [UIColor colorWithRGBHex:0x000000 alpha:0.5];
    self.overlayColor = [UIColor clearColor];
    self.borderColor = [UIColor colorWithRGBHex:0x005555 alpha:1];
    
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
    self.userInteractionEnabled = NO;
}

- (void)afterInit {
    // Nothing
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

