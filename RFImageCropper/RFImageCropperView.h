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

@property (strong, nonatomic) IBInspectable UIImage *sourceImage;

/// Default (100, 100)
@property (assign, nonatomic) IBInspectable CGSize cropSize;
- (UIImage *)croppedImage;

/// Default 1
@property (assign, nonatomic) IBInspectable CGFloat maxPixelZoomRatio;

@end

@interface RFImageCropperFrameView : UIView <
    RFInitializing
>
@property (strong, nonatomic) IBInspectable UIColor *borderColor;
@property (strong, nonatomic) IBInspectable UIColor *overlayColor;
@property (strong, nonatomic) IBInspectable UIColor *maskColor;

@property (assign, nonatomic) IBInspectable CGSize frameSize;

// No implementation
/// Default 10.f
@property (assign, nonatomic) CGFloat frameMargin;
@end

