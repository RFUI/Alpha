
#import "RFDrawView.h"

@implementation RFDrawView
RFInitializingRootForUIView

- (void)onInit {
    [super setBackgroundColor:[UIColor clearColor]];
    self.opaque = NO;
}

-(void)afterInit {
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.color = backgroundColor;
}

@end
