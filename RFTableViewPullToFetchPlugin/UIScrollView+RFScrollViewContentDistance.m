
#import "UIScrollView+RFScrollViewContentDistance.h"

@implementation UIScrollView (RFScrollViewContentDistance)
@dynamic distanceBetweenContentAndBottom, distanceBetweenContentAndTop;

+ (NSSet *)keyPathsForValuesAffectingDistanceBetweenContentAndTop {
    UITableView *this;
    return [NSSet setWithObjects:@keypath(this, contentOffset), nil];
}

+ (NSSet *)keyPathsForValuesAffectingDistanceBetweenContentAndBottom {
    UITableView *this;
    return [NSSet setWithObjects:@keypath(this, contentOffset), @keypath(this, contentSize), @keypath(this, bounds), nil];
}

- (CGFloat)distanceBetweenContentAndTop {
    return -self.contentOffset.y;
}

- (void)setDistanceBetweenContentAndTop:(CGFloat)distanceBetweenContentAndTop {
    CGPoint offset = self.contentOffset;
    offset.y = -distanceBetweenContentAndTop;
    self.contentOffset = offset;
}

- (CGFloat)distanceBetweenContentAndBottom {
    return self.bounds.size.height + self.contentOffset.y - self.contentSize.height;
}

- (void)setDistanceBetweenContentAndBottom:(CGFloat)distanceBetweenContentAndBottom {
    CGPoint offset = self.contentOffset;
    offset.y = distanceBetweenContentAndBottom + self.contentSize.height - CGRectGetHeight(self.bounds);
    self.contentOffset = offset;
}

@end
