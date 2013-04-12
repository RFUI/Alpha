
#import "RFPlugin.h"

@implementation RFPlugin

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setup {
    
#if defined(DEBUG) && DEBUG
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_current_queue(), ^(void){
        if (self.master == nil) {
            dout_warning(@"%@: master not set yet", self)
        }
    });
#endif
}

- (void)dealloc {
    doutwork()
}

@end
