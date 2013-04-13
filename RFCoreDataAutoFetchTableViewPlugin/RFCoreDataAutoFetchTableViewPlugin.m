
#import "RFCoreDataAutoFetchTableViewPlugin.h"

@interface RFCoreDataAutoFetchTableViewPlugin ()
@property (RF_STRONG, readwrite, nonatomic) NSFetchedResultsController *fetchController;

@end

@implementation RFCoreDataAutoFetchTableViewPlugin

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
            [self.fetchController performFetch:&e];
            if (e) douto(e);
            
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
    NSInteger countBefore = 0;
    if ([self.master respondsToSelector:@selector(RFCoreDataAutoFetchTableViewPlugin:numberOfRowsBeforeFetchedRowsInSection:)]) {
        countBefore = [self.master RFCoreDataAutoFetchTableViewPlugin:self numberOfRowsBeforeFetchedRowsInSection:indexPath.section];
    }
    
    if (indexPath.row >= countBefore) {
        return [self.fetchController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-countBefore inSection:indexPath.section]];
    }
    return nil;
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.master) return nil;
        
    UITableViewCell *cell = [self.master RFCoreDataAutoFetchTableViewPlugin:self cellForRowAtIndexPath:indexPath managedObject:[self fetchedObjectAtIndexPath:indexPath]];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = [[self.fetchController sections] count];
    return count;
}

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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchController sections][section];
    return [sectionInfo indexTitle];
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	UITableView *table = self.tableView;
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[table insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			break;
			
		case NSFetchedResultsChangeDelete:
			[table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			break;
			
		case NSFetchedResultsChangeUpdate:
            [table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			break;
			
		case NSFetchedResultsChangeMove:
            [table moveRowAtIndexPath:[NSArray arrayWithObject:indexPath] toIndexPath:[NSArray arrayWithObject:newIndexPath]];
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
        objc_setAssociatedObject(self, &RFCoreDataAutoFetchTableViewPluginCateogryProperty, coreDataAutoFetchTableViewPlugin, OBJC_ASSOCIATION_ASSIGN);
        if (coreDataAutoFetchTableViewPlugin) {
            coreDataAutoFetchTableViewPlugin.tableView = self;
            if (!self.dataSource) {
                self.dataSource = coreDataAutoFetchTableViewPlugin;
            }
        }
        [self didChangeValueForKey:@keypath(self, coreDataAutoFetchTableViewPlugin)];
    }
}

@end
