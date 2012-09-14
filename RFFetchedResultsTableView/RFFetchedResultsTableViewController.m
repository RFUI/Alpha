//
//  RFFetchedResultsTableViewController.m
//  MIPS
//
//  Created by BB9z on 12-9-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RFFetchedResultsTableViewController.h"

@interface RFFetchedResultsTableViewController ()
@property (RF_STRONG, readwrite, nonatomic) NSFetchedResultsController *fetchController;

@end

@implementation RFFetchedResultsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.managedObjectContext && self.request) {
        self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.request managedObjectContext:self.managedObjectContext sectionNameKeyPath:self.fetchSectionNameKeyPath cacheName:self.fetchCacheName];
        self.fetchController.delegate = self;
        [self performFetch];
    }
    
    [self addObserver:self forKeyPath:@"request" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"request.predicate" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"request.sortDescriptors" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"managedObjectContext" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)performFetch {
    if (self.fetchController) {
        NSError *e = nil;
        [self.fetchController performFetch:&e];
        if (e) douto(e);
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
            self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.request managedObjectContext:self.managedObjectContext sectionNameKeyPath:self.fetchSectionNameKeyPath cacheName:self.fetchCacheName];
            [self performFetch];
        }
        return;
    }
    
    if ([keyPath isEqualToString:@"request.predicate"] ||
        [keyPath isEqualToString:@"request.sortDescriptors"]) {
        [self performFetch];
        return;
    }
    
    if ([keyPath isEqualToString:@"managedObjectContext"]) {
        if (self.request) {
            self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.request managedObjectContext:self.managedObjectContext sectionNameKeyPath:self.fetchSectionNameKeyPath cacheName:self.fetchCacheName];
            [self performFetch];
        }
        return;
    }

    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
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
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
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
			[self configureCell:[table cellForRowAtIndexPath:indexPath] atIndexPath:newIndexPath];
			break;
			
		case NSFetchedResultsChangeMove:
//			[table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            [table insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
	[table endUpdates];
}


@end
