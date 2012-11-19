
#import "RFResizableBackgroundImageButton.h"
#import "RFThemeBundle.h"
#import "RFUIThemeManager.h"

@interface RFResizableBackgroundImageButton ()
@property (RF_STRONG, nonatomic) RFThemeBundle *bundle;
@end

@implementation RFResizableBackgroundImageButton

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
        [[NSNotificationCenter defaultCenter] addObserverForName:MSGRFUIThemeChange object:nil queue:nil usingBlock:^(NSNotification *note) {
            NSDictionary *rule = [self.themeManager themeRuleForKey:[self RFUIThemeRuleKey]];
            [self applyThemeWithRule:rule];
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
    if (dict[RFThemeRulekRBIButton_backgroundImageCapInsets]) {
        self.backgroundImageCapInsets = UIEdgeInsetsFromString(dict[RFThemeRulekRBIButton_backgroundImageCapInsets]);
    }
    if (dict[RFThemeRulekRBIButton_backgroundImageName]) {
        self.backgroundImageName = dict[RFThemeRulekRBIButton_backgroundImageName];
    }
    if (dict[RFThemeRulekRBIButton_showsTouchWhenHighlighted]) {
        self.showsTouchWhenHighlighted = [dict[RFThemeRulekRBIButton_showsTouchWhenHighlighted] boolValue];
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
