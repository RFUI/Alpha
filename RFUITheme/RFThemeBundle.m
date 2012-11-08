//
//  RFThemeBundle.m
//  MIPS
//
//  Created by BB9z on 12-11-8.
//
//

#import "RFThemeBundle.h"

static NSString *const RFThemeBundlekThemeName = @"Theme Name";

@implementation RFThemeBundle

+ (RFThemeBundle *)bundleWithName:(NSString *)bundleName {
    NSString *path = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
    RFThemeBundle *bundle = [[RFThemeBundle alloc] initWithPath:path];
    return bundle;
}

- (id)initWithPath:(NSString *)path {
    if (self = [super initWithPath:path]) {
    }
    return self;
}

#pragma mark - Theme Info
- (NSDictionary *)themeInfo {
    if (!_themeInfo) {
        _themeInfo = [NSDictionary dictionaryWithContentsOfFile:[self pathForResource:@"Info" ofType:@"plist"]];
        douto(_themeInfo)
    }
    return _themeInfo;
}

- (NSString *)themeName {
    return [self.themeInfo objectForKey:RFThemeBundlekThemeName];
}



@end
