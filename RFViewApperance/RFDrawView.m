
#import "RFDrawView.h"

@implementation RFDrawView
RFInitializingRootForUIView

- (void)onInit {
    self.opaque = NO;
    self.userInteractionEnabled = NO;
}

-(void)afterInit {
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.color = backgroundColor;
}

- (UIColor *)backgroundColor {
    return self.color;
}

@end
