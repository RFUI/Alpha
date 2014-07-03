/*!
    RFTableViewCoreDataAutoFetchDataSource
    RFUI

    Copyright (c) 2013-2014 BB9z
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

#import "RFDelegateChain.h"
#import <CoreData/CoreData.h>

@class RFTableViewAutoFetchDataSource;

@protocol RFTableViewAutoFetchDataSource <UITableViewDataSource>

@required
- (UITableViewCell *)RFCoreDataAutoFetchTableViewPlugin:(RFTableViewAutoFetchDataSource *)plugin cellForRowAtIndexPath:(NSIndexPath *)indexPath managedObject:(NSManagedObject *)managedObject;

@optional
- (NSInteger)RFTableViewAutoFetchDataSource:(RFTableViewAutoFetchDataSource *)plugin numberOfRowsBeforeFetchedRowsInSection:(NSInteger)section;

- (NSInteger)RFTableViewAutoFetchDataSource:(RFTableViewAutoFetchDataSource *)plugin numberOfRowsAfterFetchedRowsInSection:(NSInteger)section;

// Wont call
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;

@end

@interface RFTableViewAutoFetchDataSource : RFDelegateChain <NSFetchedResultsControllerDelegate, UITableViewDataSource
>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet id<RFTableViewAutoFetchDataSource> delegate;

@property (strong, readonly, nonatomic) NSFetchedResultsController *fetchController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchRequest *request;

@property (copy, nonatomic) NSString *fetchCacheName;
@property (copy, nonatomic) NSString *fetchSectionNameKeyPath;

// 
- (NSManagedObject *)fetchedObjectAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface UITableView (RFCoreDataAutoFetchTableViewPlugin)
@property (strong, nonatomic) RFTableViewAutoFetchDataSource *coreDataAutoFetchTableViewPlugin;
@end

