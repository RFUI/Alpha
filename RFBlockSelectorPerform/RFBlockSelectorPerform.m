
#import "RFBlockSelectorPerform.h"

@implementation NSObject (RFBlockSelectorPerform)

- (void)rf_performBlockSelector {
    ((void (^)(void))self)();
}

- (void)rf_performBlockSelectorWithSender:(id)sender {
    ((void (^)(id))self)(sender);
}

@end
