//
//  RFThemeBundle.h
//  MIPS
//
//  Created by BB9z on 12-11-8.
//
//

#import "RFUI.h"

@interface RFUIThemeBundle : NSBundle
@property (RF_STRONG, nonatomic) NSDictionary *themeInfo;

+ (RFUIThemeBundle *)bundleWithName:(NSString *)bundleName;
- (id)initWithPath:(NSString *)path;

- (NSString *)themeName;
- (NSDictionary *)themeRuleForKey:(NSString *)string;
@end

static NSString *const RFThemeBundlekThemeName = @"Theme Name";
static NSString *const RFThemeBundlekThemeRules = @"Theme Rules";
static NSString *const RFThemeBundlekThemePreview = @"Preview";
