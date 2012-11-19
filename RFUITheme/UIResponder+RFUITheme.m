
#import "UIResponder+RFUITheme.h"

@implementation UIResponder (RFUITheme)

- (NSString *)RFUIThemeRuleKey {
    return NSStringFromClass([self class]);
}

- (void)applyThemeWithRule:(NSDictionary *)dict {
    // nothing
}

@end
