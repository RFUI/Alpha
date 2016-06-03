
#import "UIView+RFLayerApperance.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (RFLayerApperance)

- (CGFloat)cornerRadius {
    return self.layer.cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
}

- (CGFloat)borderWidth {
    return self.layer.borderWidth;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    self.layer.borderWidth = borderWidth;
}

- (UIColor *)borderColor {
    CGColorRef clRef = self.layer.borderColor;
    if (!clRef) return nil;
    return [UIColor colorWithCGColor:clRef];
}

- (void)setBorderColor:(UIColor *)borderColor {
    self.layer.borderColor = borderColor.CGColor;
    if (!self.borderWidth) {
        self.borderWidth = 1;
    }
}

@end
