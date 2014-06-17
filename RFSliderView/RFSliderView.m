
#import "RFSliderView.h"
#import "RFFullSizeCollectionViewFlowLayout.h"

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
    CGFloat oldWidth = CGRectGetWidth(self.bounds);
    CGFloat newWidth = CGRectGetWidth(bounds);
    NSUInteger page = 0;
    if (oldWidth != newWidth && oldWidth > 0) {
        page = self.contentOffset.x / oldWidth + 0.5;
    }

    _dout_debug(@"Update bounds: %@", NSStringFromCGRect(bounds))
    [super setBounds:bounds];

    if (oldWidth == newWidth) return;
    if (self.isDragging) return;

    self.contentOffset = CGPointMake(page * newWidth, self.contentOffset.y);
}

@end
