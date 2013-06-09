/*!
    RFCheckBox
    RFUI

    Copyright (c) 2013 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    TEST
 */

#import "RFControl.h"

// Add target for UIControlEventValueChanged to get notice when state changed.

@interface RFCheckBox : RFControl
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkBoxImageView;

@property (assign, nonatomic, getter = isOn) BOOL on;

@property (strong, nonatomic) UIImage *onImage;
@property (strong, nonatomic) UIImage *onHighlightedImage;
@property (strong, nonatomic) UIImage *onDisabledImage;
@property (strong, nonatomic) UIImage *offImage;
@property (strong, nonatomic) UIImage *offHighlightedImage;
@property (strong, nonatomic) UIImage *offDisabledImage;

@end

extern CGFloat RFCheckBoxNoImageDisableAlpha;
