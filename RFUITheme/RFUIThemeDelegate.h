
#import "RFUI.h"

@class RFThemeBundle, RFUIThemeManager;
@protocol RFUIThemeDelegate <NSObject>

@required
//- (NSString *)themeDefineRuleKey;
//- (NSDictionary *)themeSupportKeys;
- (void)applyThemeWithRule:(NSDictionary *)dict;


@optional
- (NSString *)RFUIThemeRuleKey;

- (void)changeThemeWithBundle:(RFThemeBundle *)themeBundle;
- (void)changeThemeWithManager:(RFUIThemeManager *)manager;
- (NSDictionary *)themeVersionSupportInfo;

@end


