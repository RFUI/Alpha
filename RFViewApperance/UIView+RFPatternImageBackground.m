
#import "UIView+RFPatternImageBackground.h"
#import <objc/runtime.h>

static char UIViewBackgroundColorPatternImageNameCateogryProperty;

@implementation UIView (RFApperancePatternImageBackground)

- (NSString *)backgroundColorPatternImageName {
    return objc_getAssociatedObject(self, &UIViewBackgroundColorPatternImageNameCateogryProperty);
}

- (void)setBackgroundColorPatternImageName:(NSString *)backgroundColorPatternImageName {
    if (![self.backgroundColorPatternImageName isEqualToString:backgroundColorPatternImageName]) {
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:backgroundColorPatternImageName]];
        objc_setAssociatedObject(self, &UIViewBackgroundColorPatternImageNameCateogryProperty, backgroundColorPatternImageName, OBJC_ASSOCIATION_COPY);
    }
}

@end
