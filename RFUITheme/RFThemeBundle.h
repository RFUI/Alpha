//
//  RFThemeBundle.h
//  MIPS
//
//  Created by BB9z on 12-11-8.
//
//

#import "RFUI.h"

@interface RFThemeBundle : NSBundle
@property (RF_STRONG, nonatomic) NSDictionary *themeInfo;

+ (RFThemeBundle *)bundleWithName:(NSString *)bundleName;
- (id)initWithPath:(NSString *)path;

- (NSString *)themeName;
@end
