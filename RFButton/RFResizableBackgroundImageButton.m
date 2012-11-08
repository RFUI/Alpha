//
//  RFResizableBackgroundImageButton.m
//  MIPS
//
//  Created by BB9z on 12-11-6.
//
//

#import "RFResizableBackgroundImageButton.h"

@implementation RFResizableBackgroundImageButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    NSValue *inset = [self valueForKey:RFUDRAkBackgroundImageCapInsets];
    CGRect tmp_inset = CGRectZero;
    [inset getValue:&tmp_inset];

    self.backgroundImageCapInsets = UIEdgeInsetsMake(tmp_inset.origin.x, tmp_inset.origin.y, tmp_inset.size.width, tmp_inset.size.height);
    
    UIImage *image = [self backgroundImageForState:UIControlStateNormal];
    [self setBackgroundImage:[image resizableImageWithCapInsets:self.backgroundImageCapInsets] forState:UIControlStateNormal];
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
