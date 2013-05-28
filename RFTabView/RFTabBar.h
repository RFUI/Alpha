// TEST

#import "RFUI.h"
#import "RFTabBarItem.h"

@protocol RFTabBarDelegate, RFTabBarDataSource;

@interface RFTabBar : UIView
@property (weak, nonatomic) IBOutlet id<RFTabBarDelegate> delegate;
@property (weak, nonatomic) IBOutlet id<RFTabBarDataSource> dataSource;

- (void)reloadTabItem;

#pragma mark - Accessing item
@property (strong, nonatomic) IBOutletCollection(RFTabBarItem) NSMutableArray *items;
- (void)setItems:(NSArray *)items animated:(BOOL)animated;

@property(nonatomic, assign) RFTabBarItem *selectedItem;

- (RFTabBarItem *)itemAtIndex:(NSInteger)index;

- (NSInteger)indexForItem:(RFTabBarItem *)item;
- (NSInteger)indexForSelectedItem:(RFTabBarItem *)item;

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
