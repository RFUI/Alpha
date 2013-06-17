
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

- (id)initWithMaster:(id<RFPluginSupported>)master {
    self = [super init];
    if (self) {
        self.master = master;
        dispatch_async(dispatch_get_current_queue(), ^{
            [self setup];
        });
    }
    return self;
}

- (void)setup {
#if DEBUG
    @weakify(self);
    dispatch_after_seconds(2.0, ^{
        @strongify(self);
        if (!self) return;
        
        if (self.master == nil) {
            dout_warning(@"%@: master not set yet", self);
        }
    });
#endif
}

- (void)dealloc {
    _dout(@"Dealloc: %@", self)
}

@end
