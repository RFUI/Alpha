
#import "RFUIThemeManager.h"

@interface RFUIThemeManager ()
@property (readwrite, copy, nonatomic) NSString *currentThemeName;
@property (readwrite, nonatomic) RFThemeBundle *currentBundle;
@end

@implementation RFUIThemeManager

+ (RFUIThemeManager *)sharedInstance {
	static RFUIThemeManager *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
	return sharedInstance;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, Theme Name:%@, bundle:%@, default:%@>", [self class], self, self.currentThemeName, self.currentBundle, self.defaultBundle];
}

- (void)changeThemeToName:(NSString *)themeName {
    if (themeName.length == 0) return;
    
    if (![themeName isEqualToString:self.currentThemeName]) {
        RFThemeBundle *bundle = [RFThemeBundle bundleWithName:themeName];
        if (bundle) {
            self.currentThemeName = themeName;
            self.currentBundle = bundle;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:MSGRFUIThemeChange object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:RFNotificationKeyThemeName, self.currentThemeName, nil]];
        }
    }
}

- (NSDictionary *)themeRuleForKey:(NSString *)string {
    RFAssert(string.length > 0, @"Temp assert");
    
    if (self.currentBundle) {
        return [self.currentBundle themeRuleForKey:string];
    }
    else {
        return [self.defaultBundle themeRuleForKey:string];
    }
}

- (UIImage *)imageWithName:(NSString *)imageName {
    NSString *imagePath = [self pathForResource:imageName ofType:@"png"];
    if (!imagePath) {
        imagePath = [self pathForResource:imageName ofType:@"jpg"];
    }
    return [UIImage imageWithContentsOfFile:imagePath];
}

- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)extension {
    NSString *path = nil;
    if (self.currentBundle) {
        path = [self.currentBundle pathForResource:name ofType:extension];
    }
    if (!path) {
        path = [self.defaultBundle pathForResource:name ofType:extension];
    }
    return path;
}
@end
