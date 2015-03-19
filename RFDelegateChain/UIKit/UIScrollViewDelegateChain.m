
#import "UIScrollViewDelegateChain.h"

@implementation UIScrollViewDelegateChain

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(scrollViewDidScroll:)) {
        if (self.didScroll) return YES;
    }
    else if (aSelector == @selector(scrollViewWillBeginDragging:)) {
        if (self.willBeginDragging) return YES;
    }
    else if (aSelector == @selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)) {
        if (self.willEndDragging) return YES;
    }
    else if (aSelector == @selector(scrollViewDidEndDragging:willDecelerate:)) {
        if (self.didEndDragging) return YES;
    }
    else if (aSelector == @selector(scrollViewShouldScrollToTop:)) {
        if (self.shouldScrollToTop) return YES;
    }
    else if (aSelector == @selector(scrollViewDidScrollToTop:)) {
        if (self.didScrollToTop) return YES;
    }
    else if (aSelector == @selector(scrollViewWillBeginDecelerating:)) {
        if (self.willBeginDecelerating) return YES;
    }
    else if (aSelector == @selector(scrollViewDidEndDecelerating:)) {
        if (self.didEndDecelerating) return YES;
    }
    else if (aSelector == @selector(viewForZoomingInScrollView:)) {
        if (self.viewForZooming) return YES;
    }
    else if (aSelector == @selector(scrollViewWillBeginZooming:withView:)) {
        if (self.willBeginZoomingView) return YES;
    }
    else if (aSelector == @selector(scrollViewDidEndZooming:withView:atScale:)) {
        if (self.didEndZoomingView) return YES;
    }
    else if (aSelector == @selector(scrollViewDidZoom:)) {
        if (self.didZoom) return YES;
    }
    else if (aSelector == @selector(scrollViewDidEndScrollingAnimation:)) {
        if (self.didEndScrollingAnimation) return YES;
    }

    return [super respondsToSelector:aSelector];
}

#pragma mark -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.didScroll(scrollView, self.delegate);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.willBeginDragging(scrollView, self.delegate);
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    self.willEndDragging(scrollView, velocity, targetContentOffset, self.delegate);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.didEndDragging(scrollView, decelerate, self.delegate);
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    return self.shouldScrollToTop(scrollView, self.delegate);
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    self.didScrollToTop(scrollView, self.delegate);
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    self.willBeginDecelerating(scrollView, self.delegate);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.didEndDecelerating(scrollView, self.delegate);
}

#pragma mark -

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.viewForZooming(scrollView, self.delegate);
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    self.willBeginZoomingView(scrollView, view, self.delegate);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    self.didEndZoomingView(scrollView, view, scale, self.delegate);
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    self.didZoom(scrollView, self.delegate);
}

#pragma mark -

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.didEndScrollingAnimation(scrollView, self.delegate);
}

@end
