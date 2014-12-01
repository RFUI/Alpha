
#import "RFPlugin.h"
#import "dout.h"

@implementation RFPlugin

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)init {
    self = [super init];
    if (self) {
        [self onInit];
        [self performSelector:@selector(afterInit) withObject:self afterDelay:0];
    }
    return self;
}
#pragma clang diagnostic pop

- (instancetype)initWithMaster:(id<RFPluginSupported>)master {
    self = [super init];
    if (self) {
        self.master = master;
        [self onInit];
        [self performSelector:@selector(afterInit) withObject:self afterDelay:0];
    }
    return self;
}

- (void)onInit {
    // Nothing
}

- (void)afterInit {
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
