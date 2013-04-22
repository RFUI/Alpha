/*!
    RFButton
    RFUI

    Copyright (c) 2012-2013 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php
 
    Alpha
 */

#import "RFUI.h"

@interface RFButton : UIView
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (copy, nonatomic, setter = setTappedBlock:) void (^tappedBlock)(RFButton *);

// Defalut was nil.
- (void)setHighlightEffectBlock:(void (^)(RFButton *sender))highlightEffectBlock;
- (void)setUnhighlightEffectBlock:(void (^)(RFButton *sender))unhighlightEffectBlock;

- (void)onTouchUpInside;

@property (weak, nonatomic, readonly) UIButton *agentButton;

@end
