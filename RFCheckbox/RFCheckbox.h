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

@property (strong, nonatomic) IBInspectable UIImage *onImage;
@property (strong, nonatomic) IBInspectable UIImage *onHighlightedImage;
@property (strong, nonatomic) IBInspectable UIImage *onDisabledImage;
@property (strong, nonatomic) IBInspectable UIImage *offImage;
@property (strong, nonatomic) IBInspectable UIImage *offHighlightedImage;
@property (strong, nonatomic) IBInspectable UIImage *offDisabledImage;

@end

extern CGFloat RFCheckBoxNoImageDisableAlpha;
