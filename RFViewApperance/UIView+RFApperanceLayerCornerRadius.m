
#import "UIView+RFApperanceLayerCornerRadius.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (RFApperanceLayerCornerRadius)

- (CGFloat)cornerRadius {
    return self.layer.cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
}

@end
