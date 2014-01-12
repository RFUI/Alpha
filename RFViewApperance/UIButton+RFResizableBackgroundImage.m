
#import "UIButton+RFResizableBackgroundImage.h"
#import "RFRuntime.h"
#import <objc/runtime.h>
#import "UIDevice+RFKit.h"

static char UIButtonBackgroundImageResizingCapInsetsCateogryProperty;
static char UIButtonBackgroundImageResizingCapInsets2xCateogryProperty;
static char UIButtonBackgroundImageStretchResizingModeCateogryProperty;

@implementation UIButton (RFApperanceResizableBackgroundImage)

- (UIEdgeInsets)backgroundImageResizingCapInsets {
    return [objc_getAssociatedObject(self, &UIButtonBackgroundImageResizingCapInsetsCateogryProperty) UIEdgeInsetsValue];
}

- (UIEdgeInsets)backgroundImageResizingCapInsets2x {
    return [objc_getAssociatedObject(self, &UIButtonBackgroundImageResizingCapInsets2xCateogryProperty) UIEdgeInsetsValue];
}

- (BOOL)backgroundImageStretchResizingMode {
    return [objc_getAssociatedObject(self, &UIButtonBackgroundImageStretchResizingModeCateogryProperty) boolValue];
}

- (void)setBackgroundImageStretchResizingMode:(BOOL)backgroundImageStretchResizingMode {
    objc_setAssociatedObject(self, &UIButtonBackgroundImageResizingCapInsetsCateogryProperty, @(backgroundImageStretchResizingMode), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#define __UIButtonSetResizableBackgroundImageForState(IX, STATE)\
    tmp = [self backgroundImageForState:STATE];\
    if (tmp) {\
        [self setBackgroundImage:[tmp resizableImageWithCapInsets:backgroundImageResizingCapInsets resizingMode:mode] forState:STATE];\
    }

- (void)setBackgroundImageResizingCapInsets:(UIEdgeInsets)backgroundImageResizingCapInsets {
    objc_setAssociatedObject(self, &UIButtonBackgroundImageResizingCapInsetsCateogryProperty, [NSValue valueWithUIEdgeInsets:backgroundImageResizingCapInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    if ([UIDevice currentDevice].isRetinaDisplay && objc_getAssociatedObject(self, &UIButtonBackgroundImageResizingCapInsets2xCateogryProperty)) {
        return;
    }
    else {
        UIImage *tmp;
        UIImageResizingMode mode = self.backgroundImageStretchResizingMode? UIImageResizingModeStretch : UIImageResizingModeTile;
        metamacro_foreach(__UIButtonSetResizableBackgroundImageForState,,
                          UIControlStateNormal,
                          UIControlStateHighlighted,
                          UIControlStateSelected,
                          UIControlStateDisabled);
    }
}

- (void)setBackgroundImageResizingCapInsets2x:(UIEdgeInsets)backgroundImageResizingCapInsets {
    objc_setAssociatedObject(self, &UIButtonBackgroundImageResizingCapInsets2xCateogryProperty, [NSValue valueWithUIEdgeInsets:backgroundImageResizingCapInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    if (![UIDevice currentDevice].isRetinaDisplay) {
        return;
    }
    else {
        UIImage *tmp;
        UIImageResizingMode mode = self.backgroundImageStretchResizingMode? UIImageResizingModeStretch : UIImageResizingModeTile;
        metamacro_foreach(__UIButtonSetResizableBackgroundImageForState,,
                          UIControlStateNormal,
                          UIControlStateHighlighted,
                          UIControlStateSelected,
                          UIControlStateDisabled);
    }
}

#undef __UIButtonSetResizableBackgroundImageForState
@end
