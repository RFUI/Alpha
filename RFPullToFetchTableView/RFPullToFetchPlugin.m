
#import "RFPullToFetchPlugin.h"
#import "UIScrollView+RFScrollViewContentDistance.h"
#import "UIView+RFAnimate.h"

#undef RFDebugLevel
#define RFDebugLevel 5

NSTimeInterval RFPullToFetchAnimateTimeInterval = 2;

@interface RFPullToFetchPlugin ()
@property (readwrite, nonatomic) BOOL headerProcessing;
@property (readwrite, nonatomic) BOOL footerProcessing;

@property (strong, nonatomic) NSIndexPath *lastVisibleRowBeforeTriggeIndexPath;
@property (assign, nonatomic) CGPoint draggingTrackPoint;

@property (assign, nonatomic) BOOL needsDisplayHeader;
@property (assign, nonatomic) BOOL needsDisplayFooter;

@property (assign, nonatomic) BOOL animating;
@property (strong, nonatomic) id contentBetweenBottomDistanceObserver;
@end

@implementation RFPullToFetchPlugin

- (void)onInit {
    self.headerStyle = RFPullToFetchTableIndicatorLayoutTypeStatic;
    self.footerStyle = RFPullToFetchTableIndicatorLayoutTypeStatic;

    self.headerFetchingEnabled = YES;
    self.footerFetchingEnabled = YES;
    self.shouldHideHeaderWhenFooterProcessing = YES;
    self.shouldHideFooterWhenHeaderProcessing = YES;
    self.shouldScrollToTopWhenHeaderEventTrigged = YES;
    self.shouldScrollToLastVisibleRowBeforeTriggeAfterFooterProccessFinished = YES;
}

- (void)afterInit {
    dout_debug(@"RFPullToFetchPlugin status: delegate = %@, tableView = %@, headerContainer = %@, footerContainer = %@", self.delegate, self.tableView, self.headerContainer, self.footerContainer);
}

- (void)setTableView:(UITableView *)tableView {
    if (_tableView != tableView) {
        if (self.delegate) {
            _tableView.delegate = self.delegate;
        }

        if (tableView.delegate) {
            self.delegate = tableView.delegate;
        }
        tableView.delegate = self;

        @weakify(self);
        self.contentBetweenBottomDistanceObserver = [tableView rac_addObserver:self forKeyPath:@keypath(tableView, distanceBetweenContentAndBottom) options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew queue:nil block:^(id observer, NSDictionary *change) {
            @strongify(self);
            [self onDistanceBetweenContentAndBottomChanged];
        }];
        _tableView = tableView;
    }
}

- (void)dealloc {
    self.headerFetchingEnabled = NO;
    self.footerFetchingEnabled = NO;
}

- (void)setHeaderFetchingEnabled:(BOOL)headerFetchingEnabled {
    if (_headerFetchingEnabled != headerFetchingEnabled) {
        _headerFetchingEnabled = headerFetchingEnabled;
        [self setNeedsDisplayHeader];
    }
}

- (void)setFooterFetchingEnabled:(BOOL)footerFetchingEnabled {
    if (_footerFetchingEnabled != footerFetchingEnabled) {
        _footerFetchingEnabled = footerFetchingEnabled;
        [self setNeedsDisplayFooter];
    }
}

- (void)triggerHeaderProcess {
    if (self.headerProcessing) return;

    doutwork()
    self.headerProcessing = YES;
    self.footerReachEnd = NO;

    if (self.headerProcessBlock) {
        self.headerProcessBlock();
    }

    if (self.headerProcessing) {
        [self updateHeaderDisplay:YES];

        if (self.shouldScrollToTopWhenHeaderEventTrigged) {
            CGPoint conentOffset = self.tableView.contentOffset;
            conentOffset.y = -self.headerContainer.height;
            [self.tableView setContentOffset:conentOffset animated:YES];
        }
    }
}

- (void)triggerFooterProcess {
    doutwork()
    if (self.footerProcessing) return;
    self.footerProcessing = YES;

    [self setFooterContainerVisible:YES animated:YES];
    if (self.shouldScrollToLastVisibleRowBeforeTriggeAfterFooterProccessFinished) {
        self.lastVisibleRowBeforeTriggeIndexPath = [[self.tableView indexPathsForVisibleRows] lastObject];
    }

    if (self.footerProcessBlock) {
        self.footerProcessBlock();
    }
}

