
#import "RFCheckBox.h"

CGFloat RFCheckBoxNoImageDisableAlpha = 0.5002;
static void *const RFCheckBoxKVOContext = (void *)&RFCheckBoxKVOContext;

@interface RFCheckBox ()
@property (assign, nonatomic) BOOL needsUpdateCheckboxImageView;
@end

@implementation RFCheckBox

- (void)onInit {
    [self addTarget:self action:@selector(_onTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self addObserver:self forKeyPath:@keypath(self, needsUpdateCheckboxImageView) options:NSKeyValueObservingOptionNew context:RFCheckBoxKVOContext];
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

+ (NSSet *)keyPathsForValuesAffectingNeedsUpdateCheckboxImageView {
    RFCheckBox *this;
    return [NSSet setWithObjects:@keypath(this, on), @keypath(this, enabled), @keypath(this, onImage), @keypath(this, onHighlightedImage), @keypath(this, onDisabledImage), @keypath(this, offImage), @keypath(this, offHighlightedImage), @keypath(this, offDisabledImage), nil];
}

- (void)updateCheckboxImageView {
    if (self.isOn) {
        if (self.enabled) {
            if (self.onImage) {
                self.checkBoxImageView.image = self.onImage;
            }
            if (self.onHighlightedImage) {
                self.checkBoxImageView.highlightedImage = self.onHighlightedImage;
            }
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
            if (self.offImage) {
                self.checkBoxImageView.image = self.offImage;
            }
            if (self.offHighlightedImage) {
                self.checkBoxImageView.highlightedImage = self.offHighlightedImage;
            }
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
}

@end
