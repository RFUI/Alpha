
#import "RFScrollViewPageControl.h"

@interface RFScrollViewPageControl ()
@property (strong, nonatomic) id observer;
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
        if (_scrollView) {
            [_scrollView rac_removeObserverWithIdentifier:self.observer];
        }

        if (scrollView) {
            self.observer = [scrollView rac_addObserver:self forKeyPath:@keypath(scrollView, contentOffset) options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial queue:nil block:^(RFScrollViewPageControl *observer, NSDictionary *change) {
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
