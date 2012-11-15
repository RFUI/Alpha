
#import "RFResizableBackgroundImageButton.h"
#import "RFThemeBundle.h"

@interface RFResizableBackgroundImageButton ()
@property (RF_STRONG, nonatomic) RFThemeBundle *bundle;
@end

@implementation RFResizableBackgroundImageButton

- (void)awakeFromNib {
    _douts(NSStringFromUIEdgeInsets(self.backgroundImageCapInsets));
    UIImage *image = [self backgroundImageForState:UIControlStateNormal];
    [self setBackgroundImage:[image resizableImageWithCapInsets:self.backgroundImageCapInsets] forState:UIControlStateNormal];
    
    [self setBackgroundImageName:self.backgroundImageName];
}

- (void)changeThemeWithBundle:(RFThemeBundle *)themeBundle {
    self.bundle = themeBundle;
    [self setupBackgroundImageWithName:self.backgroundImageName];
}

- (void)applyThemeWithRule:(NSDictionary *)dict {
    if (dict[RFThemeRulekRBIButton_backgroundImageName]) {
        self.backgroundImageName = dict[RFThemeRulekRBIButton_backgroundImageName];
    }
    
    if (dict[RFThemeRulekRBIButton_backgroundImageCapInsets]) {
        self.backgroundImageCapInsets = [dict[RFThemeRulekRBIButton_backgroundImageCapInsets] UIEdgeInsetsValue];
    }
}

- (RFThemeBundle *)bundle {
    if (_bundle) {
        return _bundle;
    }
    else {
        return (RFThemeBundle *)[NSBundle mainBundle];
    }
}

- (void)setupBackgroundImageWithName:(NSString *)backGroundImageName {
    douto(backGroundImageName)
    if (backGroundImageName.length > 0) {
        NSString *type = @"png";

        #define _RFResizableBackgroundImageButtonSetImage(file, state)\
            if (file) {\
                UIImage *resizeImage = [[UIImage imageWithContentsOfFile:file] resizableImageWithCapInsets:self.backgroundImageCapInsets];\
                [self setBackgroundImage:resizeImage forState:state];\
            }
        
        NSString *file = [self.bundle pathForResource:backGroundImageName ofType:type];
        douto(file)
        _RFResizableBackgroundImageButtonSetImage(file, UIControlStateNormal)
        
        file = [self.bundle pathForResource:[NSString stringWithFormat:@"%@_highlighted",backGroundImageName] ofType:type];
        _RFResizableBackgroundImageButtonSetImage(file, UIControlStateHighlighted)
        
        file = [self.bundle pathForResource:[NSString stringWithFormat:@"%@_disabled",backGroundImageName] ofType:type];
        _RFResizableBackgroundImageButtonSetImage(file, UIControlStateDisabled)
        
        file = [self.bundle pathForResource:[NSString stringWithFormat:@"%@_selected",backGroundImageName] ofType:type];
        _RFResizableBackgroundImageButtonSetImage(file, UIControlStateSelected)
        
        #undef _RFResizableBackgroundImageButtonSetImage
    }
    else if ([backGroundImageName isEqualToString:@""]) {
        [self setBackgroundImage:nil forState:UIControlStateNormal];
        [self setBackgroundImage:nil forState:UIControlStateHighlighted];
        [self setBackgroundImage:nil forState:UIControlStateDisabled];
        [self setBackgroundImage:nil forState:UIControlStateSelected];
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
 
*/

@end
