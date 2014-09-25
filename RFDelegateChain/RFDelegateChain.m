
#import "RFDelegateChain.h"

@implementation RFDelegateChain
RFInitializingRootForNSObject

- (void)onInit {
    // Nothing
}

- (void)afterInit {
    // Nothing
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, delegate = %@>", self.class, self, self.delegate];
}

- (void)setDelegate:(id)delegate {
    if (delegate != self) {
        _delegate = delegate;
    }
    else {
        dout_debug(@"Try set %@ delegtate to itself, ignored.", self);
    }
}

RFDelegateChainForwardMethods(super, self.delegate)

@end
