
#import "RFTableViewAutoFetchDataSource.h"

static void *const RFCoreDataAutoFetchTableViewPluginKVOContext = (void *)&RFCoreDataAutoFetchTableViewPluginKVOContext;

@interface RFTableViewAutoFetchDataSource ()
@property (strong, readwrite, nonatomic) NSFetchedResultsController *fetchController;
@end

@implementation RFTableViewAutoFetchDataSource

- (void)setTableView:(UITableView *)tableView {
    if (_tableView != tableView) {
        tableView.coreDataAutoFetchTableViewPlugin = self;
        if (tableView.dataSource != self) {
            self.delegate = (id)tableView.dataSource;
        }
        tableView.dataSource = self;
        _tableView = tableView;
        self.fetchController.delegate = (_tableView)?self : nil;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, delegate = %@, fetchedResultsController = %@, tableView = %p>", self.class, self, self.delegate, self.fetchController, self.tableView];
}

#pragma mark -
- (void)afterInit {
    [super afterInit];
    
    [self registObservers];
    [self setupFetchController];
}

- (void)setupFetchController {
    if (self.managedObjectContext && self.request) {
        self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.request managedObjectContext:self.managedObjectContext sectionNameKeyPath:self.fetchSectionNameKeyPath cacheName:self.fetchCacheName];
        self.fetchController.delegate = self;
        [self performFetch];
    }
}

- (void)performFetch {
    if (self.fetchController) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *e = nil;
            BOOL success = [self.fetchController performFetch:&e];
            if (e || !success) {
                dout_error(@"RFCoreDataAutoFetchTableViewPlugin fetch error:%@", e);
            }            
            [self.tableView reloadData];
        });
    }
}

- (void)registObservers {
    [self addObserver:self forKeyPath:@keypath(self, request) options:NSKeyValueObservingOptionNew context:RFCoreDataAutoFetchTableViewPluginKVOContext];
    [self addObserver:self forKeyPath:@keypath(self, request.predicate) options:NSKeyValueObservingOptionNew context:RFCoreDataAutoFetchTableViewPluginKVOContext];
    [self addObserver:self forKeyPath:@keypath(self, request.sortDescriptors) options:NSKeyValueObservingOptionNew context:RFCoreDataAutoFetchTableViewPluginKVOContext];
    [self addObserver:self forKeyPath:@keypath(self, managedObjectContext) options:NSKeyValueObservingOptionNew context:RFCoreDataAutoFetchTableViewPluginKVOContext];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@keypath(self, request) context:RFCoreDataAutoFetchTableViewPluginKVOContext];
    [self removeObserver:self forKeyPath:@keypath(self, request.predicate) context:RFCoreDataAutoFetchTableViewPluginKVOContext];
    [self removeObserver:self forKeyPath:@keypath(self, request.sortDescriptors) context:RFCoreDataAutoFetchTableViewPluginKVOContext];
    [self removeObserver:self forKeyPath:@keypath(self, managedObjectContext) context:RFCoreDataAutoFetchTableViewPluginKVOContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == RFCoreDataAutoFetchTableViewPluginKVOContext && object == self) {
        if ([keyPath isEqualToString:@keypath(self, request)]) {
            if (self.managedObjectContext) {
                [self setupFetchController];
            }
            return;
        }
        
        if ([keyPath isEqualToString:@keypath(self, request.predicate)] ||
            [keyPath isEqualToString:@keypath(self, request.sortDescriptors)]) {
            [self performFetch];
            return;
        }
        
        if ([keyPath isEqualToString:@keypath(self, managedObjectContext)]) {
            if (self.request) {
                [self setupFetchController];
            }
            return;
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (NSManagedObject *)fetchedObjectAtIndexPath:(NSIndexPath *)indexPath {
    return [self.fetchController objectAtIndexPath:[self indexPathForFetchedObjectAtTableIndexPath:indexPath]];
}

- (NSIndexPath *)indexPathForFetchedObjectAtTableIndexPath:(NSIndexPath *)indexPath {
    NSInteger countBefore = [self numberOfRowsBeforeFetchedRowsInSection:indexPath.section];
    if (indexPath.row >= countBefore) {
        return [NSIndexPath indexPathForRow:indexPath.row-countBefore inSection:indexPath.section];
    }
    return nil;
}

- (NSUInteger)numberOfRowsBeforeFetchedRowsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(RFTableViewAutoFetchDataSource:numberOfRowsBeforeFetchedRowsInSection:)]) {
        return [self.delegate RFTableViewAutoFetchDataSource:self numberOfRowsBeforeFetchedRowsInSection:section];
    }
    return 0;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger extraCount = 0;
    if ([self.delegate respondsToSelector:@selector(RFTableViewAutoFetchDataSource:numberOfRowsBeforeFetchedRowsInSection:)]) {
        extraCount += [self.delegate RFTableViewAutoFetchDataSource:self numberOfRowsBeforeFetchedRowsInSection:section];
    }
    if ([self.delegate respondsToSelector:@selector(RFTableViewAutoFetchDataSource:numberOfRowsAfterFetchedRowsInSection:)]) {
        extraCount += [self.delegate RFTableViewAutoFetchDataSource:self numberOfRowsAfterFetchedRowsInSection:section];
    }
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchController sections][section];
    return [sectionInfo numberOfObjects] + extraCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.delegate RFCoreDataAutoFetchTableViewPlugin:self cellForRowAtIndexPath:indexPath managedObject:[self fetchedObjectAtIndexPath:indexPath]];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = [[self.fetchController sections] count];
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchController sections][section];
    return [sectionInfo indexTitle];
}

