/*!
 RFRoundingCornersView
 RFUI

 Copyright (c) 2014, 2021 BB9z
 https://github.com/RFUI/Alpha

 The MIT License (MIT)
 http://www.opensource.org/licenses/mit-license.php
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
@property UIEdgeInsets cornerRadius;

/// Set cornerRadius in Interface Builder
@property (nonatomic) IBInspectable CGRect _cornerRadius;
@end
