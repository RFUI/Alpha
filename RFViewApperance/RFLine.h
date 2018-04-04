/*!
    RFLine
    RFUI

    Copyright (c) 2014-2015, 2018 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Alpha
 */

#import "RFDrawView.h"

/**
 Draw a dash line.

 Background color is used as stroke color.
 */
@interface RFLine : RFDrawView

@property IBInspectable CGFloat dashLinePatternValue1;
@property IBInspectable CGFloat dashLinePatternValue2;
@property CGLineCap lineCapStyle;

// Draw 1 pixel line
@property IBInspectable BOOL onePixel;
@end
