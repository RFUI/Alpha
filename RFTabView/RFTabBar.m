
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
    for (UIView *view in self.prototypeItems) {
        [view removeFromSuperview];
    }
    
    if (!self.dataSource) return;
    
    NSInteger count = 0;
    if ([self.dataSource respondsToSelector:@selector(numberOfItemInTabBar:)]) {
        count = [self.dataSource numberOfItemInTabBar:self];
    }
    RFAssert(count >= 0, @"Tab item count cannot less than zero.");
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger i = 0; i < count; i++) {
        [items addObject:[self.dataSource RFTabBar:self itemForIndex:i]];
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

- (id)dequeueReusableItemWithIdentifier:(NSString *)identifier {
    RFTabBarItem *prototypeItem = [self prototypeItemWithIdentifier:identifier];
    RFAssert(prototypeItem, @"Cannot dequeue a item with identifier:%@.", identifier);
    RFTabBarItem *copyedItem = [prototypeItem reusingCopy];
    [copyedItem prepareForReuse];
    return copyedItem;
}

- (RFTabBarItem *)prototypeItemWithIdentifier:(NSString *)identifier {
    for (RFTabBarItem *item in self.prototypeItems) {
        if ([item.reuseIdentifier isEqualToString:identifier]) {
            return item;
        }
    }
    return nil;
}

@end


