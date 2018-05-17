/*!
 RFButton
 RFUI
 
 Copyright (c) 2012-2013, 2018 BB9z
 https://github.com/RFUI/Alpha
 
 The MIT License (MIT)
 http://www.opensource.org/licenses/mit-license.php
 */

#import "RFControl.h"

@interface RFButton : RFControl
@property (weak, nullable, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nullable, nonatomic) IBOutlet UILabel *titleLabel;

@property (nullable, nonatomic) void (^highlightEffectBlock)(__kindof RFButton *__nonnull sender);
@property (nullable, nonatomic) void (^unhighlightEffectBlock)(__kindof RFButton *__nonnull sender);
@property (nullable, nonatomic) void (^selecteEffectBlock)(__kindof RFButton *__nonnull sender);
@property (nullable, nonatomic) void (^unselecteEffectBlock)(__kindof RFButton *__nonnull sender);


@property (weak, nullable, nonatomic) IBOutlet UIButton *agentButton;
@property (nullable, nonatomic) void (^touchUpInsideCallback)(__kindof RFButton *__nonnull sender);
@end
