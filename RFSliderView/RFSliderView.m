
#import "RFSliderView.h"
#import "RFFullSizeCollectionViewFlowLayout.h"

@interface RFSliderView ()
@end

@implementation RFSliderView
RFInitializingRootForUIView

- (void)onInit {
    // Initialization code
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

@end
