
#import "RFTabBar.h"
#import "UIView+RFAnimate.h"

@interface RFTabBar ()
@property (strong, nonatomic) NSMutableDictionary *reusingPool;
@end

@implementation RFTabBar

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.items = [NSMutableArray array];
    
    _douto(self.prototypeItems)
    _douto(self.items)
}

- (void)reloadTabItem {    
    if (!self.dataSource) return;
    
    NSInteger count = 0;
    if ([self.dataSource respondsToSelector:@selector(numberOfItemInTabBar:)]) {
        count = [self.dataSource numberOfItemInTabBar:self];
    }
    RFAssert(count >= 0, @"Tab item count cannot less than zero.");
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger i = 0; i < count; i++) {
        RFTabBarItem *item = [self.dataSource RFTabBar:self itemForIndex:i];
        if ([item actionsForTarget:self forControlEvent:UIControlEventTouchUpInside].count == 0) {
            [item addTarget:self action:@selector(onTabBarItemTapped:) forControlEvents:UIControlEventTouchUpInside];
        }
        [items addObject:item];
    }
    
    [self setItems:items animated:YES];
}

- (void)setItems:(NSArray *)items animated:(BOOL)animated {
    for (UIView *view in self.items) {
        [view removeFromSuperview];
    }
    
    [self.items setArray:items];
    for (RFTabBarItem *item in self.items) {
        [self addSubview:item];
    }
    [self setNeedsDisplay];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    BOOL usingCustomSize = [self.dataSource respondsToSelector:@selector(RFTabBar:itemWidthForIndex:)];
    NSInteger index = 0;
    CGFloat tabHeight = self.bounds.size.height;
    CGFloat ctXPosition = 0;
    CGFloat selfWidth = self.bounds.size.width;
    for (RFTabBarItem *item in self.items) {
        if (usingCustomSize) {
            item.width = [self.dataSource RFTabBar:self itemWidthForIndex:index];
        }
        else {
            item.width = selfWidth/self.items.count;
        }
        
        item.x = ctXPosition;
        ctXPosition += item.width;
        item.height = tabHeight;
        
        index++;
        _dout_rect(item.frame)
    }
}

#pragma mark - Accessing item
- (RFTabBarItem *)itemAtIndex:(NSInteger)index {
    if (index < (NSInteger)self.items.count) {
        return [self.items objectAtIndex:index];
    }
    return nil;
}

- (NSInteger)indexForItem:(RFTabBarItem *)item {
    return [self.items indexOfObject:item];
}

- (NSInteger)indexForSelectedItem:(RFTabBarItem *)item {
    return [self.items indexOfObject:self.selectedItem];
}

#pragma mark - Managing Selection
- (void)selectItemAtIndex:(NSInteger)index {
    RFTabBarItem *itemToBeSelected = [self itemAtIndex:index];
    
    if (!itemToBeSelected) return;
    if (itemToBeSelected == self.selectedItem) return;
    
    if ([self.delegate respondsToSelector:@selector(RFTabBar:shouldSelectItem:)] && ![self.delegate RFTabBar:self shouldSelectItem:itemToBeSelected]) {
        return;
    }
    
    self.selectedItem.selected = NO;
    itemToBeSelected.selected = YES;
    self.selectedItem = itemToBeSelected;
    
    if ([self.delegate respondsToSelector:@selector(RFTabBar:didSelectItem:)]) {
        [self.delegate RFTabBar:self didSelectItem:itemToBeSelected];
    }
}

#pragma mark - Delegate
- (void)onTabBarItemTapped:(RFTabBarItem *)sender {
    NSInteger indexToBeSelected = [self indexForItem:sender];
    
    if (indexToBeSelected != NSNotFound) {
        [self selectItemAtIndex:indexToBeSelected];
    }
}

@end


