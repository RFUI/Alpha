/*!
    RFTableViewCellHeightDelegate

    Copyright (c) 2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Alpha
 */

/**
 This solution works, and may better than other solutions. But is not perfect, especially when set height asynchronously or cell’s layout is complex.
 */

#import "RFDelegateChain.h"

/**
 The table view’s data source must confirm to RFTableViewCellHeightDataSource.
 */
@protocol RFTableViewCellHeightDataSource <UITableViewDataSource>
@required

- (void)tableView:(UITableView *)tableView configureCell:(id)cell forIndexPath:(NSIndexPath *)indexPath offscreenRendering:(BOOL)isOffscreenRendering;

@optional
// Suggested for better performance. Otherwise, each cell will be created twice.
- (NSString *)tableView:(UITableView *)tableView cellReuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface RFTableViewCellHeightDelegate : RFDelegateChain <
    UITableViewDelegate
>
@property (weak, nonatomic) IBOutlet id<UITableViewDelegate> delegate;
@property (assign, nonatomic) UIEdgeInsets cellLayoutEdgeInsets;

#pragma mark -

- (CGFloat)calculateCellHeightWithCell:(UITableViewCell *)cell tableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;

- (void)updateCellHeightOfCell:(UITableViewCell *)cell;

#pragma mark - Canonical Height
@property (readonly, nonatomic) NSCache *canonicalCellHeight;

- (void)setCanonicalHeight:(CGFloat)height atIndexPath:(NSIndexPath *)indexPath;

- (void)invalidateCanonicalCellHeight;
- (void)invalidateCanonicalCellHeightAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Cache
- (void)invalidateOffscreenCellCache;

@property (assign, nonatomic) IBInspectable BOOL cellHeightCacheEnabled;

- (void)invalidateCellHeightCache;
- (void)invalidateCellHeightCacheAtIndexPath:(NSIndexPath *)indexPath;
- (void)invalidateCellHeightCacheAtIndexPaths:(NSArray *)indexPaths;

- (NSNumber *)cachedHeightAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
