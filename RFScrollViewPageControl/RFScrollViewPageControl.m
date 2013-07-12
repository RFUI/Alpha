
#import "RFScrollViewPageControl.h"

@interface RFScrollViewPageControl ()
@property(assign, nonatomic) BOOL needUpdatePage;
@end

@implementation RFScrollViewPageControl
RFInitializingRootForUIView

- (void)onInit {
    self.supportHalfPage = YES;
}

- (void)afterInit {
    @weakify(self);
    [self rac_addObserver:self forKeyPath:@keypath(self, needUpdatePage) options:NSKeyValueObservingOptionNew queue:nil block:^(id observer, NSDictionary *change) {
        @strongify(self);

        [self setNeedsUpdatePage];
    }];
    
    [self setNeedsUpdatePage];
}

- (void)setNeedsUpdatePage {
    CGFloat pageWidth = self.scrollView.bounds.size.width;
    if (pageWidth) {
        if (self.supportHalfPage) {
            self.numberOfPages = ceil(self.scrollView.contentSize.width / pageWidth);
            self.currentPage = ceil(self.scrollView.contentOffset.x / pageWidth);
        }
        else {
            self.numberOfPages = self.scrollView.contentSize.width / pageWidth;
            self.currentPage = self.scrollView.contentOffset.x / pageWidth;
        }
    }
    else {
        self.numberOfPages = 0;
        self.currentPage = 0;
    }
    _dout_float(self.scrollView.contentOffset.x / pageWidth)
}

+ (NSSet *)keyPathsForValuesAffectingNeedUpdatePage {
    RFScrollViewPageControl *this;
    return [NSSet setWithObjects:
        @keypath(this, scrollView),
        @keypath(this, scrollView.bounds),
        @keypath(this, scrollView.contentOffset),
        @keypath(this, scrollView.contentSize),
        @keypath(this, supportHalfPage),
    nil];
}

@end
