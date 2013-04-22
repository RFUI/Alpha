// WORKING

#import "RFUI.h"
#import "RFStoryboardReusing.h"

@class RFTabItem;
@protocol RFTabBarDelegate;

@interface RFTabBar : UIView
@property (strong, nonatomic) IBOutletCollection(RFTabItem) NSArray *prototypeItems;
@property (strong, nonatomic) IBOutletCollection(RFTabItem) NSMutableArray *items;
@property(nonatomic, assign) UITabBarItem *selectedItem;

- (void)setItems:(NSArray *)items animated:(BOOL)animated;

@end


@interface RFTabItem : UIButton
<RFStoryboardReusing>



@end

@protocol RFTabBarDelegate <NSObject>
- (void)RFTabBar:(RFTabBar *)tabBar shouldSelectItem:(RFTabItem *)item;
- (void)RFTabBar:(RFTabBar *)tabBar didSelectItem:(RFTabItem *)item;

@end
