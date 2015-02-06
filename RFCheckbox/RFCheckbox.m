
#import "RFCheckbox.h"

CGFloat RFCheckBoxNoImageDisableAlpha = 0.5002;
static void *const RFCheckBoxKVOContext = (void *)&RFCheckBoxKVOContext;

@interface RFCheckbox ()
@property (assign, nonatomic) BOOL needsUpdateCheckboxImageView;
@end

@implementation RFCheckbox

- (NSString *)description {
    NSString *orginalDescription = [super description];
    NSUInteger toIndex = orginalDescription.length - 1;
    return [[orginalDescription substringToIndex:toIndex] stringByAppendingFormat:@"; enabled = %@; on = %@>", self.enabled? @"YES" : @"NO", self.on? @"YES" : @"NO"];
}

- (void)onInit {
    [super onInit];
    
    [self addTarget:self action:@selector(_onTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    _needsUpdateCheckboxImageView = NO;
}

- (void)afterInit {
    [super afterInit];
    
    [self addObserver:self forKeyPath:@keypath(self, needsUpdateCheckboxImageView) options:NSKeyValueObservingOptionNew context:RFCheckBoxKVOContext];
    self.needsUpdateCheckboxImageView = YES;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@keypath(self, needsUpdateCheckboxImageView) context:RFCheckBoxKVOContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context != RFCheckBoxKVOContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if (object == self && [keyPath isEqualToString:@keypath(self, needsUpdateCheckboxImageView)]) {
        [self updateCheckboxImageView];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)_onTouchUpInside {
    self.on = !self.on;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setOn:(BOOL)on {
    _on = on;
    if (self.selected != on) {
        self.selected = on;
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    _on = selected;
}

+ (NSSet *)keyPathsForValuesAffectingNeedsUpdateCheckboxImageView {
    RFCheckbox *this;
    return [NSSet setWithObjects:@keypath(this, on), @keypath(this, enabled), @keypath(this, onImage), @keypath(this, onHighlightedImage), @keypath(this, onDisabledImage), @keypath(this, offImage), @keypath(this, offHighlightedImage), @keypath(this, offDisabledImage), nil];
}

- (void)updateCheckboxImageView {
    if (self.on) {
        if (self.enabled) {
            self.checkBoxImageView.image = self.onImage;
            self.checkBoxImageView.highlightedImage = self.onHighlightedImage;
            
            if (self.checkBoxImageView.alpha == RFCheckBoxNoImageDisableAlpha) {
                self.checkBoxImageView.alpha = 1;
            }
        }
        else {
            if (self.onDisabledImage) {
                self.checkBoxImageView.image = self.onDisabledImage;
            }
            else {
                self.checkBoxImageView.alpha = RFCheckBoxNoImageDisableAlpha;
            }
        }
    }
    else {
        if (self.enabled) {
            self.checkBoxImageView.image = self.offImage;
            self.checkBoxImageView.highlightedImage = self.offHighlightedImage;
            if (self.checkBoxImageView.alpha == RFCheckBoxNoImageDisableAlpha) {
                self.checkBoxImageView.alpha = 1;
            }
        }
        else {
            if (self.offDisabledImage) {
                self.checkBoxImageView.image = self.offDisabledImage;
            }
            else {
                self.checkBoxImageView.alpha = RFCheckBoxNoImageDisableAlpha;
            }
        }
    }
    _needsUpdateCheckboxImageView = NO;
}

@end