- (void)headerProcessFinshed {
    if (!self.headerProcessing) return;
    doutwork()

    self.headerProcessing = NO;
    [self updateHeaderDisplay:YES];
}

- (void)footerProcessFinshed {
    if (!self.footerProcessing) return;
    doutwork()

    if (self.shouldScrollToLastVisibleRowBeforeTriggeAfterFooterProccessFinished && self.lastVisibleRowBeforeTriggeIndexPath) {
        [self.tableView scrollToRowAtIndexPath:self.lastVisibleRowBeforeTriggeIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }

    self.footerProcessing = NO;
    [self updateFooterDisplay:YES];
}

#pragma mark - Display

- (void)onDistanceBetweenContentAndTopChanged {
    CGFloat distance = self.tableView.distanceBetweenContentAndTop;
    if (distance < -5) return;

    if (self.headerVisibleChangeBlock && !self.headerContainer.hidden) {
        dout_debug(@"Distance between content and top: %f", distance);
        self.headerVisibleChangeBlock(!self.headerContainer.hidden, distance, (distance >= self.headerContainer.height), self.isHeaderProcessing);
    }
}

- (void)onDistanceBetweenContentAndBottomChanged {
    CGFloat distance = self.tableView.distanceBetweenContentAndBottom;
    if (distance < -5) return;

    if (self.footerVisibleChangeBlock && !self.footerContainer.hidden) {
        dout_debug(@"Distance between content and bottom: %f", distance);
        self.footerVisibleChangeBlock(!self.footerContainer.hidden, distance, (distance >= self.footerContainer.height), self.isFooterProcessing, self.footerReachEnd);
    }
}

- (void)setFooterContainerVisible:(BOOL)isVisible animated:(BOOL)animated {
    return;
    dout_debug(@"setFooterContainerVisible:%@ animated:%@", isVisible? @"YES" : @"NO", animated? @"YES" : @"NO");
    if (isVisible) {
        self.footerContainer.hidden = NO;
    }
    [UIView animateWithDuration:RFPullToFetchAnimateTimeInterval delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animated:animated beforeAnimations:nil animations:^{
        switch (self.footerStyle) {
            case RFPullToFetchTableIndicatorLayoutTypeStatic: {
                UIEdgeInsets edge = self.tableView.contentInset;
                edge.bottom = (isVisible? self.footerContainer.height : 0);
                self.tableView.contentInset = edge;
                break;
            }
            case RFPullToFetchTableIndicatorLayoutTypeFixed:
            case RFPullToFetchTableIndicatorLayoutTypeFloat:
            case RFPullToFetchTableIndicatorLayoutTypeNone:
                break;
        }
    } completion:^(BOOL finished) {
        self.footerContainer.hidden = !isVisible;
    }];
}

- (void)updateHeaderDisplay:(BOOL)animated {
    dout_debug(@"Update header display%@", animated? @" animated!" : @".");
    UIView *header = self.headerContainer;

    if (self.shouldHideHeaderWhenFooterProcessing && self.footerProcessing) {
        header.hidden = YES;
    }
    else {
        header.hidden = NO;
    }

    CGFloat distance = self.tableView.distanceBetweenContentAndTop;
    if (self.animating) {
        animated = YES;
    }
    if (animated) {
        self.animating = YES;
    }
    [UIView animateWithDuration:RFPullToFetchAnimateTimeInterval delay:0 options:UIViewAnimationOptionBeginFromCurrentState animated:animated beforeAnimations:nil animations:^{
        header.y = -header.height;

        UIEdgeInsets edge = self.tableView.contentInset;
        edge.top = (self.headerProcessing? self.headerContainer.height : 0);
        self.tableView.contentInset = edge;
    } completion:^(BOOL finished) {
        if (finished) {
            self.animating = NO;
        }
    }];

    if (self.headerVisibleChangeBlock) {
        self.headerVisibleChangeBlock(!header.hidden, distance, (distance >= self.headerContainer.height), self.isHeaderProcessing);
    }

    self.needsDisplayHeader = NO;
}

- (void)updateFooterDisplay:(BOOL)animated {
    return;
    dout_debug(@"Update footer display%@", animated? @" animated!" : @".");
    UIView *footer = self.footerContainer;
    switch (self.footerStyle) {
        case RFPullToFetchTableIndicatorLayoutTypeFixed:
            footer.bottomMargin = 0;
            break;

        case RFPullToFetchTableIndicatorLayoutTypeStatic:
            self.footerContainer.y = self.tableView.contentSize.height;
            break;

        case RFPullToFetchTableIndicatorLayoutTypeFloat:
            if (self.footerContainer.bottomMargin > 0) {
                self.footerContainer.bottomMargin = 0;
            }
            break;

        case RFPullToFetchTableIndicatorLayoutTypeNone:
            self.footerContainer.hidden = YES;
            break;
    }

    if ((self.shouldHideFooterWhenHeaderProcessing && self.headerProcessing)
        || self.footerReachEnd) {
        footer.hidden = YES;
    }
    else {
        footer.hidden = NO;
    }

    CGFloat distance = self.tableView.distanceBetweenContentAndBottom;

    if (self.footerVisibleChangeBlock) {
        self.footerVisibleChangeBlock(!footer.hidden, distance, (distance >= self.footerContainer.height), self.isFooterProcessing, self.footerReachEnd);
    }

    self.needsDisplayFooter = NO;
}

- (void)setNeedsDisplayHeader {
    if (self.needsDisplayHeader) return;

    self.needsDisplayHeader = YES;
    dispatch_after_seconds(0, ^{
        [self updateHeaderDisplay:NO];
    });
}
- (void)setNeedsDisplayFooter {
    if (self.needsDisplayFooter) return;

    self.needsDisplayFooter = YES;
    dispatch_after_seconds(0, ^{
        [self updateFooterDisplay:NO];
    });
}

#pragma mark - Other Status

- (void)setFooterReachEnd:(BOOL)footerReachEnd {
    dout_debug(@"setFooterReachEnd: %@", footerReachEnd? @"YES" : @"NO");
    _footerReachEnd = footerReachEnd;
}

- (BOOL)isFetching {
    return (self.headerProcessing || self.footerProcessing);
}

+ (NSSet *)keyPathsForValuesAffectingFetching {
    RFPullToFetchPlugin *this;
    return [NSSet setWithObjects:@keypath(this, headerProcessing), @keypath(this, footerProcessing), nil];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    _dout_debug(@"Scrolling at %.2f", scrollView.contentOffset.y);
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:scrollView];
    }

    [self onDistanceBetweenContentAndTopChanged];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.delegate scrollViewWillBeginDragging:scrollView];
    }
    dout_debug(@"TableView Will BeginDragging");

    self.draggingTrackPoint = scrollView.contentOffset;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    dout_debug(@"TableView did end dragging. %@", decelerate? @"Will decelerate" : @"No decelerate");

    if (scrollView.contentOffset.y == self.draggingTrackPoint.y) return;
    dout_debug(@"headerContainer = %@", self.headerContainer)
    dout_debug(@"footerContainer = %@", self.footerContainer)
    dout_debug(@"contentInset = %@", NSStringFromUIEdgeInsets(scrollView.contentInset))

    [self updateHeaderDisplay:YES];
    [self updateFooterDisplay:YES];

    if (scrollView.contentOffset.y < self.draggingTrackPoint.y) {
        dout_debug(@"Drag down");
        if (!self.headerFetchingEnabled) return;

        if (!self.isFetching && scrollView.distanceBetweenContentAndTop > self.headerContainer.height) {
            [self triggerHeaderProcess];
        }
    }
    else {
        dout_debug(@"Drag up");
        if (!self.footerFetchingEnabled) return;

        if (!self.footerReachEnd && !self.isFetching && scrollView.distanceBetweenContentAndBottom > self.footerContainer.height) {
            [self triggerFooterProcess];
        }
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [self.delegate scrollViewWillBeginDecelerating:scrollView];
    }
    dout_debug(@"TableView start decelerating.");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.delegate scrollViewDidEndDecelerating:scrollView];
    }
    dout_debug(@"TableView did end decelerating.");

    [self setNeedsDisplayHeader];
    [self setNeedsDisplayFooter];
}

@end
