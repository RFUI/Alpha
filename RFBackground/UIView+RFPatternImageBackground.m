
#import "UIView+RFPatternImageBackground.h"
#import <objc/runtime.h>

static char UIViewBackgroundColorPatternImageNameCateogryProperty;

@implementation UIView (RFPatternImageBackground)
@dynamic backgroundColorPatternImageName;

- (NSString *)backgroundColorPatternImageName {
    return objc_getAssociatedObject(self, &UIViewBackgroundColorPatternImageNameCateogryProperty);
}

- (void)setBackgroundColorPatternImageName:(NSString *)backgroundColorPatternImageName {
    if (![self.backgroundColorPatternImageName isEqualToString:backgroundColorPatternImageName]) {
        [self willChangeValueForKey:@keypath(self, backgroundColorPatternImageName)];
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:backgroundColorPatternImageName]];
        objc_setAssociatedObject(self, &UIViewBackgroundColorPatternImageNameCateogryProperty, backgroundColorPatternImageName, OBJC_ASSOCIATION_COPY);
        [self didChangeValueForKey:@keypath(self, backgroundColorPatternImageName)];
    }
}

@end
