/*!
    RFCoreDataAutoFetchTableViewPlugin
    RFUI

    Copyright (c) 2013 BB9z
    https://github.com/BB9z/Alpha

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

#import "RFUI.h"
#import "RFPlugin.h"
#import <CoreData/CoreData.h>

@class RFCoreDataAutoFetchTableViewPlugin;

@protocol RFCoreDataAutoFetchTableViewPluginDataSource <RFPluginSupported, UITableViewDataSource>
- (UITableViewCell *)RFCoreDataAutoFetchTableViewPlugin:(RFCoreDataAutoFetchTableViewPlugin *)plugin cellForRowAtIndexPath:(NSIndexPath *)indexPath managedObject:(NSManagedObject *)managedObject;

@optional
- (NSInteger)RFCoreDataAutoFetchTableViewPlugin:(RFCoreDataAutoFetchTableViewPlugin *)plugin numberOfRowsBeforeFetchedRowsInSection:(NSInteger)section;

- (NSInteger)RFCoreDataAutoFetchTableViewPlugin:(RFCoreDataAutoFetchTableViewPlugin *)plugin numberOfRowsAfterFetchedRowsInSection:(NSInteger)section;

// Wont call
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;

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

// 
- (NSManagedObject *)fetchedObjectAtIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, assign) BOOL shouldShowNoneDataTips;
@end

@interface UITableView (RFCoreDataAutoFetchTableViewPlugin)
@property (RF_STRONG, nonatomic) RFCoreDataAutoFetchTableViewPlugin *coreDataAutoFetchTableViewPlugin;
@end


