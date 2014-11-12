
#import "RFScrollViewPageControl.h"
#import "FBKVOController.h"

@interface RFScrollViewPageControl ()
@property (strong, nonatomic) FBKVOController *observer;
@end

@implementation RFScrollViewPageControl
RFInitializingRootForUIView

- (void)onInit {
    self.supportHalfPage = YES;
}

- (void)afterInit {
    // nothing
}

- (void)setScrollView:(UIScrollView *)scrollView {
    if (_scrollView != scrollView) {
        if (_scrollView && self.observer) {
            [self.observer unobserve:_scrollView keyPath:@keypath(scrollView, contentOffset)];
        }

        if (scrollView) {
            if (!self.observer) {
                self.observer = [[FBKVOController alloc] initWithObserver:self retainObserved:YES];
            }

            [self.observer observe:scrollView keyPath:@keypath(scrollView, contentOffset) options:(NSKeyValueObservingOptions)(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial) block:^(RFScrollViewPageControl *observer, id object, NSDictionary *change) {
                [observer setNeedsUpdatePage];
            }];
        }
        _scrollView = scrollView;
    }
}

- (void)setNeedsUpdatePage {
    CGFloat pageWidth = self.scrollView.bounds.size.width;
    if (pageWidth) {
        if (self.supportHalfPage) {
            self.numberOfPages = ceil(self.scrollView.contentSize.width / pageWidth);
            self.currentPage = ceil(self.scrollView.contentOffset.x / pageWidth- 0.5);
        }
        else {
            self.numberOfPages = self.scrollView.contentSize.width / pageWidth;
            self.currentPage = self.scrollView.contentOffset.x / pageWidth + 0.5;
        }
    }
    else {
        self.numberOfPages = 0;
        self.currentPage = 0;
    }
    _dout_float(self.scrollView.contentOffset.x / pageWidth)
}

@end
