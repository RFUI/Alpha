/*!
    RFResizableBackgroundImageButton
    RFUI

    Copyright (c) 2012 BB9z
    http://github.com/bb9z/RFKit

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php
 */

#import "RFUI.h"
#import "RFUITheme.h"

@interface RFResizableBackgroundImageButton : UIButton
<RFUIThemeDelegate>
@property (RF_STRONG, nonatomic) RFUIThemeManager *themeManager;

@property (assign, nonatomic) UIEdgeInsets backgroundImageCapInsets;
@property (copy, nonatomic) NSString *backgroundImageName;

- (void)setupBackgroundImageWithName:(NSString *)backGroundImageName;
@end

