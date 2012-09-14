/*!
    RFFetchedResultsTableView
    RFUI

    Copyright (c) 2012 BB9z
    http://github.com/bb9z/RFKit

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php
 */


#import "RFUI.h"
#import <CoreData/CoreData.h>

@interface RFFetchedResultsTableView : UITableView
<NSFetchedResultsControllerDelegate, UITableViewDataSource>

@property (RF_STRONG, readonly, nonatomic) NSFetchedResultsController *fetchController;
@property (RF_STRONG, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (RF_STRONG, nonatomic) NSFetchRequest *request;

@property (copy, nonatomic) NSString *fetchCacheName;
@property (copy, nonatomic) NSString *fetchSectionNameKeyPath;

@property (copy, nonatomic) void (^cellConfigureBlock)(UITableViewCell *cell,  NSIndexPath *indexPath);
@end
