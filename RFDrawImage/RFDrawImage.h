/*!
 RFDrawImage
 RFUI
 
 Copyright (c) 2014, 2018 BB9z
 https://github.com/RFUI/Alpha
 
 The MIT License (MIT)
 http://www.opensource.org/licenses/mit-license.php
 */
#import <RFKit/RFRuntime.h>

@interface RFDrawImage : NSObject

+ (nonnull UIImage *)imageWithSizeColor:(CGSize)imageSize fillColor:(nonnull UIColor *)color;

+ (nonnull UIImage *)imageWithRoundingCorners:(UIEdgeInsets)cornerRadius
                                 size:(CGSize)imageSize
                            fillColor:(nonnull UIColor *)fillColor
                          strokeColor:(nullable UIColor *)strokeColor
                          strokeWidth:(CGFloat)strokeWidth
                            boxMargin:(UIEdgeInsets)boxMargin
                   resizableCapInsets:(UIEdgeInsets)resizableCapInset
                          scaleFactor:(CGFloat)scaleFactor;

@end
