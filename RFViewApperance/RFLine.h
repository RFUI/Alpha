/*!
    RFLine
    RFUI

    Copyright (c) 2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Alpha
 */

#import "RFUI.h"
#import "RFInitializing.h"

/**
 Draw a dash line.

 Background color is used as stroke color.
 */
@interface RFLine : UIView <
    RFInitializing
>

/// Line color
@property (strong, nonatomic) UIColor *color UI_APPEARANCE_SELECTOR;

@property (assign, nonatomic) CGFloat dashLinePatternValue1 UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) CGFloat dashLinePatternValue2 UI_APPEARANCE_SELECTOR;
@end
