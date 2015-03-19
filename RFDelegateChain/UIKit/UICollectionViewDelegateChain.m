
#import "UICollectionViewDelegateChain.h"

@implementation UICollectionViewDelegateChain

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(collectionView:shouldSelectItemAtIndexPath:)) {
        if (self.shouldSelectItem) return YES;
    }
    else if (aSelector == @selector(collectionView:shouldDeselectItemAtIndexPath:)) {
        if (self.shouldDeselectItem) return YES;
    }
    else if (aSelector == @selector(collectionView:didSelectItemAtIndexPath:)) {
        if (self.didSelectItem) return YES;
    }
    else if (aSelector == @selector(collectionView:didDeselectItemAtIndexPath:)) {
        if (self.didDeselectItem) return YES;
    }
    if (aSelector == @selector(collectionView:shouldHighlightItemAtIndexPath:)) {
        if (self.shouldHighlightItem) return YES;
    }
    else if (aSelector == @selector(collectionView:didHighlightItemAtIndexPath:)) {
        if (self.didHighlightItem) return YES;
    }
    else if (aSelector == @selector(collectionView:didUnhighlightItemAtIndexPath:)) {
        if (self.didUnhighlightItem) return YES;
    }
    else if (aSelector == @selector(collectionView:willDisplayCell:forItemAtIndexPath:)) {
        if (self.willDisplayCell) return YES;
    }
    else if (aSelector == @selector(collectionView:willDisplaySupplementaryView:forElementKind:atIndexPath:)) {
        if (self.willDisplaySupplementaryView) return YES;
    }
    else if (aSelector == @selector(collectionView:didEndDisplayingCell:forItemAtIndexPath:)) {
        if (self.didEndDisplayingCell) return YES;
    }
    else if (aSelector == @selector(collectionView:didEndDisplayingSupplementaryView:forElementOfKind:atIndexPath:)) {
        if (self.didEndDisplayingSupplementaryView) return YES;
    }
    else if (aSelector == @selector(collectionView:transitionLayoutForOldLayout:newLayout:)) {
        if (self.transitionLayout) return YES;
    }
    else if (aSelector == @selector(collectionView:shouldShowMenuForItemAtIndexPath:)) {
        if (self.shouldShowMenuForItem) return YES;
    }
    else if (aSelector == @selector(collectionView:canPerformAction:forItemAtIndexPath:withSender:)) {
        if (self.canPerformAction) return YES;
    }
    else if (aSelector == @selector(collectionView:performAction:forItemAtIndexPath:withSender:)) {
        if (self.performAction) return YES;
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
