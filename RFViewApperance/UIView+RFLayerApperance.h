/*!
    UIView (RFLayerApperance)
    RFUI

    Copyright (c) 2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Alpha
 */

#import "RFUI.h"

@interface UIView (RFLayerApperance)
@property IBInspectable CGFloat cornerRadius UI_APPEARANCE_SELECTOR;
@property IBInspectable CGFloat borderWidth UI_APPEARANCE_SELECTOR;
@property IBInspectable UIColor *borderColor UI_APPEARANCE_SELECTOR;
@end
