
#import "UIScrollViewDelegateChain.h"

@implementation UIScrollViewDelegateChain
@dynamic delegate;

- (BOOL)respondsToSelector:(SEL)aSelector {
    _RFDelegateChainHasBlockPropertyRespondsToSelector(didScroll, scrollViewDidScroll:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(willBeginDragging, scrollViewWillBeginDragging:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(willEndDragging, scrollViewWillEndDragging:withVelocity:targetContentOffset:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(didEndDragging, scrollViewDidEndDragging:willDecelerate:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(shouldScrollToTop, scrollViewShouldScrollToTop:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(didScrollToTop, scrollViewDidScrollToTop:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(willBeginDecelerating, scrollViewWillBeginDecelerating:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(didEndDecelerating, scrollViewDidEndDecelerating:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(viewForZooming, viewForZoomingInScrollView:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(willBeginZoomingView, scrollViewWillBeginZooming:withView:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(didEndZoomingView, scrollViewDidEndZooming:withView:atScale:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(didZoom, scrollViewDidZoom:)
    _RFDelegateChainHasBlockPropertyRespondsToSelector(didEndScrollingAnimation, scrollViewDidEndScrollingAnimation:)
    return [super respondsToSelector:aSelector];
}

#pragma mark -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.didScroll) {
        self.didScroll(scrollView, self.delegate);
        return;
    }
    [self.delegate scrollViewDidScroll:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.willBeginDragging) {
        self.willBeginDragging(scrollView, self.delegate);
        return;
    }
    [self.delegate scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (self.willEndDragging) {
        self.willEndDragging(scrollView, velocity, targetContentOffset, self.delegate);
        return;
    }
    [self.delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.didEndDragging) {
        self.didEndDragging(scrollView, decelerate, self.delegate);
        return;
    }
    [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    if (self.shouldScrollToTop) {
        return self.shouldScrollToTop(scrollView, self.delegate);
    }
    return [self.delegate scrollViewShouldScrollToTop:scrollView];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if (self.didScrollToTop) {
        self.didScrollToTop(scrollView, self.delegate);
        return;
    }
    [self scrollViewDidScrollToTop:scrollView];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (self.willBeginDecelerating) {
        self.willBeginDecelerating(scrollView, self.delegate);
        return;
    }
    [self.delegate scrollViewWillBeginDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.didEndDecelerating) {
        self.didEndDecelerating(scrollView, self.delegate);
        return;
    }
    [self.delegate scrollViewDidEndDecelerating:scrollView];
}

#pragma mark -

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (self.viewForZooming) {
        return self.viewForZooming(scrollView, self.delegate);
    }
    return [self.delegate viewForZoomingInScrollView:scrollView];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    if (self.willBeginZoomingView) {
        self.willBeginZoomingView(scrollView, view, self.delegate);
        return;
    }
    [self.delegate scrollViewWillBeginZooming:scrollView withView:view];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if (self.didEndZoomingView) {
        self.didEndZoomingView(scrollView, view, scale, self.delegate);
        return;
    }
    [self.delegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (self.didZoom) {
        self.didZoom(scrollView, self.delegate);
        return;
    }
    [self.delegate scrollViewDidZoom:scrollView];
}

#pragma mark -

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (self.didEndScrollingAnimation) {
        self.didEndScrollingAnimation(scrollView, self.delegate);
        return;
    }
    [self.delegate scrollViewDidEndScrollingAnimation:scrollView];
}

@end
