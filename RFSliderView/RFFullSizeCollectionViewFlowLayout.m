
#import "RFFullSizeCollectionViewFlowLayout.h"

@interface RFFullSizeCollectionViewFlowLayout ()
@end

@implementation RFFullSizeCollectionViewFlowLayout

- (void)prepareLayout {
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
    [super prepareLayout];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    if (!CGSizeEqualToSize(self.itemSize, newBounds.size)) {
        return YES;
    }
    return NO;
}

@end
