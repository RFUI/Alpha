
#import "UICollectionViewDelegateFlowLayoutChain.h"

@implementation UICollectionViewDelegateFlowLayoutChain
@dynamic delegate;

- (BOOL)respondsToSelector:(SEL)aSelector {
    _RFDelegateChainHasBlockPropertyRespondsToSelector(sizeForItem, collectionView:layout:sizeForItemAtIndexPath:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(insetForSection, collectionView:layout:insetForSectionAtIndex:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(minimumLineSpacingForSection, collectionView:layout:minimumLineSpacingForSectionAtIndex:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(minimumInteritemSpacingForSection, collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(referenceSizeForHeaderInSection, collectionView:layout:referenceSizeForHeaderInSection:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(referenceSizeForFooterInSection, collectionView:layout:referenceSizeForFooterInSection:)
    return [super respondsToSelector:aSelector];
}

#pragma mark -

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.sizeForItem(collectionView, collectionViewLayout, indexPath, self.delegate);
}

#pragma mark -

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return self.insetForSection(collectionView, collectionViewLayout, section, self.delegate);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.minimumLineSpacingForSection(collectionView, collectionViewLayout, section, self.delegate);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.minimumInteritemSpacingForSection(collectionView, collectionViewLayout, section, self.delegate);
}

#pragma mark -

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return self.referenceSizeForHeaderInSection(collectionView, collectionViewLayout, section, self.delegate);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return self.referenceSizeForFooterInSection(collectionView, collectionViewLayout, section, self.delegate);
}

@end
