/*!
    RFRoundingCornersView
    RFUI

    Copyright (c) 2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Alpha
 */
#import "RFDrawView.h"


@interface RFRoundingCornersView : RFDrawView


/**
 @code
 top         right
   ⤹---------
   |           |
   |           |
   ⤷---------⤴︎
 left          bottom
 @endcode

 */
@property (assign, nonatomic) UIEdgeInsets cornerRadius;
@end
