
#import "RFUI.h"

@class RFThemeBundle;
@protocol RFUIThemeDelegate <NSObject>

@required
- (void)changeThemeWithBundle:(RFThemeBundle *)themeBundle;

@optional

@end
