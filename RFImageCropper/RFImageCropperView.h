/*!
    RFImageCropperView

    Copyright (c) 2012-2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Alpha
 */

#import "RFUI.h"

@class RFImageCropperFrameView;

/**
 
 If cropSize is bigger than view size, you can scale this view to make sure frameView is visable completely.
 
 eg:

 @code
self.cropView.cropSize = CGSizeMake(640, 640);
self.cropView.transform = CGAffineTransformMakeScale(0.5, 0.5);
 @endcode
 
 */
@interface RFImageCropperView : UIView <
    RFInitializing
>
@property (strong, nonatomic) RFImageCropperFrameView *frameView;

@property (strong, nonatomic) UIImage *sourceImage;

/// Default (100, 100)
@property (assign, nonatomic) CGSize cropSize;
- (UIImage *)croppedImage;

/// Default 1
@property (assign, nonatomic) CGFloat maxPixelZoomRatio;

@end

@interface RFImageCropperFrameView : UIView <
    RFInitializing
>
@property (strong, nonatomic) UIColor *borderColor;
@property (strong, nonatomic) UIColor *overlayColor;
@property (strong, nonatomic) UIColor *maskColor;

@property (assign, nonatomic) CGSize frameSize;

// No implementation
/// Default 10.f
@property (assign, nonatomic) CGFloat frameMargin;
@end

