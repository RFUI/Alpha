
#import "RFControl.h"

@implementation RFControl

#pragma mark - init
- (id)init {
    self = [super init];
    if (self) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self onInit];
        });
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self onInit];
        });
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self onInit];
        });
    }
    return self;
}

- (void)onInit {
    // For overwrite
}

#pragma mark - Control Attributes
- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    
    for (UIControl *view in self.subviews) {
        if ([view isKindOfClass:[UIControl class]]) {
            view.enabled = enabled;
        }
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    for (UIControl *view in self.subviews) {
        if ([view isKindOfClass:[UIControl class]]) {
            view.selected = selected;
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    for (UIControl *view in self.subviews) {
        if ([view isKindOfClass:[UIControl class]]) {
            view.highlighted = highlighted;
        }
        else if ([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UIImageView class]]) {
            view.highlighted = highlighted;
        }
    }
}

@end
