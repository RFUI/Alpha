/*!
    RFTableViewCellHeightDelegate

    Copyright (c) 2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Alpha
 */

/**
 
 This solution works, and may better than other solutions. But is not perfect, especially when a table view’s frame changed.

 Caution: 
 
 Table view’s data source should not call `dequeueReusableCellWithIdentifier:forIndexPath:` in `tableView:cellForRowAtIndexPath:`. Instead, you can use `dequeueReusableCellWithIdentifier:`.
 `dequeueReusableCellWithIdentifier:forIndexPath:` will creat duplicated cells which can not be released until the table view deallocated.
 */

#import "RFDelegateChain.h"

@protocol RFTableViewCellHeightDelegate <UITableViewDataSource>
@required

- (void)tableView:(UITableView *)tableView configureCell:(id)cell forIndexPath:(NSIndexPath *)indexPath offscreenRendering:(BOOL)isOffscreenRendering;

@optional
// Suggested for better performance. Otherwise, each cell will be created twice.
- (NSString *)tableView:(UITableView *)tableView cellReuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface RFTableViewCellHeightDelegate : RFDelegateChain <
    UITableViewDelegate
>
@property (weak, nonatomic) IBOutlet id<RFTableViewCellHeightDelegate> delegate;
@property (assign, nonatomic) UIEdgeInsets cellLayoutEdgeInsets;

#pragma mark - Cache
- (void)resetOffscreenCellsCache;

- (void)resetCellHeightCache;
- (void)invalidateCellHeightCacheAtIndexPath:(NSIndexPath *)indexPath;
- (void)invalidateCellHeightCacheAtIndexPaths:(NSArray *)indexPaths;
@end
