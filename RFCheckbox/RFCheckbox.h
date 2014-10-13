/*!
    RFCheckBox
    RFUI

    Copyright (c) 2013-2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Alpha
 */

#import "RFControl.h"

// Add target for UIControlEventValueChanged to get notice when state changed.

@interface RFCheckbox : RFControl
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkBoxImageView;

@property (assign, nonatomic, getter = isOn) IBInspectable BOOL on;

@property (strong, nonatomic) IBInspectable UIImage *onImage UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) IBInspectable UIImage *onHighlightedImage UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) IBInspectable UIImage *onDisabledImage UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) IBInspectable UIImage *offImage UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) IBInspectable UIImage *offHighlightedImage UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) IBInspectable UIImage *offDisabledImage UI_APPEARANCE_SELECTOR;

@end

extern CGFloat RFCheckBoxNoImageDisableAlpha;
