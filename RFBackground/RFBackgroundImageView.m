
#import "RFBackgroundImageView.h"

@implementation RFBackgroundImageView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.image = [self.image resizableImageWithCapInsets:self.resizeCapInsets];
}

@end
