/*
 RFTabBar
 RFUI

 Copyright (c) 2012-2013 BB9z
 https://github.com/RFUI/Alpha

 The MIT License (MIT)
 http://www.opensource.org/licenses/mit-license.php
 */

#import <RFKit/RFKit.h>
#import "RFTabBarItem.h"
#import "RFInitializing.h"

@protocol RFTabBarDelegate, RFTabBarDataSource;

@interface RFTabBar : UIView
<RFInitializing>
@property (weak, nonatomic) IBOutlet id<RFTabBarDelegate> delegate;
@property (weak, nonatomic) IBOutlet id<RFTabBarDataSource> dataSource;

- (void)reloadTabItem;

#pragma mark - Accessing item

@property (strong, nonatomic) IBOutletCollection(RFTabBarItem) NSMutableArray *items;
- (void)setItems:(NSArray *)items animated:(BOOL)animated;

- (RFTabBarItem *)itemAtIndex:(NSInteger)index;
- (NSInteger)indexForItem:(RFTabBarItem *)item;

#pragma mark - Managing Selection

@property (nonatomic) RFTabBarItem *selectedItem;

- (void)selectItemAtIndex:(NSInteger)index;
- (NSInteger)indexForSelectedItem;

#pragma mark - Using Static Items
/// Like you can define a static UITableView in storyboard, RFTabBar support something like that too. If set to `YES`, all RFTabBarItem added to this view will be its item.
/// You need call `reloadTabItem` manually after you add some items programily.
@property (assign, nonatomic) BOOL staticMode;

/// If set to `YES`, will not change item frame in `layoutSubviews`. Default is `NO`.
/// If you load static item from stroyboard and want to keey layout, you must make sure set this property before `staticMode`. I recoment you using storyboard `User Defined Runtime Attributes` to set these properties.
@property (assign, nonatomic) BOOL keepLayoutForStaticMode;

@end


@protocol RFTabBarDelegate <NSObject>
@optional
- (BOOL)RFTabBar:(RFTabBar *)tabBar shouldSelectItem:(RFTabBarItem *)item;
- (void)RFTabBar:(RFTabBar *)tabBar didSelectItem:(RFTabBarItem *)item;

@end


@protocol RFTabBarDataSource <NSObject>
@required
- (NSInteger)numberOfItemInTabBar:(RFTabBar *)tabBar;
- (RFTabBarItem *)RFTabBar:(RFTabBar *)tabBar itemForIndex:(NSInteger)index;

@optional
- (CGFloat)RFTabBar:(RFTabBar *)tabBar itemWidthForIndex:(NSInteger)index;

@end
