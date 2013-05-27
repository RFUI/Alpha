
#import "RFButton.h"

@interface RFButton ()
@property (weak, nonatomic, readwrite) UIButton *agentButton;
@property (copy, nonatomic, setter = setHighlightEffectBlock:) void (^highlightEffectBlock)(RFButton *);
@property (copy, nonatomic, setter = setUnhighlightEffectBlock:) void (^unhighlightEffectBlock)(RFButton *);
@end

@implementation RFButton

- (void)onInit {
    [self addTarget:self action:@selector(onTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -
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
