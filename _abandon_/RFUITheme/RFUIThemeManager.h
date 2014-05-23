/*!
    RFUIThemeManager
    RFUI

    Copyright (c) 2012 BB9z
    http://github.com/bb9z/RFKit

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php
 */

#import "RFRuntime.h"
#import "RFUIThemeBundle.h"

@interface RFUIThemeManager : NSObject
+ (RFUIThemeManager *)sharedInstance;

@property (RF_STRONG, nonatomic) RFUIThemeBundle *defaultBundle;

@property (readonly, nonatomic) RFUIThemeBundle *currentBundle;
@property (readonly, copy, nonatomic) NSString *currentThemeName;

- (void)changeThemeWithBundle:(RFUIThemeBundle *)themeBundle;


#pragma mark - Rule
- (NSDictionary *)themeRuleForKey:(NSString *)string;

#pragma mark - Resource Method
/// 资源文件的搜寻会先尝试当前主题包，若没有从默认主题包获取

// TODO: 测试是否能支持 @2x 、~iPhone 等后缀，扩展名大小写
- (UIImage *)imageWithName:(NSString *)imageName;
- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)extension;

- (NSURL *)urlForResource:(NSString *)name ofType:(NSString *)extension;

@end

static NSString *const MSGRFUIThemeChange = @"com.github.bb9z.rfui.RFUIThemeChange";
static NSString *const RFNotificationKeyThemeName = @"Theme Name";