#pragma mark - Other fallback table view data source

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    for (id <NSFetchedResultsSectionInfo> sectionInfo in [self.fetchController sections]) {
        if ([[sectionInfo indexTitle] isEqualToString:title]) {
            return [[self.fetchController sections] indexOfObject:sectionInfo];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(tableView:sectionForSectionIndexTitle:atIndex:)]) {
        return [self.delegate tableView:tableView sectionForSectionIndexTitle:title atIndex:index];
    }
    return NSNotFound;
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	UITableView *table = self.tableView;
    
    // Convert from fetch indexPath to table indexPath, add rows before.
    NSInteger countBefore = [self numberOfRowsBeforeFetchedRowsInSection:indexPath.section];
    indexPath = [NSIndexPath indexPathForRow:indexPath.row+countBefore inSection:indexPath.section];
    newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row+countBefore inSection:newIndexPath.section];
    
	switch(type) {
		case NSFetchedResultsChangeInsert:
            [table insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			break;
			
		case NSFetchedResultsChangeDelete:
			[table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			break;
			
		case NSFetchedResultsChangeUpdate:
            [table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			break;
			
		case NSFetchedResultsChangeMove:
            [table moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
			break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	UITableView *table = self.tableView;
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
			[table insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
			break;
			
		case NSFetchedResultsChangeDelete:
			[table deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
			break;
            
        case NSFetchedResultsChangeUpdate:
            [table reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            douts(@"NSFetchedResultsChangeMove for section")
            dout(@"%@", sectionInfo)
            dout_int(sectionIndex)
            RFAssert(false, @"need implementation");
            break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView endUpdates];
}

@end

#import <objc/runtime.h>
static char RFCoreDataAutoFetchTableViewPluginCateogryProperty;

@implementation UITableView (RFCoreDataAutoFetchTableViewPlugin)
@dynamic coreDataAutoFetchTableViewPlugin;

- (RFTableViewAutoFetchDataSource *)coreDataAutoFetchTableViewPlugin {
    return objc_getAssociatedObject(self, &RFCoreDataAutoFetchTableViewPluginCateogryProperty);
}

- (void)setCoreDataAutoFetchTableViewPlugin:(RFTableViewAutoFetchDataSource *)coreDataAutoFetchTableViewPlugin {
    if (self.coreDataAutoFetchTableViewPlugin != coreDataAutoFetchTableViewPlugin) {
        objc_setAssociatedObject(self, &RFCoreDataAutoFetchTableViewPluginCateogryProperty, coreDataAutoFetchTableViewPlugin, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end
