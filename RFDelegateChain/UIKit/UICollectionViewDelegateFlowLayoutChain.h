/*!
    UICollectionViewDelegateFlowLayoutChain
    RFDelegateChain

    Copyright (c) 2015 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Alpha
 */
#import "UICollectionViewDelegateChain.h"

@interface UICollectionViewDelegateFlowLayoutChain : UICollectionViewDelegateChain <
    UICollectionViewDelegateFlowLayout
>

@property (weak, nonatomic) IBOutlet id<UICollectionViewDelegateFlowLayout> delegate;

#pragma mark Getting the Size of Items

@property (copy, nonatomic) CGSize (^sizeForItem)(UICollectionView *collectionView, UICollectionViewLayout *collectionViewLayout, NSIndexPath *indexPath, id<UICollectionViewDelegateFlowLayout> delegate);

#pragma mark Getting the Section Spacing

@property (copy, nonatomic) UIEdgeInsets (^insetForSection)(UICollectionView *collectionView, UICollectionViewLayout *collectionViewLayout, NSInteger section, id<UICollectionViewDelegateFlowLayout> delegate);

@property (copy, nonatomic) CGFloat (^minimumLineSpacingForSection)(UICollectionView *collectionView, UICollectionViewLayout *collectionViewLayout, NSInteger section, id<UICollectionViewDelegateFlowLayout> delegate);

@property (copy, nonatomic) CGFloat (^minimumInteritemSpacingForSection)(UICollectionView *collectionView, UICollectionViewLayout *collectionViewLayout, NSInteger section, id<UICollectionViewDelegateFlowLayout> delegate);

#pragma mark Getting the Header and Footer Sizes

@property (copy, nonatomic) CGSize (^referenceSizeForHeaderInSection)(UICollectionView *collectionView, UICollectionViewLayout *collectionViewLayout, NSInteger section, id<UICollectionViewDelegateFlowLayout> delegate);

@property (copy, nonatomic) CGSize (^referenceSizeForFooterInSection)(UICollectionView *collectionView, UICollectionViewLayout *collectionViewLayout, NSInteger section, id<UICollectionViewDelegateFlowLayout> delegate);


@end
