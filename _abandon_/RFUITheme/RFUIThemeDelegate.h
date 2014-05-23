
#import "RFUI.h"

@class RFUIThemeBundle, RFUIThemeManager;
@protocol RFUIThemeDelegate <NSObject>

@required
//- (NSString *)themeDefineRuleKey;
//- (NSDictionary *)themeSupportKeys;
- (void)applyThemeWithRule:(NSDictionary *)dict;


@optional
- (NSString *)RFUIThemeRuleKey;

- (void)changeThemeWithBundle:(RFUIThemeBundle *)themeBundle;
- (void)changeThemeWithManager:(RFUIThemeManager *)manager;
- (NSDictionary *)themeVersionSupportInfo;

@end


