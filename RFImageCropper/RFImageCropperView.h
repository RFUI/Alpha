/*!
    RFImageCropperView

    Copyright (c) 2012-2014, 2016 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    BETA
 */

#import <RFKit/RFRuntime.h>
#import <RFInitializing/RFInitializing.h>

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
@property (nonatomic, nonnull) RFImageCropperFrameView *frameView;

@property (nonatomic, nullable) IBInspectable UIImage *sourceImage;

/// Default (100, 100)
@property (nonatomic) IBInspectable CGSize cropSize;
- (nullable UIImage *)croppedImage;

/// Default 1
@property (nonatomic) IBInspectable CGFloat maxPixelZoomRatio;

@end

@interface RFImageCropperFrameView : UIView <
    RFInitializing
>
@property (nonatomic, null_resettable) IBInspectable UIColor *borderColor;
@property (nonatomic, null_resettable) IBInspectable UIColor *overlayColor;
@property (nonatomic, null_resettable) IBInspectable UIColor *maskColor;

@property (nonatomic) IBInspectable CGSize frameSize;

// No implementation
/// Default 10.f
@property (nonatomic) CGFloat frameMargin;
@end

