
#import "RFTabBarItem.h"

@implementation RFTabBarItem

- (void)prepareForReuse {
    // Nothing
}

- (id)reusingCopy {
    return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
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
