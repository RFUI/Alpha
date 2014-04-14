
#import "RFDelegateChain.h"

@protocol RFTableViewCellHeightDelegate <UITableViewDelegate>
@required

- (UITableViewCell *)tableView:(UITableView *)tableView configCellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface RFTableViewCellHeightDelegate : RFDelegateChain <
    UITableViewDelegate
>


@end
