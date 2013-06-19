//
//  ViewController.h
//  RFPullToFetchTableView
//
//  Created by BB9z on 13-6-18.
//  Copyright (c) 2013年 RFUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFSidePanel.h"
#import "RFPullToFetchTableView.h"

@interface ViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet RFPullToFetchTableView *tableView;

@property (assign, nonatomic) int pageSize;
@property (assign, nonatomic) int currentPageIndex;
@property (assign, nonatomic) BOOL reachEnd;
@end
