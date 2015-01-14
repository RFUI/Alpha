
#import "UITableView+RFTableViewCellHeight.h"

@implementation UITableView (RFTableViewCellHeight)

- (id)rf_dequeueReusableCellWithIdentifier:(NSString *)identifier {
    UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:identifier];
    CGFloat tableWidth = CGRectGetWidth(cell.bounds);
    CGRect cellBounds = cell.bounds;
    if (cellBounds.size.width != tableWidth) {
        cellBounds.size.width = tableWidth;
        cell.bounds = cellBounds;
        [cell layoutIfNeeded];
    }
    return (id)cell;
}

@end
