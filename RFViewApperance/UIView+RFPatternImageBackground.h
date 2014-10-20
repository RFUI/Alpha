/*!
    UIView (RFApperancePatternImageBackground)
    RFUI

    Copyright (c) 2013-2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    BETA
 */

#import "RFUI.h"

/**
 @category UIView (RFApperancePatternImageBackground)

 This category help you fill a view’s background using a pattern image.
 */
@interface UIView (RFApperancePatternImageBackground)

/** The name of the pattern image file. Set this property will change the background color of the view using the specified pattern image.
 */
@property (copy, nonatomic) IBInspectable NSString *backgroundColorPatternImageName;

@end
