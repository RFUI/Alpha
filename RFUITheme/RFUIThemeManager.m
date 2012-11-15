
#import "RFUIThemeManager.h"
#import "RFThemeBundle.h"

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

- (void)changeThemeToName:(NSString *)themeName {
    if (![themeName isEqualToString:self.currentThemeName]) {        
        dispatch_sync(dispatch_get_main_queue(), ^{
            RFThemeBundle *bundle = [RFThemeBundle bundleWithName:themeName];
            if (bundle) {
                self.currentThemeName = themeName;
                self.currentBundle = bundle;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:MSGRFUIThemeChange object:self userInfo:@{ RFNotificationKeyThemeName : self.currentThemeName }];
            }
        });
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
    NSString *path = [self.currentBundle pathForResource:name ofType:extension];
    if (!path) {
        path = [self.defaultBundle pathForResource:name ofType:extension];
    }
    return path;
}
@end
