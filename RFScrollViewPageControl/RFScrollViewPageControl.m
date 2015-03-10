
#import "RFScrollViewPageControl.h"
#import "RFKVOWrapper.h"

@interface RFScrollViewPageControl ()
@property (weak, nonatomic) id observer;
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
            [_scrollView RFRemoveObserverWithIdentifier:self.observer];
        }

        if (scrollView) {
            self.observer = [scrollView RFAddObserver:self forKeyPath:@keypath(scrollView, contentOffset) options:(NSKeyValueObservingOptions)(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial) queue:nil block:^(RFScrollViewPageControl *observer, NSDictionary *change) {
                [observer setNeedsUpdatePage];
            }];
        }
        _scrollView = scrollView;
    }
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    [super setNumberOfPages:numberOfPages];

    if (self.hidesWhenOnePage) {
        self.hidden = (numberOfPages <= 1);
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
