
#import "UICollectionViewDataSourceChain.h"

@implementation UICollectionViewDataSourceChain

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(collectionView:numberOfItemsInSection:)) {
        return !!(self.numberOfItemsInSection);
    }
    else if (aSelector == @selector(collectionView:cellForItemAtIndexPath:)) {
        return !!(self.cellForItemAtIndexPath);
    }
    else if (aSelector == @selector(numberOfSectionsInCollectionView:)) {
        return !!(self.numberOfSections);
    }
    else if (aSelector == @selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)) {
        return !!(self.viewForSupplementaryElement);
    }
    return [super respondsToSelector:aSelector];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.numberOfItemsInSection(collectionView, section, self.delegate);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellForItemAtIndexPath(collectionView, indexPath, self.delegate);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.numberOfSections(collectionView, self.delegate);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return self.viewForSupplementaryElement(collectionView, kind, indexPath, self.delegate);
}

@end
