//
//  ViewController.m
//  RFPullToFetchTableView
//
//  Created by BB9z on 13-6-18.
//  Copyright (c) 2013年 RFUI. All rights reserved.
//

#import "ViewController.h"
#import "ConfigViewController.h"

NSTimeInterval DebugFetchDelay = 1;
int DebugMaxItemCount = 20;

@interface ViewController ()
// We don not use reall data.
@property (assign, nonatomic) int cellCount;

@property (strong, nonatomic) UILabel *headerView;
@property (strong, nonatomic) UILabel *footerView;
@end

@implementation ViewController
RFUIInterfaceOrientationSupportAll

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupPanel];
    [self setupPullToFetchDisplay];
    [self setupPullToFetchData];
    
    self.pageSize = 3;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    dispatch_after_seconds(1, ^{
        [self.tableView triggerHeaderProccess];
    });
}

- (void)setupPanel {
    RFSidePanel *sp = [[RFSidePanel alloc] initWithNibName:@"RFSidePanel" bundle:nil];
    sp.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    CGRect frame = self.view.bounds;
    frame.size.width = 200;
    sp.view.frame = frame;
    [self addChildViewController:sp intoView:self.view];
    [sp hide:NO];
    
    ConfigViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifierUsingClass:[ConfigViewController class]];
    cvc.master = self;
    sp.rootViewController = cvc;
}

- (void)setupPullToFetchDisplay {
    self.headerView = (UILabel *)self.tableView.tableHeaderView;
    self.tableView.tableHeaderView = nil;
    
    self.tableView.headerContainer = self.headerView;
    [self.tableView addSubview:self.headerView];
    
    @weakify(self);
    [self.tableView setHeaderVisibleChangeBlock:^(BOOL isVisible, CGFloat visibleHeight, BOOL isCompleteVisible, BOOL isProccessing) {
        dout(@"header visible = %@", @(isVisible))
        @strongify(self);

        if (isProccessing) {
            self.headerView.text = @"Refreshing...";
            return;
        }
        
        if (isCompleteVisible) {
            self.headerView.text = @"Release to refresh.";
            return;
        }
        
        if (isVisible) {
            self.headerView.text = @"Pull to refresh.";
        }
    }];
    
    
    self.footerView = (UILabel *)self.tableView.tableFooterView;
    self.tableView.tableFooterView = nil;
    
    self.tableView.footerContainer = self.footerView;
    [self.tableView addSubview:self.footerView];
    
    [self.tableView setFooterVisibleChangeBlock:^(BOOL isVisible, CGFloat visibleHeight, BOOL isCompleteVisible, BOOL isProccessing, BOOL reachEnd) {
        dout(@"footer visible = %@", @(isVisible))

        @strongify(self);
        if (reachEnd) {
            self.footerView.text = @"No more";
            return;
        }
        
        if (isProccessing) {
            self.footerView.text = @"Loading...";
            return;
        }
        
        if (isCompleteVisible) {
            self.footerView.text = @"Release to load more.";
            return;
        }
        
        if (isVisible) {
            self.footerView.text = @"Pull to load more.";
        }
    }];
}

- (void)setupPullToFetchData {
    [self.tableView setHeaderProccessBlock:^{
        self.cellCount = 0;
        
        dispatch_after_seconds(DebugFetchDelay, ^{
            self.cellCount = self.pageSize;
            [self.tableView headerProccessFinshed];
        });
    }];
    
    [self.tableView setFooterProccessBlock:^{
        dispatch_after_seconds(DebugFetchDelay, ^{
            self.cellCount += self.pageSize;
            [self.tableView footerProccessFinshed];
        });
    }];
}

#pragma mark - TableView data
- (void)setCellCount:(int)cellCount {
    if (DebugMaxItemCount && cellCount > DebugMaxItemCount) {
        self.tableView.footerReachEnd = YES;
        cellCount = DebugMaxItemCount;
    }
    
    if (_cellCount != cellCount) {
        int orgCount = _cellCount;
        dout_int(_cellCount)
        dout_int(cellCount)
        
        _cellCount = cellCount;
        
        if (cellCount > orgCount) {
            [self.tableView insertRowsAtIndexPaths:[self indexPathsForRange:(NSRange){orgCount, ABS(cellCount-orgCount)}] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            [self.tableView deleteRowsAtIndexPaths:[self indexPathsForRange:(NSRange){fminf(orgCount, cellCount), ABS(cellCount-orgCount)}] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

- (NSArray *)indexPathsForRange:(NSRange)range {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:range.length];
    for (int i = 0; i < range.length; i++) {
        [array addObject:[NSIndexPath indexPathForRow:range.location+i inSection:0]];
    }
    return array;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = [@(indexPath.row) stringValue];
    return cell;
}

@end
