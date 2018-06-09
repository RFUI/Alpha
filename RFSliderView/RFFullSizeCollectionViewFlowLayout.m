
#import "RFFullSizeCollectionViewFlowLayout.h"

@implementation RFFullSizeCollectionViewFlowLayout

- (void)prepareLayout {
    // Must call super first, otherwise the layout is abnormal after screen rotates.
    [super prepareLayout];
    self.sectionInset = UIEdgeInsetsZero;
    self.minimumInteritemSpacing = 0;
    self.minimumLineSpacing = 0;
    
    CGSize itemSize = self.collectionView.bounds.size;
    if (itemSize.width > 0 && itemSize.width < 10000 && itemSize.height > 0 && itemSize.height < 10000) {
        self.itemSize = itemSize;
    }
    else {
        self.itemSize = CGSizeMake(1, 1);
    }
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    if (!CGSizeEqualToSize(self.itemSize, newBounds.size)) {
        return YES;
    }
    return NO;
}

@end
