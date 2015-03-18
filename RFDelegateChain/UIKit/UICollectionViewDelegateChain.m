
#import "UICollectionViewDelegateChain.h"

@implementation UICollectionViewDelegateChain

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(collectionView:shouldSelectItemAtIndexPath:)) {
        return !!(self.shouldSelectItem);
    }
    else if (aSelector == @selector(collectionView:shouldDeselectItemAtIndexPath:)) {
        return !!(self.shouldDeselectItem);
    }
    else if (aSelector == @selector(collectionView:didSelectItemAtIndexPath:)) {
        return !!(self.didSelectItem);
    }
    else if (aSelector == @selector(collectionView:didDeselectItemAtIndexPath:)) {
        return !!(self.didDeselectItem);
    }
    if (aSelector == @selector(collectionView:shouldHighlightItemAtIndexPath:)) {
        return !!(self.shouldHighlightItem);
    }
    else if (aSelector == @selector(collectionView:didHighlightItemAtIndexPath:)) {
        return !!(self.didHighlightItem);
    }
    else if (aSelector == @selector(collectionView:didUnhighlightItemAtIndexPath:)) {
        return !!(self.didUnhighlightItem);
    }
    else if (aSelector == @selector(collectionView:willDisplayCell:forItemAtIndexPath:)) {
        return !!(self.willDisplayCell);
    }
    else if (aSelector == @selector(collectionView:willDisplaySupplementaryView:forElementKind:atIndexPath:)) {
        return !!(self.willDisplaySupplementaryView);
    }
    else if (aSelector == @selector(collectionView:didEndDisplayingCell:forItemAtIndexPath:)) {
        return !!(self.didEndDisplayingCell);
    }
    else if (aSelector == @selector(collectionView:didEndDisplayingSupplementaryView:forElementOfKind:atIndexPath:)) {
        return !!(self.didEndDisplayingSupplementaryView);
    }
    else if (aSelector == @selector(collectionView:transitionLayoutForOldLayout:newLayout:)) {
        return !!(self.transitionLayout);
    }
    else if (aSelector == @selector(collectionView:shouldShowMenuForItemAtIndexPath:)) {
        return !!(self.shouldShowMenuForItem);
    }
    else if (aSelector == @selector(collectionView:canPerformAction:forItemAtIndexPath:withSender:)) {
        return !!(self.canPerformAction);
    }
    else if (aSelector == @selector(collectionView:performAction:forItemAtIndexPath:withSender:)) {
        return !!(self.performAction);
    }

    return [super respondsToSelector:aSelector];
}

#pragma mark -

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.shouldSelectItem(collectionView, indexPath, self.delegate);
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.shouldDeselectItem(collectionView, indexPath, self.delegate);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.didSelectItem(collectionView, indexPath, self.delegate);
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.didDeselectItem(collectionView, indexPath, self.delegate);
}

#pragma mark -

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.shouldHighlightItem(collectionView, indexPath, self.delegate);
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    self.didHighlightItem(collectionView, indexPath, self.delegate);
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    self.didUnhighlightItem(collectionView, indexPath, self.delegate);
}

#pragma mark -

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    self.willDisplayCell(collectionView, cell, indexPath, self.delegate);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    self.willDisplaySupplementaryView(collectionView, view, elementKind, indexPath, self.delegate);
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    self.didEndDisplayingCell(collectionView, cell, indexPath, self.delegate);
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    self.didEndDisplayingSupplementaryView(collectionView, view, elementKind, indexPath, self.delegate);
}

#pragma mark -

- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout {
    return self.transitionLayout(collectionView, fromLayout, toLayout, self.delegate);
}

#pragma mark -

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.shouldShowMenuForItem(collectionView, indexPath, self.delegate);
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return self.canPerformAction(collectionView, action, indexPath, sender, self.delegate);
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    self.performAction(collectionView, action, indexPath, sender, self.delegate);
}

@end
