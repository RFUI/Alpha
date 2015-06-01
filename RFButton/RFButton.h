/*!
    RFButton
    RFUI

    Copyright (c) 2012-2013 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php
 
    BETA
 */

#import "RFControl.h"

@interface RFButton : RFControl
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (copy, nonatomic) void (^highlightEffectBlock)(RFButton *sender);
@property (copy, nonatomic) void (^unhighlightEffectBlock)(RFButton *sender);
@property (copy, nonatomic) void (^selecteEffectBlock)(RFButton *sender);
@property (copy, nonatomic) void (^unselecteEffectBlock)(RFButton *sender);


@property (weak, nonatomic) IBOutlet UIButton *agentButton;
@property (copy, nonatomic) void (^touchUpInsideCallback)(RFButton *sender);
@end
