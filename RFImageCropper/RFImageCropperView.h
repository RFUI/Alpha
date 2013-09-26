/*!
    RFImageCropperView

    Copyright (c) 2012-2013 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Alpha
 */

#import "RFUI.h"

@class RFImageCropperFrameView;

@interface RFImageCropperView : UIView
@property (weak, nonatomic) RFImageCropperFrameView *frameView;

@property (strong, nonatomic) UIImage *sourceImage;

@property (assign, nonatomic) CGSize cropSize;
- (UIImage *)cropedImage;

@property(nonatomic) float minimumZoomScale;
@property(nonatomic) float maximumZoomScale;

@end

@interface RFImageCropperFrameView : UIView
@property (strong, nonatomic) UIColor *borderColor;
@property (strong, nonatomic) UIColor *overlayColor;
@property (strong, nonatomic) UIColor *maskColor;

@end

