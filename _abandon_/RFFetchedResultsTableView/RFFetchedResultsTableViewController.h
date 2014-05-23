/*!
    RFFetchedResultsTableViewController
    RFUI

    Copyright (c) 2012 BB9z
    http://github.com/bb9z/RFKit

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php
 */


#import "RFUI.h"
#import <CoreData/CoreData.h>

DEPRECATED_ATTRIBUTE @interface RFFetchedResultsTableViewController : UITableViewController
<NSFetchedResultsControllerDelegate>

@property (RF_STRONG, readonly, nonatomic) NSFetchedResultsController *fetchController DEPRECATED_ATTRIBUTE;
@property (RF_STRONG, nonatomic) NSManagedObjectContext *managedObjectContext DEPRECATED_ATTRIBUTE;
@property (RF_STRONG, nonatomic) NSFetchRequest *request DEPRECATED_ATTRIBUTE;

@property (copy, nonatomic) NSString *fetchCacheName DEPRECATED_ATTRIBUTE;
@property (copy, nonatomic) NSString *fetchSectionNameKeyPath DEPRECATED_ATTRIBUTE;

@property (copy, nonatomic) void (^cellConfigureBlock)(UITableViewCell *cell,  NSIndexPath *indexPath) DEPRECATED_ATTRIBUTE;

/**
 If this block was set, cellConfigureBlock won`t call in tableView:cellForRowAtIndexPath:.
 But cellConfigureBlock will still call when fetch result change.
 */
@property (copy, nonatomic) UITableViewCell *(^cellForRowAtIndexPathBlock)(UITableView *tableView,  NSIndexPath *indexPath) DEPRECATED_ATTRIBUTE;
@end
