
#import "RFButton.h"

@interface RFButton ()
@property (weak, nonatomic, readwrite) UIButton *agentButton;
@end

@implementation RFButton

- (void)onInit {
    [super onInit];
    
    [self addTarget:self action:@selector(onTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -
- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        if (self.selecteEffectBlock) {
            self.selecteEffectBlock(self);
        }
    }
    else {
        if (self.unselecteEffectBlock) {
            self.unselecteEffectBlock(self);
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        if (self.highlightEffectBlock) {
            self.highlightEffectBlock(self);
        }
    }
    else {
        if (self.unhighlightEffectBlock) {
            self.unhighlightEffectBlock(self);
        }
    }
}

- (void)onTouchUpInside {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (self.tappedBlock) {
        self.tappedBlock(self);
    }
#pragma clang diagnostic pop
}

@end
