
#import "RFSliderView.h"
#import "RFFullSizeCollectionViewFlowLayout.h"
#import "UIView+RFAnimate.h"

@interface RFSliderView ()
@end

@implementation RFSliderView
RFInitializingRootForUIView

- (void)onInit {
    RFFullSizeCollectionViewFlowLayout *layout = [[RFFullSizeCollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionViewLayout = layout;

    self.pagingEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
}

- (void)afterInit {
    // nothing
}

- (void)setBounds:(CGRect)bounds {
    CGFloat oldWidth = self.width;
    CGFloat newWidth = CGRectGetWidth(bounds);
    NSUInteger page = self.currentPage;

    _dout_debug(@"Update bounds: %@", NSStringFromCGRect(bounds))
    [super setBounds:bounds];

    if (oldWidth == newWidth) return;
    if (self.isDragging) return;

    self.contentOffset = CGPointMake(page * newWidth, self.contentOffset.y);
}

- (NSInteger)currentPage {
    CGFloat width = CGRectGetWidth(self.bounds);
    if (width > 0) {
        return self.contentOffset.x / width + 0.5;
    }
    return -1;
}

- (void)setCurrentPage:(NSInteger)currentPage {
    CGPoint offset = self.contentOffset;
    offset.x = currentPage * self.width;
    self.contentOffset = offset;
}

@end
