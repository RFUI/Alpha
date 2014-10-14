
#import "RFImageCropperView.h"
#import "UIView+RFAnimate.h"

@interface RFImageCropperScrollView : UIScrollView
@end

@interface RFImageCropperView () <
    UIScrollViewDelegate
>
@property (strong, nonatomic) RFImageCropperScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (assign, nonatomic) CGSize imageSize;
@property (assign, nonatomic) CGFloat frameScale;
@property (assign, nonatomic) BOOL scaleFixLock;
@end

@implementation RFImageCropperView
RFInitializingRootForUIView

- (void)onInit {
    // Default
    _cropSize = CGSizeMake(100, 100);
    _maxPixelZoomRatio = 1;

    self.clipsToBounds = YES;
    [self.frameView bringAboveView:self.scrollView];
}

- (void)afterInit {
    // Nothing
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p; frame = %@; contentOffset = %@; contentSize = %@; zoomScale = %f; maximumZoomScale = %f; minimumZoomScale = %f; imageSize = %@; cropSize = %@; sourceImage = %@; maxPixelZoomRatio = %f; scrollView frame = %@>", self.class, self, NSStringFromCGRect(self.frame), NSStringFromCGPoint(self.scrollView.contentOffset), NSStringFromCGSize(self.scrollView.contentSize), self.scrollView.zoomScale, self.scrollView.maximumZoomScale, self.scrollView.minimumZoomScale, NSStringFromCGSize(self.imageSize), NSStringFromCGSize(self.cropSize), self.sourceImage, self.maxPixelZoomRatio, NSStringFromCGRect(self.scrollView.frame)];
}

- (UIImage *)croppedImage {
    CGFloat scale = self.scrollView.zoomScale;
    CGPoint imageOffset = self.scrollView.contentOffset;
    _dout_point(imageOffset)

    // If offset is not a integer, image size may become diffrent to cropSize
    imageOffset.x = floor(imageOffset.x);
    imageOffset.y = floor(imageOffset.y);

    UIImage *downSizeImage = [self.sourceImage imageWithScale:scale];
    UIImage *cropedImage = [downSizeImage imageWithCropRect:(CGRect){imageOffset, self.cropSize}];
    dout_debug(@"SourceImage %@@%.f", NSStringFromCGSize(self.sourceImage.size), self.sourceImage.scale);
    dout_debug(@"CropedImage %@@%.f", NSStringFromCGSize(cropedImage.size), cropedImage.scale);
    return cropedImage;
}

#pragma mark - View Setup

- (RFImageCropperFrameView *)frameView {
    if (!_frameView) {
        RFImageCropperFrameView *fv = [[RFImageCropperFrameView alloc] initWithFrame:self.bounds];
        fv.autoresizingMask = UIViewAutoresizingFlexibleSize;
        [self addSubview:fv];
        fv.frameSize = self.cropSize;
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
        sv.scrollsToTop = NO;
        self.scrollView = sv;
    }
    return _scrollView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *iv = [[UIImageView alloc] init];
        [self.scrollView addSubview:iv];
        _imageView = iv;
    }
    return _imageView;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)updateLayout {
    RFImageCropperFrameView *frameView = self.frameView;
    frameView.frameSize = self.cropSize;

    UIScrollView *scrollView = self.scrollView;
    scrollView.size = self.cropSize;
    scrollView.center = CGPointOfRectCenter(self.bounds);

    // Make sure scrollView can scroll
    CGSize contentSize = scrollView.contentSize;
    CGSize imageSize = self.cropSize;
    CGFloat expand = self.window.screen? 1/self.window.screen.scale/2 : 1/[UIScreen mainScreen].scale/2;
    _dout_float(expand);
    if (contentSize.width <= imageSize.width + expand) {
        _dout_debug(@"Expand width")
        contentSize.width = imageSize.width + expand;
        scrollView.contentSize = contentSize;
    }
    if (contentSize.height <= imageSize.height + expand) {
        _dout_debug(@"Expand height")
        contentSize.height = imageSize.height + expand;
        scrollView.contentSize = contentSize;
    }
    _dout_size(contentSize)
}

