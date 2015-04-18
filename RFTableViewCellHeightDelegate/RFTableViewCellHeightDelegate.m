
#import "RFTableViewCellHeightDelegate.h"
#import "dout.h"
#import "UIView+RFAnimate.h"

@interface RFTableViewCellHeightDelegate () <
    UITableViewDelegate
>
@property (strong, nonatomic) NSCache *offscreenCellCache;
@property (strong, nonatomic) NSCache *cellHeightCache;
@property (assign, atomic) BOOL requestNewCellLock;
@property (weak, nonatomic) id lastTableView;
@property (assign, nonatomic) CGFloat lastTableViewWidth;
@property (readwrite, strong, nonatomic) NSCache *canonicalCellHeight;
@end

@implementation RFTableViewCellHeightDelegate
@dynamic delegate;

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
    _cellHeightCacheEnabled = YES;

    _canonicalCellHeight = [NSCache new];
}

#pragma mark - Update Height

- (void)updateCellHeightOfCell:(UITableViewCell *)cell {
    UITableView *tableView = self.lastTableView;
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    if (!indexPath) {
        dout_warning(@"[RFTableViewCellHeightDelegate updateCellHeightOfCell:] can not find cell(%@) in table(%@)", cell, tableView);
        return;
    }

    CGFloat height = [self calculateCellHeightWithCell:cell tableView:tableView atIndexPath:indexPath];
    if (self.cellHeightCacheEnabled) {
        [self.cellHeightCache setObject:@(height) forKey:indexPath];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (CGFloat)calculateCellHeightWithCell:(UITableViewCell *)cell tableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    UIEdgeInsets inset = self.cellLayoutEdgeInsets;

    cell.width = tableView.width;
    dout_debug(@"Calculate cell size for width: %f", cell.width);
    CGFloat contentWidth = cell.contentView.width - inset.left - inset.right;
    cell.contentView.width = contentWidth;
    [cell layoutIfNeeded];

    CGSize size = [cell.contentView systemLayoutSizeFittingSize:CGSizeMake(contentWidth, 0)];
    dout_debug(@"Cell size: %@", NSStringFromCGSize(size));
    CGFloat height = size.height + inset.top + inset.bottom + 1;
    return height;
}

#pragma mark - Canonical Height

- (void)setCanonicalHeight:(CGFloat)height atIndexPath:(NSIndexPath *)indexPath {
    [self.canonicalCellHeight setObject:@(height) forKey:indexPath];
}

- (void)invalidateCanonicalCellHeight {
    [self.canonicalCellHeight removeAllObjects];
}

- (void)invalidateCanonicalCellHeightAtIndexPath:(NSIndexPath *)indexPath {
    [self.canonicalCellHeight removeObjectForKey:indexPath];
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

- (NSNumber *)cachedHeightAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *height = [self.canonicalCellHeight objectForKey:indexPath];
    if (height) {
        return height;
    }

    if (self.cellHeightCacheEnabled) {
        height = [self.cellHeightCache objectForKey:indexPath];
    }
    return height;
}

#pragma mark -

- (UITableViewCell *)tableView:(UITableView *)tableView offscreenCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    BOOL suportCache = [tableView.dataSource respondsToSelector:@selector(tableView:cellReuseIdentifierForRowAtIndexPath:)];
    NSString *cellReuseIdentifier;
    if (suportCache) {
        cellReuseIdentifier = [(id)tableView.dataSource tableView:tableView cellReuseIdentifierForRowAtIndexPath:indexPath];
        if (cellReuseIdentifier) {
            cell = [self.offscreenCellCache objectForKey:cellReuseIdentifier];
            [cell prepareForReuse];
        }
    }

    // No cached cell, ask delegate for an new one.
    if (!cell) {
        self.requestNewCellLock = YES;
        if (cellReuseIdentifier) {
            cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
        }
        else {
            cell = [tableView.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
        }
        if (suportCache) {
            [self.offscreenCellCache setObject:cell forKey:cell.reuseIdentifier];
        }

        // Hide cell created by `dequeueReusableCellWithIdentifier:forIndexPath:` method.
        [cell removeFromSuperview];
        self.requestNewCellLock = NO;
    }
    return cell;
}

#pragma mark - Height

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // A simplified way to check whether the table view width changed.
    if (self.lastTableView != tableView) {
        self.lastTableView = tableView;
        [self invalidateOffscreenCellCache];
    }

    if (self.lastTableViewWidth != tableView.width) {
        self.lastTableViewWidth = tableView.width;
        [self invalidateCellHeightCache];
    }

    NSNumber *height = [self cachedHeightAtIndexPath:indexPath];
    if (height) {
        return [height floatValue];
    }

    if ([self.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        CGFloat height = [self.delegate tableView:tableView heightForRowAtIndexPath:indexPath];
        if (height != UITableViewAutomaticDimension) {
            if (self.cellHeightCacheEnabled) {
                [self.cellHeightCache setObject:@(height) forKey:indexPath];
            }
            return height;
        }
    }

    if (self.requestNewCellLock) {
        return 0;
    }

    // Make duplicated cells deallocated faster.
    @autoreleasepool {
        UITableViewCell *cell = [self tableView:tableView offscreenCellForRowAtIndexPath:indexPath];
        RFAssert(cell, @"Cannot get a cached cell or an new one.");

        [(id)tableView.dataSource tableView:tableView configureCell:cell forIndexPath:indexPath offscreenRendering:YES];
        CGFloat height = [self calculateCellHeightWithCell:cell tableView:tableView atIndexPath:indexPath];
        if (self.cellHeightCacheEnabled) {
            [self.cellHeightCache setObject:@(height) forKey:indexPath];
        }
        return height;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *height = [self cachedHeightAtIndexPath:indexPath];
    if (height) {
        return [height floatValue];
    }

    if ([self.delegate respondsToSelector:@selector(tableView:estimatedHeightForRowAtIndexPath:)]) {
        return [(id<UITableViewDelegate>)self.delegate tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
    }
    return UITableViewAutomaticDimension;
}

@end
