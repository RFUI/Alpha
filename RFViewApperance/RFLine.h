/*!
    RFLine
    RFUI

    Copyright (c) 2014 BB9z
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

@property (assign, nonatomic) IBInspectable CGFloat dashLinePatternValue1;
@property (assign, nonatomic) IBInspectable CGFloat dashLinePatternValue2;

// Draw 1 pixel line
@property (assign, nonatomic) IBInspectable BOOL onePixel;
@end
