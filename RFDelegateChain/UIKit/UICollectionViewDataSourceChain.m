
#import "UICollectionViewDataSourceChain.h"

@implementation UICollectionViewDataSourceChain
@dynamic delegate;

- (BOOL)respondsToSelector:(SEL)aSelector {
    _RFDelegateChainHasBlockPropertyRespondsToSelector(numberOfItemsInSection, collectionView:numberOfItemsInSection:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(cellForItemAtIndexPath, collectionView:cellForItemAtIndexPath:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(numberOfSections, numberOfSectionsInCollectionView:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(viewForSupplementaryElement, collectionView:viewForSupplementaryElementOfKind:atIndexPath:)
    return [super respondsToSelector:aSelector];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.numberOfItemsInSection) {
        return self.numberOfItemsInSection(collectionView, section, self.delegate);
    }
    return [self.delegate collectionView:collectionView numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.cellForItemAtIndexPath) {
        return self.cellForItemAtIndexPath(collectionView, indexPath, self.delegate);
    }
    return [self.delegate collectionView:collectionView cellForItemAtIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.numberOfSections) {
        return self.numberOfSections(collectionView, self.delegate);
    }
    return [self.delegate numberOfSectionsInCollectionView:collectionView];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (self.viewForSupplementaryElement) {
        return self.viewForSupplementaryElement(collectionView, kind, indexPath, self.delegate);
    }
    return [self.delegate collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
}

@end
