
#import "RFPlugin.h"

@implementation RFPlugin

- (id)init {
    self = [super init];
    if (self) {        
        dispatch_async(dispatch_get_current_queue(), ^{
            [self setup];
        });
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setup {
#if DEBUG
    __weak __typeof(&*self)weakSelf = self;
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_current_queue(), ^(void){
        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
        if (!strongSelf) return;
        
        if (strongSelf.master == nil) {
            dout_warning(@"%@: master not set yet", strongSelf)
        }
    });
#endif
}

- (void)dealloc {
    _dout(@"Dealloc: %@", self)
}

@end
