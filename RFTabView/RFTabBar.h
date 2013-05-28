// TEST

#import "RFUI.h"
#import "RFTabBarItem.h"

@protocol RFTabBarDelegate, RFTabBarDataSource;

@interface RFTabBar : UIView
@property (strong, nonatomic) IBOutletCollection(RFTabBarItem) NSArray *prototypeItems;
@property (weak, nonatomic) IBOutlet id<RFTabBarDelegate> delegate;
@property (weak, nonatomic) IBOutlet id<RFTabBarDataSource> dataSource;

@property (strong, nonatomic) IBOutletCollection(RFTabBarItem) NSMutableArray *items;
@property(nonatomic, assign) UITabBarItem *selectedItem;

- (void)setItems:(NSArray *)items animated:(BOOL)animated;
- (void)reloadTabItem;
- (id)dequeueReusableItemWithIdentifier:(NSString *)identifier;

@end


@protocol RFTabBarDelegate <NSObject>
@optional
- (void)RFTabBar:(RFTabBar *)tabBar shouldSelectItem:(RFTabBarItem *)item;
- (void)RFTabBar:(RFTabBar *)tabBar didSelectItem:(RFTabBarItem *)item;

@end


@protocol RFTabBarDataSource <NSObject>
@required
- (NSInteger)numberOfItemInTabBar:(RFTabBar *)tabBar;
- (RFTabBarItem *)RFTabBar:(RFTabBar *)tabBar itemForIndex:(NSInteger)index;

@optional
- (CGFloat)RFTabBar:(RFTabBar *)tabBar itemWidthForIndex:(NSInteger)index;

@end
