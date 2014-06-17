
#import "RFFullSizeCollectionViewFlowLayout.h"

@interface RFFullSizeCollectionViewFlowLayout ()
@end

@implementation RFFullSizeCollectionViewFlowLayout

- (id)init {
    if (!(self = [super init])) return nil;

    self.sectionInset = UIEdgeInsetsZero;
    self.minimumInteritemSpacing = 0;
    self.minimumLineSpacing = 0;
    
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    self.itemSize = self.collectionView.bounds.size;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    CGSize oldSize = self.collectionView.bounds.size;
    if (!CGSizeEqualToSize(oldSize, newBounds.size)) {
        self.itemSize = newBounds.size;
        return YES;
    }
    return NO;
}

@end
