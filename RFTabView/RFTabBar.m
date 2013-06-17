
#import "RFTabBar.h"
#import "UIView+RFAnimate.h"

@interface RFTabBar ()
@property (strong, nonatomic) NSMutableDictionary *reusingPool;
@end

@implementation RFTabBar

#pragma mark - init
- (id)init {
    self = [super init];
    if (self) {
        [self onInit];
        [self performSelector:@selector(afterInit) withObject:self afterDelay:0];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self onInit];
        [self performSelector:@selector(afterInit) withObject:self afterDelay:0];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self onInit];
        [self performSelector:@selector(afterInit) withObject:self afterDelay:0];
    }
    return self;
}

- (void)onInit {
    self.items = [NSMutableArray array];
}

- (void)afterInit {
    [self reloadTabItem];
}

#pragma mark -
- (void)reloadTabItem {
    if (self.staticMode) {
        [self loadStaticItem];
        return;
    }
    
    if (!self.dataSource) return;
    
    NSInteger count = 0;
    if ([self.dataSource respondsToSelector:@selector(numberOfItemInTabBar:)]) {
        count = [self.dataSource numberOfItemInTabBar:self];
    }
    RFAssert(count >= 0, @"Tab item count cannot less than zero.");
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger i = 0; i < count; i++) {
        RFTabBarItem *item = [self.dataSource RFTabBar:self itemForIndex:i];
        [self setupItemAction:item];
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

    if (self.staticMode && self.keepLayoutForStaticMode) return;
    
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
        item.y = 0;
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

- (NSInteger)indexForSelectedItem {
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

#pragma mark - Using Static Items
- (void)setStaticMode:(BOOL)staticMode {
    if (_staticMode != staticMode) {
        [self willChangeValueForKey:@keypath(self, staticMode)];
        _staticMode = staticMode;
        if (staticMode) {
            [self reloadTabItem];
        }
        [self didChangeValueForKey:@keypath(self, staticMode)];
    }
}

- (void)setKeepLayoutForStaticMode:(BOOL)keepLayoutForStaticMode {
    if (_keepLayoutForStaticMode != keepLayoutForStaticMode) {
        [self willChangeValueForKey:@keypath(self, keepLayoutForStaticMode)];
        _keepLayoutForStaticMode = keepLayoutForStaticMode;
        [self setNeedsLayout];
        [self didChangeValueForKey:@keypath(self, keepLayoutForStaticMode)];
    }
}

- (void)loadStaticItem {
    [self.items removeAllObjects];
    
    for (RFTabBarItem *item in self.subviews) {
        if ([item isKindOfClass:[RFTabBarItem class]]) {
            [self.items addObject:item];
            [self setupItemAction:item];
        }
    }
    
    [self setNeedsLayout];
}

- (void)setupItemAction:(RFTabBarItem *)item {
    for (id obj in [item actionsForTarget:self forControlEvent:UIControlEventTouchUpInside]) {
        if ([obj isEqualToString:NSStringFromSelector(@selector(onTabBarItemTapped:))]) {
            return;
        }
    }
    [item addTarget:self action:@selector(onTabBarItemTapped:) forControlEvents:UIControlEventTouchUpInside];
}

@end


