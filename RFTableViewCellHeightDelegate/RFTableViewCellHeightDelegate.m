
#import "RFTableViewCellHeightDelegate.h"
#import "dout.h"
#import "UIView+RFAnimate.h"

@interface RFTableViewCellHeightDelegate ()
@property (strong, nonatomic) NSCache *offscreenCellCache;
@property (strong, nonatomic) NSCache *cellHeightCache;
@property (assign, atomic) BOOL requestNewCellLock;
@property (weak, nonatomic) id lastTableView;
@property (assign, nonatomic) CGFloat lastTableViewWidth;
@end

@implementation RFTableViewCellHeightDelegate

#pragma mark - Cache management

- (void)onInit {
    [super onInit];

    _cellLayoutEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    NSCache *occ = [[NSCache alloc] init];
    occ.name = @"com.github.RFUI.RFTableViewCellHeightDelegate.offscreenCellCache";
    _offscreenCellCache = occ;

    NSCache *chc = [[NSCache alloc] init];
    chc.name = @"com.github.RFUI.RFTableViewCellHeightDelegate.cellHeightCache";
    _cellHeightCache = chc;
}

- (void)setDelegate:(id<RFTableViewCellHeightDelegate>)delegate {
    if (self.delegate != delegate) {
        [self invalidateOffscreenCellCache];
        [self invalidateCellHeightCache];
    }
    [super setDelegate:delegate];
}

#pragma mark - Cache

- (void)invalidateOffscreenCellCache {
    [self.offscreenCellCache removeAllObjects];
}

- (void)invalidateCellHeightCache {
    [self.cellHeightCache removeAllObjects];
}

- (void)invalidateCellHeightCacheAtIndexPath:(NSIndexPath *)indexPath {
    [self.cellHeightCache removeObjectForKey:indexPath];
}

- (void)invalidateCellHeightCacheAtIndexPaths:(NSArray *)indexPaths {
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath* obj, NSUInteger idx, BOOL *stop) {
        [self.cellHeightCache removeObjectForKey:obj];
    }];
}

#pragma mark -

- (UITableViewCell *)tableView:(UITableView *)tableView offscreenCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    BOOL suportCache = [self.delegate respondsToSelector:@selector(tableView:cellReuseIdentifierForRowAtIndexPath:)];
    if (suportCache) {
        NSString *cellReuseIdentifier = [self.delegate tableView:tableView cellReuseIdentifierForRowAtIndexPath:indexPath];
        if (cellReuseIdentifier) {
            cell = [self.offscreenCellCache objectForKey:cellReuseIdentifier];
            [cell prepareForReuse];
        }
    }

    // No cached cell, ask delegate for an new one.
    if (!cell) {
        self.requestNewCellLock = YES;
        cell = [self.delegate tableView:tableView cellForRowAtIndexPath:indexPath];
        if (suportCache) {
            [self.offscreenCellCache setObject:cell forKey:cell.reuseIdentifier];
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

    // A simplified way to check whether the table view width changed.
    if (self.lastTableView != tableView) {
        self.lastTableView = tableView;
        [self invalidateOffscreenCellCache];
    }

    if (self.lastTableViewWidth != tableView.width) {
        self.lastTableViewWidth = tableView.width;
        [self invalidateCellHeightCache];
    }

    NSNumber *heightCache = [self.cellHeightCache objectForKey:indexPath];
    if (heightCache) {
        dout_debug(@"Return cached height: %@", heightCache);
        return [heightCache floatValue];
    }

    // Make duplicated cells deallocated faster.
    @autoreleasepool {
        UITableViewCell *cell = [self tableView:tableView offscreenCellForRowAtIndexPath:indexPath];
        RFAssert(cell, @"Cannot get a cached cell or an new one.");

        [self.delegate tableView:tableView configureCell:cell forIndexPath:indexPath offscreenRendering:YES];

        UIEdgeInsets inset = self.cellLayoutEdgeInsets;

        cell.width = tableView.width;
        dout_debug(@"Calculate cell size for width: %f", cell.width);
        CGFloat contentWidth = cell.contentView.width - inset.left - inset.right;
        cell.contentView.width = contentWidth;
        [cell layoutIfNeeded];

        CGSize size = [cell.contentView systemLayoutSizeFittingSize:CGSizeMake(contentWidth, 0)];
        dout_debug(@"Cell size: %@", NSStringFromCGSize(size));
        CGFloat height = size.height + 1.f + inset.top + inset.bottom;
        [self.cellHeightCache setObject:@(height) forKey:indexPath];
        return height;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:estimatedHeightForRowAtIndexPath:)]) {
        return [(id<UITableViewDelegate>)self.delegate tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
    }
    return UITableViewAutomaticDimension;
}

@end
