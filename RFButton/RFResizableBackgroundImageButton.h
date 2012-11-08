//
//  RFResizableBackgroundImageButton.h
//  MIPS
//
//  Created by BB9z on 12-11-6.
//
//

#import "RFUI.h"
#import "RFUIThemeDelegate.h"

@interface RFResizableBackgroundImageButton : UIButton
<RFUIThemeDelegate>

@property (assign, nonatomic) UIEdgeInsets backgroundImageCapInsets;
@property (copy, nonatomic) NSString *backgroundImageName;

- (void)setupBackgroundImageWithName:(NSString *)backGroundImageName;
@end
