
#import "UICollectionViewDelegateChain.h"

@implementation UICollectionViewDelegateChain
@dynamic delegate;

- (BOOL)respondsToSelector:(SEL)aSelector {
    _RFDelegateChainHasBlockPropertyRespondsToSelector(shouldSelectItem, collectionView:shouldSelectItemAtIndexPath:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(shouldDeselectItem, collectionView:shouldDeselectItemAtIndexPath:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(didSelectItem, collectionView:didSelectItemAtIndexPath:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(didDeselectItem, collectionView:didDeselectItemAtIndexPath:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(shouldHighlightItem, collectionView:shouldHighlightItemAtIndexPath:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(didHighlightItem, collectionView:didHighlightItemAtIndexPath:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(didUnhighlightItem, collectionView:didUnhighlightItemAtIndexPath:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(willDisplayCell, collectionView:willDisplayCell:forItemAtIndexPath:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(willDisplaySupplementaryView, collectionView:willDisplaySupplementaryView:forElementKind:atIndexPath:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(didEndDisplayingCell, collectionView:didEndDisplayingCell:forItemAtIndexPath:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(didEndDisplayingSupplementaryView, collectionView:didEndDisplayingSupplementaryView:forElementOfKind:atIndexPath:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(transitionLayout, collectionView:transitionLayoutForOldLayout:newLayout:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(shouldShowMenuForItem, collectionView:shouldShowMenuForItemAtIndexPath:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(canPerformAction, collectionView:canPerformAction:forItemAtIndexPath:withSender:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(performAction, collectionView:performAction:forItemAtIndexPath:withSender:)
    return [super respondsToSelector:aSelector];
}

#pragma mark -

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.shouldSelectItem) {
        return self.shouldSelectItem(collectionView, indexPath, self.delegate);
    }
    return [self.delegate collectionView:collectionView shouldSelectItemAtIndexPath:indexPath];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.shouldDeselectItem) {
        return self.shouldDeselectItem(collectionView, indexPath, self.delegate);
    }
    return [self.delegate collectionView:collectionView shouldDeselectItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didSelectItem) {
        self.didSelectItem(collectionView, indexPath, self.delegate);
        return;
    }
    [self.delegate collectionView:collectionView didSelectItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didDeselectItem) {
        self.didDeselectItem(collectionView, indexPath, self.delegate);
        return;
    }
    [self.delegate collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
}

#pragma mark -

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.shouldHighlightItem) {
        return self.shouldHighlightItem(collectionView, indexPath, self.delegate);
    }
    return [self.delegate collectionView:collectionView shouldHighlightItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didHighlightItem) {
        self.didHighlightItem(collectionView, indexPath, self.delegate);
        return;
    }
    [self.delegate collectionView:collectionView didHighlightItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didUnhighlightItem) {
        self.didUnhighlightItem(collectionView, indexPath, self.delegate);
        return;
    }
    [self.delegate collectionView:collectionView didUnhighlightItemAtIndexPath:indexPath];
}

#pragma mark -

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.willDisplayCell) {
        self.willDisplayCell(collectionView, cell, indexPath, self.delegate);
        return;
    }
    [self.delegate collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if (self.willDisplaySupplementaryView) {
        self.willDisplaySupplementaryView(collectionView, view, elementKind, indexPath, self.delegate);
        return;
    }
    [self.delegate collectionView:collectionView willDisplaySupplementaryView:view forElementKind:elementKind atIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didEndDisplayingCell) {
        self.didEndDisplayingCell(collectionView, cell, indexPath, self.delegate);
        return;
    }
    [self.delegate collectionView:collectionView didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if (self.didEndDisplayingSupplementaryView) {
        self.didEndDisplayingSupplementaryView(collectionView, view, elementKind, indexPath, self.delegate);
        return;
    }
    [self.delegate collectionView:collectionView didEndDisplayingSupplementaryView:view forElementOfKind:elementKind atIndexPath:indexPath];
}

#pragma mark -

- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout {
    if (self.transitionLayout) {
        return self.transitionLayout(collectionView, fromLayout, toLayout, self.delegate);
    }
    return [self.delegate collectionView:collectionView transitionLayoutForOldLayout:fromLayout newLayout:toLayout];
}

#pragma mark -

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.shouldShowMenuForItem) {
        return self.shouldShowMenuForItem(collectionView, indexPath, self.delegate);
    }
    return [self.delegate collectionView:collectionView shouldShowMenuForItemAtIndexPath:indexPath];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (self.canPerformAction) {
        return self.canPerformAction(collectionView, action, indexPath, sender, self.delegate);
    }
    return [self.delegate collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (self.performAction) {
        self.performAction(collectionView, action, indexPath, sender, self.delegate);
        return;
    }
    [self.delegate collectionView:collectionView performAction:action forItemAtIndexPath:indexPath withSender:sender];
}

@end
