
#import "RFTabBarItem.h"

@implementation RFTabBarItem

- (void)prepareForReuse {
    // Nothing
}

- (id)reusingCopy {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    // No longer maintained, just ignore it
    return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
#pragma clang diagnostic pop
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.reuseIdentifier forKey:@keypath(self, reuseIdentifier)];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.reuseIdentifier = [aDecoder decodeObjectForKey:@keypath(self, reuseIdentifier)];
    }
    return self;
}

@end