#pragma mark -

- (void)setSourceImage:(UIImage *)sourceImage {
    if (_sourceImage != sourceImage) {
        self.imageSize = sourceImage.size;
        self.imageView.image = sourceImage;

        self.scaleFixLock = NO;
        [self updateScaleSetting];

        UIImageView *imageView = self.imageView;
        UIScrollView *scrollView = self.scrollView;
        [imageView sizeToFit];
        [imageView moveToX:0 Y:0];
        scrollView.contentSize = imageView.size;

        [scrollView setContentOffset:CGPointMake((scrollView.contentSize.width - scrollView.width)/2, (scrollView.contentSize.height - scrollView.height)/2) animated:NO];

        _sourceImage = sourceImage;
    }
}

- (void)setCropSize:(CGSize)cropSize {
    _cropSize = cropSize;
    self.frameView.frameSize = cropSize;
    [self.frameView setNeedsDisplay];
    self.scaleFixLock = NO;
    [self updateScaleSetting];
}

- (void)updateScaleSetting {
    CGSize imageSize = self.imageSize;
    CGSize cropSize = self.cropSize;

    if (imageSize.width <= 0 || imageSize.height <=0 || cropSize.width <= 0 || cropSize.height <= 0) {
        return;
    }

    if (imageSize.width < cropSize.width || imageSize.height < cropSize.height) {
        dout_warning(@"Image size is smaller than crop size.");
    }

    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat onePixel = 1/scale;
    CGFloat xScale = imageSize.width/cropSize.width;
    CGFloat yScale = imageSize.height/cropSize.height;
    _dout_float(xScale)
    _dout_float(yScale)

    UIScrollView *scrollView = self.scrollView;
    scrollView.minimumZoomScale = MAX(1/xScale, 1/yScale);
    scrollView.maximumZoomScale = MIN(xScale *self.maxPixelZoomRatio, yScale*self.maxPixelZoomRatio);

    // Make sure scrollView is zoom enabled.
    if (scrollView.maximumZoomScale <= scrollView.minimumZoomScale) {
        CGFloat scaleAdjust = MIN(onePixel/cropSize.width, onePixel/cropSize.height)/2;
        _dout_float(scaleAdjust)
        scrollView.maximumZoomScale = scrollView.minimumZoomScale + scaleAdjust;
    }
    _dout_float(self.scrollView.minimumZoomScale)
    _dout_float(self.scrollView.maximumZoomScale)
    scrollView.zoomScale = scrollView.minimumZoomScale;

    [self updateLayout];

    // Set again will fix scrollview could not scroll.
    if (!self.scaleFixLock) {
        self.scaleFixLock = YES;
        dispatch_after_seconds(0, ^{
            [self updateScaleSetting];
        });
    }
}


#pragma mark - Zoom Scale

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat zoom = self.scrollView.zoomScale;
    CGFloat minScale = self.scrollView.minimumZoomScale;
    _dout_float(zoom)
    _dout_float(minScale)

    if (zoom < minScale) {
        scrollView.size = CGSizeScaled(self.cropSize, zoom/minScale);
        scrollView.center = CGPointOfRectCenter(self.bounds);
    }
    else {
        scrollView.size = self.cropSize;
        scrollView.center = CGPointOfRectCenter(self.bounds);
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [UIView animateWithDuration:0.1 animations:^{
        [self updateLayout];
        dout_size(self.scrollView.contentSize)
    }];
}

@end

@implementation RFImageCropperFrameView
RFInitializingRootForUIView

- (void)onInit {
    // Default vaule
    self.maskColor = [UIColor colorWithRGBHex:0x000000 alpha:0.5];
    self.overlayColor = [UIColor clearColor];
    self.borderColor = [UIColor colorWithRGBHex:0x005555 alpha:1];
    self.frameMargin = 10.f;
    
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
    self.userInteractionEnabled = NO;
}

- (void)afterInit {
    // Nothing
}

- (void)drawRect:(CGRect)rect {
    CGRect viewFrame = self.bounds;
    CGRect cropFrame = CGRectMakeWithCenterAndSize(self.center, self.frameSize);
    
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

