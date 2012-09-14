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

@interface RFFetchedResultsTableViewController : UITableViewController
<NSFetchedResultsControllerDelegate>

@property (RF_STRONG, readonly, nonatomic) NSFetchedResultsController *fetchController;
@property (RF_STRONG, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (RF_STRONG, nonatomic) NSFetchRequest *request;

@property (copy, nonatomic) NSString *fetchCacheName;
@property (copy, nonatomic) NSString *fetchSectionNameKeyPath;


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
