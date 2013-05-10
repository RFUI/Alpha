
#import "RFCheckmarkSelectedTableViewCell.h"

@interface RFCheckmarkSelectedTableViewCell ()

@end

@implementation RFCheckmarkSelectedTableViewCell

- (void)setOn:(BOOL)on {
    if (_on != on) {
        [self willChangeValueForKey:@keypath(self, on)];
        _on = on;
        self.accessoryType = (on)? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        [self didChangeValueForKey:@keypath(self, on)];
    }
}

@end
