/*!
    RFDrawImage
    RFUI

    Copyright (c) 2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    BETA
 */
#import <RFKit/RFRuntime.h>

@interface RFDrawImage : NSObject

+ (UIImage *)imageWithSizeColor:(CGSize)imageSize fillColor:(UIColor *)color;

+ (UIImage *)imageWithRoundingCorners:(UIEdgeInsets)cornerRadius
                                 size:(CGSize)imageSize
                            fillColor:(UIColor *)fillColor
                          strokeColor:(UIColor *)strokeColor
                          strokeWidth:(CGFloat)strokeWidth
                            boxMargin:(UIEdgeInsets)boxMargin
                   resizableCapInsets:(UIEdgeInsets)resizableCapInset
                          scaleFactor:(CGFloat)scaleFactor;

@end
