/*!
    RFCoreDataAutoFetchTableViewPlugin
    RFUI

    Copyright (c) 2013 BB9z
    http://github.com/bb9z/RFKit

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php
 
    Alpha
 */

/**
 Advice
 ----
 
 ViewController should retain plugin.
 Set plugin´s tableView property, not tableView´s.
 
 */

#import "RFPlugin.h"
#import <CoreData/CoreData.h>

@class RFCoreDataAutoFetchTableViewPlugin;

@protocol RFCoreDataAutoFetchTableViewPluginDataSource <RFPluginSupported>
- (UITableViewCell *)RFCoreDataAutoFetchTableViewPlugin:(RFCoreDataAutoFetchTableViewPlugin *)plugin cellForRowAtIndexPath:(NSIndexPath *)indexPath managedObject:(NSManagedObject *)managedObject;

@optional
- (NSInteger)RFCoreDataAutoFetchTableViewPlugin:(RFCoreDataAutoFetchTableViewPlugin *)plugin numberOfRowsBeforeFetchedRowsInSection:(NSInteger)section;

- (NSInteger)RFCoreDataAutoFetchTableViewPlugin:(RFCoreDataAutoFetchTableViewPlugin *)plugin numberOfRowsAfterFetchedRowsInSection:(NSInteger)section;

@end

@interface RFCoreDataAutoFetchTableViewPlugin : RFPlugin
<NSFetchedResultsControllerDelegate, UITableViewDataSource>

@property (RF_WEAK, nonatomic) IBOutlet UITableView *tableView;
@property (RF_WEAK, nonatomic) IBOutlet id<RFCoreDataAutoFetchTableViewPluginDataSource> master;

@property (RF_STRONG, readonly, nonatomic) NSFetchedResultsController *fetchController;
@property (RF_STRONG, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (RF_STRONG, nonatomic) NSFetchRequest *request;

@property (copy, nonatomic) NSString *fetchCacheName;
@property (copy, nonatomic) NSString *fetchSectionNameKeyPath;

@property (copy, nonatomic) void (^cellConfigureBlock)(UITableViewCell *cell,  NSIndexPath *indexPath);

/**
 If this block was set, cellConfigureBlock won`t call in tableView:cellForRowAtIndexPath:.
 But cellConfigureBlock will still call when fetch result change.
 */
@property (copy, nonatomic) UITableViewCell *(^cellForRowAtIndexPathBlock)(UITableView *tableView,  NSIndexPath *indexPath);


@end

@interface UITableView (RFCoreDataAutoFetchTableViewPlugin)
@property (RF_STRONG, nonatomic) RFCoreDataAutoFetchTableViewPlugin *coreDataAutoFetchTableViewPlugin;
@end

