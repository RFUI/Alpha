
#import "UICollectionViewDelegateFlowLayoutChain.h"

@implementation UICollectionViewDelegateFlowLayoutChain

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(collectionView:layout:sizeForItemAtIndexPath:)) {
        return !!(self.sizeForItem);
    }
    else if (aSelector == @selector(collectionView:layout:insetForSectionAtIndex:)) {
        return !!(self.insetForSection);
    }
    else if (aSelector == @selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)) {
        return !!(self.minimumLineSpacingForSection);
    }
    else if (aSelector == @selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)) {
        return !!(self.minimumInteritemSpacingForSection);
    }
    else if (aSelector == @selector(collectionView:layout:referenceSizeForHeaderInSection:)) {
        return !!(self.referenceSizeForHeaderInSection);
    }
    else if (aSelector == @selector(collectionView:layout:referenceSizeForFooterInSection:)) {
        return !!(self.referenceSizeForFooterInSection);
    }
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
