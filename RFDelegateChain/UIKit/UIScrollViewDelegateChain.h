/*!
    UIScrollViewDelegateChain
    RFDelegateChain

    Copyright (c) 2015 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Alpha
 */

#import "RFDelegateChain.h"

@interface UIScrollViewDelegateChain : RFDelegateChain <
    UIScrollViewDelegate
>

@property (weak, nonatomic) IBOutlet id<UIScrollViewDelegate> delegate;

#pragma mark Responding to Scrolling and Dragging

@property (copy, nonatomic) void (^didScroll)(UIScrollView *scrollView, id<UIScrollViewDelegate> delegate);

@property (copy, nonatomic) void (^willBeginDragging)(UIScrollView *scrollView, id<UIScrollViewDelegate> delegate);

@property (copy, nonatomic) void (^willEndDragging)(UIScrollView *scrollView, CGPoint velocity, CGPoint *targetContentOffset, id<UIScrollViewDelegate> delegate);

@property (copy, nonatomic) void (^didEndDragging)(UIScrollView *scrollView, BOOL decelerate, id<UIScrollViewDelegate> delegate);

@property (copy, nonatomic) BOOL (^shouldScrollToTop)(UIScrollView *scrollView, id<UIScrollViewDelegate> delegate);

@property (copy, nonatomic) void (^didScrollToTop)(UIScrollView *scrollView, id<UIScrollViewDelegate> delegate);

@property (copy, nonatomic) void (^willBeginDecelerating)(UIScrollView *scrollView, id<UIScrollViewDelegate> delegate);

@property (copy, nonatomic) void (^didEndDecelerating)(UIScrollView *scrollView, id<UIScrollViewDelegate> delegate);

#pragma mark Managing Zooming

@property (copy, nonatomic) UIView* (^viewForZooming)(UIScrollView *scrollView, id<UIScrollViewDelegate> delegate);

@property (copy, nonatomic) void (^willBeginZoomingView)(UIScrollView *scrollView, UIView *view, id<UIScrollViewDelegate> delegate);

@property (copy, nonatomic) void (^didEndZoomingView)(UIScrollView *scrollView, UIView *view, CGFloat scale, id<UIScrollViewDelegate> delegate);

@property (copy, nonatomic) void (^didZoom)(UIScrollView *scrollView, id<UIScrollViewDelegate> delegate);

#pragma mark Responding to Scrolling Animations

@property (copy, nonatomic) void (^didEndScrollingAnimation)(UIScrollView *scrollView, id<UIScrollViewDelegate> delegate);

@end
