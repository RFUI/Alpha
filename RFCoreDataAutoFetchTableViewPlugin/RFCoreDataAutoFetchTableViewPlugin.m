
#import "RFCoreDataAutoFetchTableViewPlugin.h"

@interface RFCoreDataAutoFetchTableViewPlugin ()
@property (RF_STRONG, readwrite, nonatomic) NSFetchedResultsController *fetchController;
@end

@implementation RFCoreDataAutoFetchTableViewPlugin

- (void)setTableView:(UITableView *)tableView {
    if (_tableView != tableView) {
        [self willChangeValueForKey:@keypath(self, tableView)];
        tableView.coreDataAutoFetchTableViewPlugin = self;
        tableView.dataSource = self;
        _tableView = tableView;
        [self didChangeValueForKey:@keypath(self, tableView)];
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, fetchedResultsController = %@ ,tableView = %p>", [self class], self, self.fetchController, self.tableView];
}

#pragma mark -
- (void)setup {
    [super setup];
    
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
    [self addObserver:self forKeyPath:@keypath(self, request) options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@keypath(self, request.predicate) options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@keypath(self, request.sortDescriptors) options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@keypath(self, managedObjectContext) options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@keypath(self, request)];
    [self removeObserver:self forKeyPath:@keypath(self, request.predicate)];
    [self removeObserver:self forKeyPath:@keypath(self, request.sortDescriptors)];
    [self removeObserver:self forKeyPath:@keypath(self, managedObjectContext)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self) {
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
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
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
    if ([self.master respondsToSelector:@selector(RFCoreDataAutoFetchTableViewPlugin:numberOfRowsBeforeFetchedRowsInSection:)]) {
        return [self.master RFCoreDataAutoFetchTableViewPlugin:self numberOfRowsBeforeFetchedRowsInSection:section];
    }
    return 0;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger extraCount = 0;
    if ([self.master respondsToSelector:@selector(RFCoreDataAutoFetchTableViewPlugin:numberOfRowsBeforeFetchedRowsInSection:)]) {
        extraCount += [self.master RFCoreDataAutoFetchTableViewPlugin:self numberOfRowsBeforeFetchedRowsInSection:section];
    }
    if ([self.master respondsToSelector:@selector(RFCoreDataAutoFetchTableViewPlugin:numberOfRowsAfterFetchedRowsInSection:)]) {
        extraCount += [self.master RFCoreDataAutoFetchTableViewPlugin:self numberOfRowsAfterFetchedRowsInSection:section];
    }
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchController sections][section];
    return [sectionInfo numberOfObjects] + extraCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RFAssert(self.master, @"RFCoreDataAutoFetchTableViewPlugin must have a master.");
        
    UITableViewCell *cell = [self.master RFCoreDataAutoFetchTableViewPlugin:self cellForRowAtIndexPath:indexPath managedObject:[self fetchedObjectAtIndexPath:indexPath]];
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
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if ([self.master respondsToSelector:@selector(tableView:titleForFooterInSection:)]) {
        return [self.master tableView:tableView titleForFooterInSection:section];
    }
    return nil;
}

// Default changed to NO.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.master respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)]) {
        return [self.master tableView:tableView canEditRowAtIndexPath:indexPath];
    }
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.master respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)]) {
        return [self.master tableView:tableView canMoveRowAtIndexPath:indexPath];
    }
    return YES;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if ([self.master respondsToSelector:@selector(sectionIndexTitlesForTableView:)]) {
        return [self sectionIndexTitlesForTableView:tableView];
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    for (id <NSFetchedResultsSectionInfo> sectionInfo in [self.fetchController sections]) {
        if ([[sectionInfo indexTitle] isEqualToString:title]) {
            return [[self.fetchController sections] indexOfObject:sectionInfo];
        }
    }
    
    if ([self.master respondsToSelector:@selector(tableView:sectionForSectionIndexTitle:atIndex:)]) {
        return [self.master tableView:tableView sectionForSectionIndexTitle:title atIndex:index];
    }
    return NSNotFound;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.master respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)]) {
        [self.master tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if ([self.master respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)]) {
        [self.master tableView:tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    }
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

static char RFCoreDataAutoFetchTableViewPluginCateogryProperty;

@implementation UITableView (RFCoreDataAutoFetchTableViewPlugin)
@dynamic coreDataAutoFetchTableViewPlugin;

- (RFCoreDataAutoFetchTableViewPlugin *)coreDataAutoFetchTableViewPlugin {
    return objc_getAssociatedObject(self, &RFCoreDataAutoFetchTableViewPluginCateogryProperty);
}

- (void)setCoreDataAutoFetchTableViewPlugin:(RFCoreDataAutoFetchTableViewPlugin *)coreDataAutoFetchTableViewPlugin {
    if (self.coreDataAutoFetchTableViewPlugin != coreDataAutoFetchTableViewPlugin) {
        [self willChangeValueForKey:@keypath(self, coreDataAutoFetchTableViewPlugin)];
        objc_setAssociatedObject(self, &RFCoreDataAutoFetchTableViewPluginCateogryProperty, coreDataAutoFetchTableViewPlugin, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self didChangeValueForKey:@keypath(self, coreDataAutoFetchTableViewPlugin)];
    }
}

@end
