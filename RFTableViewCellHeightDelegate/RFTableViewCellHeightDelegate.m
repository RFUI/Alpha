
#import "RFTableViewCellHeightDelegate.h"
#import "dout.h"
#import "UIView+RFAnimate.h"

@interface RFTableViewCellHeightDelegate ()
@property (strong, nonatomic) NSMutableDictionary *offscreenCells;
@property (assign, atomic) BOOL requestNewCellLock;
@end

@implementation RFTableViewCellHeightDelegate

#pragma mark - Cache management

- (void)onInit {
    _cellLayoutEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    _offscreenCells = [NSMutableDictionary dictionaryWithCapacity:5];
}

- (void)setDelegate:(id<RFTableViewCellHeightDelegate>)delegate {
    if (self.delegate != delegate) {
        [self resetOffscreenCellsCache];
    }
    [super setDelegate:delegate];
}

- (void)resetOffscreenCellsCache {
    [self.offscreenCells removeAllObjects];
}

#pragma mark -

- (UITableViewCell *)tableView:(UITableView *)tableView offscreenCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    BOOL suportCache = [self.delegate respondsToSelector:@selector(tableView:cellReuseIdentifierForRowAtIndexPath:)];
    if (suportCache) {
        NSString *cellReuseIdentifier = [self.delegate tableView:tableView cellReuseIdentifierForRowAtIndexPath:indexPath];
        if (cellReuseIdentifier) {
            cell = self.offscreenCells[cellReuseIdentifier];
        }
    }

    // No cached cell, ask delegate for an new one.
    if (!cell) {
        self.requestNewCellLock = YES;
        cell = [self.delegate tableView:tableView cellForRowAtIndexPath:indexPath];
        if (suportCache) {
            [self.offscreenCells setObject:cell forKey:cell.reuseIdentifier];
        }

        // Hide cell created by `dequeueReusableCellWithIdentifier:forIndexPath:` method.
        cell.hidden = YES;
        self.requestNewCellLock = NO;
    }
    return cell;
}

#pragma mark - Height

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.requestNewCellLock) {
        return 0;
    }

    // Make duplicated cells deallocated faster.
    @autoreleasepool {
        UITableViewCell *cell = [self tableView:tableView offscreenCellForRowAtIndexPath:indexPath];
        RFAssert(cell, @"Cannot get a cached cell or an new one.");

        [self.delegate tableView:tableView configureCell:cell forIndexPath:indexPath];

        UIEdgeInsets inset = self.cellLayoutEdgeInsets;

        cell.width = tableView.width;
        CGFloat contentWidth = cell.contentView.width - inset.left - inset.right;
        cell.contentView.width = contentWidth;
        [cell layoutIfNeeded];

        CGSize size = [cell.contentView systemLayoutSizeFittingSize:CGSizeMake(contentWidth, 0)];
        _dout_size(size)
        CGFloat height = size.height;
        
        return height + 1.f + inset.top + inset.bottom;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:estimatedHeightForRowAtIndexPath:)]) {
        return [(id<UITableViewDelegate>)self.delegate tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
    }
    return UITableViewAutomaticDimension;
}

@end
