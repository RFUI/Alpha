
#import "UICollectionViewDataSourceChain.h"

@implementation UICollectionViewDataSourceChain

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(collectionView:numberOfItemsInSection:)) {
        if (self.numberOfItemsInSection) return YES;
    }
    else if (aSelector == @selector(collectionView:cellForItemAtIndexPath:)) {
        if (self.cellForItemAtIndexPath) return YES;
    }
    else if (aSelector == @selector(numberOfSectionsInCollectionView:)) {
        if (self.numberOfSections) return YES;
    }
    else if (aSelector == @selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)) {
        if (self.viewForSupplementaryElement) return YES;
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
