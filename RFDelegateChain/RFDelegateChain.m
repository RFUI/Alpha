
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

RFDelegateChainForwordMethods(super, self.delegate)

@end
