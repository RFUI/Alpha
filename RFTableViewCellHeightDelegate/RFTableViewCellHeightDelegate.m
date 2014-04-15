
#import "RFTableViewCellHeightDelegate.h"
#import "dout.h"

@interface RFTableViewCellHeightDelegate ()
@property (assign, atomic) BOOL cellCalculateLock;
@end

@implementation RFTableViewCellHeightDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Make duplicated cells deallocated faster.
    @autoreleasepool {
        CGFloat height = 0;
        if (!self.cellCalculateLock) {
            self.cellCalculateLock = YES;
            UITableViewCell *cell = [self.delegate tableView:tableView cellForRowAtIndexPath:indexPath];
            self.cellCalculateLock = NO;

            if (cell) {
                [self.delegate tableView:tableView configureCell:cell forIndexPath:indexPath];

                CGFloat leftEdge = 0;
                CGFloat rightEdge = 0;

                if (cell.accessoryType != UITableViewCellAccessoryNone) {
                    rightEdge = 33.f;
                }

                CGRect frame = cell.frame;
                frame.size.width = cell.contentView.bounds.size.width - leftEdge - rightEdge;
                cell.contentView.frame = frame;

                [cell layoutIfNeeded];

                CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
                _dout_size(size)
                height = size.height;

                cell.hidden = YES;
            }
        }
        return height + 1.f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:estimatedHeightForRowAtIndexPath:)]) {
        return [(id<UITableViewDelegate>)self.delegate tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
    }
    return UITableViewAutomaticDimension;
}

@end
