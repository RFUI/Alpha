
#import "RFCheckmarkSelectedTableViewCell.h"

@interface RFCheckmarkSelectedTableViewCell ()

@end

@implementation RFCheckmarkSelectedTableViewCell

- (void)setOn:(BOOL)on {
    if (_on != on) {
        _on = on;
        self.accessoryType = (on)? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
}

@end
