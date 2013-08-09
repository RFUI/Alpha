//
//  RFThemeBundle.m
//  MIPS
//
//  Created by BB9z on 12-11-8.
//
//

#import "RFUIThemeBundle.h"

@implementation RFUIThemeBundle

+ (RFUIThemeBundle *)bundleWithName:(NSString *)bundleName {
    NSString *path = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
    RFUIThemeBundle *bundle = [[RFUIThemeBundle alloc] initWithPath:path];
    return bundle;
}

- (id)initWithPath:(NSString *)path {
    if ((self = [super initWithPath:path])) {
    }
    return self;
}

#pragma mark - Theme Info
- (NSString *)themeName {
    return [self infoDictionary][RFThemeBundlekThemeName];
}

- (NSDictionary *)themeRuleForKey:(NSString *)string {
    return [self infoDictionary][RFThemeBundlekThemeRules][string];
}

@end
