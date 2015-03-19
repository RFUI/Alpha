/*!
    UICollectionViewDelegateChain
    RFDelegateChain

    Copyright (c) 2015 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Alpha
 */

#import "UIScrollViewDelegateChain.h"

@interface UICollectionViewDelegateChain : UIScrollViewDelegateChain <
    UICollectionViewDelegate
>

@property (weak, nonatomic) IBOutlet id<UICollectionViewDelegate> delegate;

#pragma mark Managing the Selected Cells

@property (copy, nonatomic) BOOL (^shouldSelectItem)(UICollectionView *collectionView, NSIndexPath *indexPath, id<UICollectionViewDelegate> delegate);

@property (copy, nonatomic) void (^didSelectItem)(UICollectionView *collectionView, NSIndexPath *indexPath, id<UICollectionViewDelegate> delegate);

@property (copy, nonatomic) BOOL (^shouldDeselectItem)(UICollectionView *collectionView, NSIndexPath *indexPath, id<UICollectionViewDelegate> delegate);

@property (copy, nonatomic) void (^didDeselectItem)(UICollectionView *collectionView, NSIndexPath *indexPath, id<UICollectionViewDelegate> delegate);

#pragma mark Managing Cell Highlighting

@property (copy, nonatomic) BOOL (^shouldHighlightItem)(UICollectionView *collectionView, NSIndexPath *indexPath, id<UICollectionViewDelegate> delegate);

@property (copy, nonatomic) void (^didHighlightItem)(UICollectionView *collectionView, NSIndexPath *indexPath, id<UICollectionViewDelegate> delegate);

@property (copy, nonatomic) void (^didUnhighlightItem)(UICollectionView *collectionView, NSIndexPath *indexPath, id<UICollectionViewDelegate> delegate);

#pragma mark Tracking the Addition and Removal of Views

@property (copy, nonatomic) void (^willDisplayCell)(UICollectionView *collectionView, UICollectionViewCell *cell, NSIndexPath *indexPath, id<UICollectionViewDelegate> delegate) NS_AVAILABLE_IOS(8_0);

@property (copy, nonatomic) void (^willDisplaySupplementaryView)(UICollectionView *collectionView, UICollectionReusableView *view, NSString *elementKind, NSIndexPath *indexPath, id<UICollectionViewDelegate> delegate) NS_AVAILABLE_IOS(8_0);

@property (copy, nonatomic) void (^didEndDisplayingCell)(UICollectionView *collectionView, UICollectionViewCell *cell, NSIndexPath *indexPath, id<UICollectionViewDelegate> delegate);

@property (copy, nonatomic) void (^didEndDisplayingSupplementaryView)(UICollectionView *collectionView, UICollectionReusableView *view, NSString *elementKind, NSIndexPath *indexPath, id<UICollectionViewDelegate> delegate);

#pragma mark Providing a Transition Layout

@property (copy, nonatomic) UICollectionViewTransitionLayout* (^transitionLayout)(UICollectionView *collectionView, UICollectionViewLayout *fromLayout, UICollectionViewLayout *toLayout, id<UICollectionViewDelegate> delegate);

#pragma mark Managing Actions for Cells

@property (copy, nonatomic) BOOL (^shouldShowMenuForItem)(UICollectionView *collectionView, NSIndexPath *indexPath, id<UICollectionViewDelegate> delegate);

@property (copy, nonatomic) BOOL (^canPerformAction)(UICollectionView *collectionView, SEL action, NSIndexPath *indexPath, id sender, id<UICollectionViewDelegate> delegate);

@property (copy, nonatomic) BOOL (^performAction)(UICollectionView *collectionView,  SEL action, NSIndexPath *indexPath, id sender, id<UICollectionViewDelegate> delegate);

@end
