
#import "RFResizableBackgroundImageButton.h"
#import "RFUIThemeBundle.h"
#import "RFUIThemeManager.h"

@interface RFResizableBackgroundImageButton ()
@property (RF_STRONG, nonatomic) RFUIThemeBundle *bundle;
@end

@implementation RFResizableBackgroundImageButton
_RFAlloctionLog

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _douts(NSStringFromUIEdgeInsets(self.backgroundImageCapInsets));
    UIImage *image = [self backgroundImageForState:UIControlStateNormal];
    [self setBackgroundImage:[image resizableImageWithCapInsets:self.backgroundImageCapInsets] forState:UIControlStateNormal];
}

- (RFUIThemeManager *)themeManager {
    if (!_themeManager) {
        _themeManager = [RFUIThemeManager sharedInstance];
    }
    return _themeManager;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview) {
        __weak RFResizableBackgroundImageButton *selfRef = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:MSGRFUIThemeChange object:nil queue:nil usingBlock:^(NSNotification *note) {
            NSDictionary *rule = [selfRef.themeManager themeRuleForKey:[selfRef RFUIThemeRuleKey]];
            [selfRef applyThemeWithRule:rule];
        }];
        [self applyThemeWithRule:[self.themeManager themeRuleForKey:[self RFUIThemeRuleKey]]];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MSGRFUIThemeChange object:nil];
    }
}

//- (void)changeThemeWithBundle:(RFThemeBundle *)themeBundle {
//    self.bundle = themeBundle;
//    [self setupBackgroundImageWithName:self.backgroundImageName];
//}

- (void)applyThemeWithRule:(NSDictionary *)dict {
    id rule = nil;
    
    _RFUIThemeApplayRule(@"Background Image CapInsets") {
        self.backgroundImageCapInsets = UIEdgeInsetsFromString(rule);
    }
    _RFUIThemeApplayRule(@"Background Image Name") {
        self.backgroundImageName = rule;
    }
    _RFUIThemeApplayRule(@"Shows Touch When Highlighted") {
        self.showsTouchWhenHighlighted = [rule boolValue];
    }
    _RFUIThemeApplayRule(@"Color Highlighted") {
        [self setTitleColor:[UIColor colorWithRGBString:rule] forState:UIControlStateHighlighted];
    }
    _RFUIThemeApplayRule(@"Color") {
        [self setTitleColor:[UIColor colorWithRGBString:rule] forState:UIControlStateNormal];
    }
    [self setupBackgroundImageWithName:self.backgroundImageName];
}

- (NSString *)RFUIThemeRuleKey {
    return NSStringFromClass([self class]);
}

- (void)setupBackgroundImageWithName:(NSString *)backGroundImageName {
    if (backGroundImageName.length > 0) {
        NSString *imageName = backGroundImageName;

        #define _RFResizableBackgroundImageButtonSetImage(imageName, state)\
            if (imageName) {\
                UIImage *resizeImage = [[self.themeManager imageWithName:imageName] resizableImageWithCapInsets:self.backgroundImageCapInsets];\
                [self setBackgroundImage:resizeImage forState:state];\
            }
        
        _RFResizableBackgroundImageButtonSetImage(imageName, UIControlStateNormal)
        
        imageName = [NSString stringWithFormat:@"%@_highlighted",backGroundImageName];
        _RFResizableBackgroundImageButtonSetImage(imageName, UIControlStateHighlighted)
        
        imageName = [NSString stringWithFormat:@"%@_disabled",backGroundImageName];
        _RFResizableBackgroundImageButtonSetImage(imageName, UIControlStateDisabled)
        
        imageName = [NSString stringWithFormat:@"%@_selected",backGroundImageName];
        _RFResizableBackgroundImageButtonSetImage(imageName, UIControlStateSelected)
        
        #undef _RFResizableBackgroundImageButtonSetImage
    }
    else if ([backGroundImageName isEqualToString:@""]) {
        [self setBackgroundImage:nil forState:UIControlStateNormal];
        [self setBackgroundImage:nil forState:UIControlStateHighlighted];
        [self setBackgroundImage:nil forState:UIControlStateDisabled];
        [self setBackgroundImage:nil forState:UIControlStateSelected];
    }
}


@end
