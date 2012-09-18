
#import "RFFetchedResultsTableViewController.h"

@interface RFFetchedResultsTableViewController ()
@property (RF_STRONG, readwrite, nonatomic) NSFetchedResultsController *fetchController;

@end

@implementation RFFetchedResultsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupFetchController];
    
    [self addObserver:self forKeyPath:@"request" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"request.predicate" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"request.sortDescriptors" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"managedObjectContext" options:NSKeyValueObservingOptionNew context:NULL];
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

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"request"];
    [self removeObserver:self forKeyPath:@"request.predicate"];
    [self removeObserver:self forKeyPath:@"request.sortDescriptors"];
    [self removeObserver:self forKeyPath:@"managedObjectContext"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"request"]) {
        if (self.managedObjectContext) {
            [self setupFetchController];
        }
        return;
    }
    
    if ([keyPath isEqualToString:@"request.predicate"] ||
        [keyPath isEqualToString:@"request.sortDescriptors"]) {
        [self performFetch];
        return;
    }
    
    if ([keyPath isEqualToString:@"managedObjectContext"]) {
        [self setupFetchController];
        return;
    }

    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.cellForRowAtIndexPathBlock) {
        return self.cellForRowAtIndexPathBlock(tableView, indexPath);
    }
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (self.cellConfigureBlock) {
        self.cellConfigureBlock(cell, indexPath);
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = [[self.fetchController sections] count];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	UITableView *table = self.tableView;
	[table beginUpdates];
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
			if (self.cellConfigureBlock) {
                self.cellConfigureBlock([table cellForRowAtIndexPath:indexPath], indexPath);
            }
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
			[table insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[table deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
            
        case NSFetchedResultsChangeUpdate:
            break;
            
        case NSFetchedResultsChangeMove:
            break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	UITableView *table = self.tableView;
	[table endUpdates];
}


@end
