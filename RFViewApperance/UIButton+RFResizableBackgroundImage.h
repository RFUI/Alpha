/*!
    UIButton (RFApperanceResizableBackgroundImage)
    RFUI

    Copyright (c) 2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Alpha
 */

#import "RFUI.h"

/**
 @category UIButton (RFApperanceResizableBackgroundImage)

 This category help you making button’s background image resizable if you need support iOS 6 devices.

 If you use storyboard and only have several buttons, you can set these edge insets using user defined runtime attributes.
 
 If there are many buttons, I advice you set them using UIAppearance, eg.

 @code
 @implementation MyButton

 + (void)load {
     [[self appearance] setBackgroundImageResizingCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
     [[self appearance] setBackgroundImageResizingCapInsets2x:UIEdgeInsetsMake(0, 3.5, 0, 3.5)];
 }

 @end

 @endcode
 */
@interface UIButton (RFApperanceResizableBackgroundImage)

/** Background image resizing cap insets.
 
 @discussion Generally, you set this property to make current background image resizable. It will change background image for normal, highlighted, selected and disabled status.

 @see backgroundImageResizingCapInsets2x
 @see backgroundImageStretchResizingMode
*/
@property (assign, nonatomic) UIEdgeInsets backgroundImageResizingCapInsets NS_AVAILABLE_IOS(6_0);

/** Resizing cap insets for retina display.

 @discussion If your 2x and 1x image has the same resizing cap insets, set this property is not required.
 
 @see backgroundImageResizingCapInsets
 @see backgroundImageStretchResizingMode
 */
@property (assign, nonatomic) UIEdgeInsets backgroundImageResizingCapInsets2x NS_AVAILABLE_IOS(6_0);

/** Background image resizing mode.
 
 @discussion If set `YES`, the background image will be stretched when it is resized. Otherwise, it will be tiled.
 */
@property (assign, nonatomic) BOOL backgroundImageStretchResizingMode NS_AVAILABLE_IOS(6_0);


@end
