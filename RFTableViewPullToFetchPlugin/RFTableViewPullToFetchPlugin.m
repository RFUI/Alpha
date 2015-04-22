
#import "RFTableViewPullToFetchPlugin.h"
#import "UIScrollView+RFScrollViewContentDistance.h"
#import "UIView+RFAnimate.h"
#import "RFKVOWrapper.h"

#undef RFDebugLevel
#define RFDebugLevel 2

static NSTimeInterval RFPullToFetchAnimateTimeInterval = .2;

@interface RFTableViewPullToFetchPlugin ()
@property (readwrite, nonatomic) BOOL headerProcessing;
@property (readwrite, nonatomic) BOOL footerProcessing;
@property (assign, nonatomic) BOOL needsDisplayHeader;
@property (assign, nonatomic) BOOL needsDisplayFooter;

@property (strong, nonatomic) NSIndexPath *lastVisibleRowBeforeTriggeIndexPath;
@property (assign, nonatomic) CGPoint draggingTrackPoint;

@property (assign, nonatomic) BOOL animating;
@property (strong, nonatomic) id contentSizeChangedObserver;

@property (assign, nonatomic) BOOL hasFetched;
@end

@implementation RFTableViewPullToFetchPlugin
@dynamic delegate;

- (void)onInit {
    [super onInit];
//    self.headerStyle = RFPullToFetchTableIndicatorLayoutTypeStatic;
//    self.footerStyle = RFPullToFetchTableIndicatorLayoutTypeStatic;

    self.headerFetchingEnabled = YES;
    self.footerFetchingEnabled = YES;
    self.shouldHideHeaderWhenFooterProcessing = YES;
    self.shouldHideFooterWhenHeaderProcessing = YES;
}

- (void)afterInit {
    [super afterInit];
    dout_debug(@"RFPullToFetchPlugin status: delegate = %@, tableView = %@, headerContainer = %@, footerContainer = %@", self.delegate, self.tableView, self.headerContainer, self.footerContainer);
    [self setupViewHierarchy];
}

- (void)setTableView:(UITableView *)tableView {
    if (_tableView != tableView) {
        if (self.delegate) {
            _tableView.delegate = self.delegate;
        }

        if (tableView.delegate && tableView.delegate != self) {
            self.delegate = tableView.delegate;
        }
        tableView.delegate = self;

        self.hasFetched = NO;
        self.footerContainer.hidden = YES;

        @weakify(self);
        self.contentSizeChangedObserver = [tableView RFAddObserver:self forKeyPath:@keypath(tableView, contentSize) options:(NSKeyValueObservingOptions)(NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew) queue:nil block:^(id observer, NSDictionary *change) {
            @strongify(self);
            [self updateFooterLayout];
        }];

        _tableView = tableView;
    }
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

- (void)setupViewHierarchy {
    if (!self.tableView) return;

    UITableView *table = self.tableView;
    UIView *header = self.headerContainer;
    UIView *footer = self.footerContainer;
    if (header && header.superview != table) {
        header.width = table.width;
        header.x = 0;
        [table insertSubview:header atIndex:0];
        [self setNeedsDisplayHeader];
    }

    if (footer && footer.superview != table) {
        footer.width = table.width;
        footer.x = 0;
        [table insertSubview:footer atIndex:0];
        [self setNeedsDisplayFooter];
    }
}

- (RFPullToFetchIndicatorStatus)headerStatus {
    if (self.headerProcessing) {
        return RFPullToFetchIndicatorStatusProcessing;
    }
    if (self.tableView.dragging) {
        return RFPullToFetchIndicatorStatusDragging;
    }
    if (self.tableView.decelerating) {
        return RFPullToFetchIndicatorStatusDecelerating;
    }
    return RFPullToFetchIndicatorStatusWaiting;
}

- (RFPullToFetchIndicatorStatus)footerStatus {
    if (self.footerReachEnd) {
        return RFPullToFetchIndicatorStatusFrozen;
    }
    if (self.footerProcessing) {
        return RFPullToFetchIndicatorStatusProcessing;
    }
    if (self.tableView.dragging) {
        return RFPullToFetchIndicatorStatusDragging;
    }
    if (self.tableView.decelerating) {
        return RFPullToFetchIndicatorStatusDecelerating;
    }
    return RFPullToFetchIndicatorStatusWaiting;
}

- (void)triggerHeaderProcess {
    if (self.headerProcessing || !self.headerFetchingEnabled) return;
    _doutwork()

    if (self.footerProcessing) {
        self.footerProcessing = NO;
        [self updateFooterDisplay:NO];
    }

    self.headerProcessing = YES;
    self.footerReachEnd = NO;
    if (self.shouldHideFooterWhenHeaderProcessing) {
        self.footerContainer.hidden = YES;
    }

    BOOL animate = NO;

    if (self.headerProcessBlock) {
        self.headerProcessBlock();
    }

    if (self.headerProcessing) {
        animate = YES;
        [self updateHeaderDisplay:YES];
    }

    if (self.shouldScrollToTopWhenHeaderEventTrigged) {
        CGPoint conentOffset = self.tableView.contentOffset;
        conentOffset.y = animate? -self.headerContainer.height : 0;
        [self.tableView setContentOffset:conentOffset animated:animate];
    }
}

- (void)triggerFooterProcess {
    if (self.footerProcessing || !self.footerFetchingEnabled || self.footerReachEnd) return;
    _doutwork()

    if (self.headerProcessing) {
        self.headerProcessing = NO;
        [self updateHeaderDisplay:NO];
    }

    self.footerProcessing = YES;

    if (self.shouldScrollToLastVisibleRowBeforeTriggeAfterFooterProccessFinished) {
        self.lastVisibleRowBeforeTriggeIndexPath = [[self.tableView indexPathsForVisibleRows] lastObject];
    }

    if (self.footerProcessBlock) {
        self.footerProcessBlock();
    }

    if (self.footerProcessing) {
        [self updateFooterDisplay:YES];
    }
}

- (void)markProcessFinshed {
    if (self.headerProcessing) {
        [self headerProcessFinshed];
    }
    else {
        [self footerProcessFinshed];
    }
}

- (void)headerProcessFinshed {
    _doutwork()
    self.headerProcessing = NO;
    [self updateHeaderDisplay:YES];

    // If there are few cell to show after fetching, footer should be hidden.
    if (self.tableView.distanceBetweenContentAndBottom > 0 && !self.footerReachEnd) {
        self.hasFetched = NO;
        self.footerContainer.hidden = YES;
    }
    else {
        [self updateFooterDisplay:YES];
    }
}

- (void)footerProcessFinshed {
    _doutwork()

    if (self.shouldScrollToLastVisibleRowBeforeTriggeAfterFooterProccessFinished && self.lastVisibleRowBeforeTriggeIndexPath) {
        [self.tableView scrollToRowAtIndexPath:self.lastVisibleRowBeforeTriggeIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }

    self.footerProcessing = NO;
    [self updateFooterDisplay:YES];
    [self setNeedsDisplayHeader];
}

#pragma mark - Display

- (void)onDistanceBetweenContentAndTopChanged {
    CGFloat distance = self.tableView.distanceBetweenContentAndTop;
    dout_debug(@"Distance between content and top changed: %f", distance);

    [self updateHeaderVisable];
    [self updateFooterVisable];

    if (distance < -5 || self.headerContainer.hidden) return;
    [self updateHeaderIndicatorStatus];
}

- (void)onDistanceBetweenContentAndBottomChanged {
    CGFloat distance = self.tableView.distanceBetweenContentAndBottom;
    dout_debug(@"Distance between content and bottom changed: %f", distance);

    if (self.autoFetchWhenScroll) {
        if (distance > -self.autoFetchTolerateDistance) {
            if (!self.fetching) {
                [self triggerFooterProcess];
            }
        }
    }

    if (distance < -5 || self.footerContainer.hidden) return;
    [self updateFooterIndicatorStatus];
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

- (void)updateHeaderDisplay:(BOOL)animated {
    dout_debug(@"Update header display%@", animated? @" animated!" : @".");
    [self updateHeaderVisable];

    if (self.animating) {
        animated = YES;
    }
    if (animated) {
        self.animating = YES;
    }
    [UIView animateWithDuration:RFPullToFetchAnimateTimeInterval delay:0 options:UIViewAnimationOptionBeginFromCurrentState animated:animated beforeAnimations:nil animations:^{
        [self updateHeaderLayout];

        UITableView *tb = self.tableView;
        if (!tb || !tb.window) return;

        UIEdgeInsets edge = tb.contentInset;
        edge.top = (self.headerProcessing? self.headerContainer.height : 0);
        tb.contentInset = edge;
    } completion:^(BOOL finished) {
        if (finished) {
            self.animating = NO;
        }
    }];

    [self updateHeaderIndicatorStatus];
    self.needsDisplayHeader = NO;
}

- (void)updateFooterDisplay:(BOOL)animated {
    dout_debug(@"Update footer display%@", animated? @" animated!" : @".");
    [self updateFooterVisable];

    if (self.animating) {
        animated = YES;
    }
    if (animated) {
        self.animating = YES;
    }
    [UIView animateWithDuration:RFPullToFetchAnimateTimeInterval delay:0 options:UIViewAnimationOptionBeginFromCurrentState animated:animated beforeAnimations:nil animations:^{
        [self updateFooterLayout];

        UITableView *tb = self.tableView;
        if (!tb || !tb.window) return;

        UIEdgeInsets edge = tb.contentInset;
        edge.bottom = (self.footerProcessing? self.footerContainer.height : 0);
        tb.contentInset = edge;
        if (tb.tableFooterView) {
            tb.tableFooterView = tb.tableFooterView;
        }
    } completion:^(BOOL finished) {
        if (finished) {
            self.animating = NO;
        }
    }];

    [self updateFooterIndicatorStatus];
    self.needsDisplayFooter = NO;
}

- (void)updateHeaderLayout {
    UIView *header = self.headerContainer;
    header.y = -header.height;
    _dout_debug(@"Update layout header y = %f", header.y);
}

- (void)updateFooterLayout {
    UIView *footer = self.footerContainer;
    footer.y = self.tableView.contentSize.height;
    _dout_debug(@"Update layout footer y = %f", footer.y);
}

- (void)updateHeaderVisable {
    UIView *header = self.headerContainer;
    CGFloat distance = self.tableView.distanceBetweenContentAndTop;

    if (!self.headerFetchingEnabled) {
        header.hidden = YES;
    }
    else if (self.headerProcessing) {
        header.hidden = NO;
    }
    else if ((self.shouldHideHeaderWhenFooterProcessing && self.footerProcessing)
        || distance < 0) {
        header.hidden = YES;
    }
    else {
        header.hidden = NO;
    }
    _dout_bool(header.hidden)
}

- (void)updateFooterVisable {
    UIView *footer = self.footerContainer;
    CGFloat distance = self.tableView.distanceBetweenContentAndBottom;

    if (!self.footerFetchingEnabled) {
        footer.hidden = YES;
    }
    else if (self.footerProcessing) {
        footer.hidden = NO;
    }
    else if ((self.shouldHideFooterWhenHeaderProcessing && self.headerProcessing)
        || distance <= 0
        || (self.tableView.distanceBetweenContentAndTop > 0 && !self.footerReachEnd)) {
        footer.hidden = YES;
    }
    else {
        footer.hidden = NO;
    }
    _dout_bool(footer.hidden)
}

- (void)updateHeaderIndicatorStatus {
    if (self.headerStatusChangeBlock) {
        self.headerStatusChangeBlock(self, self.headerContainer, self.headerStatus, self.tableView.distanceBetweenContentAndTop, self.tableView);
    }
}

- (void)updateFooterIndicatorStatus {
    if (self.footerStatusChangeBlock) {
        self.footerStatusChangeBlock(self, self.footerContainer, self.footerStatus, self.tableView.distanceBetweenContentAndBottom, self.tableView);
    }
}

#pragma mark - Other Status

- (void)setFooterReachEnd:(BOOL)footerReachEnd {
    dout_debug(@"setFooterReachEnd: %@", footerReachEnd? @"YES" : @"NO");
    _footerReachEnd = footerReachEnd;
    [self updateFooterDisplay:NO];
}

- (BOOL)isFetching {
    return (self.headerProcessing || self.footerProcessing);
}

+ (NSSet *)keyPathsForValuesAffectingFetching {
    RFTableViewPullToFetchPlugin *this;
    return [NSSet setWithObjects:@keypath(this, headerProcessing), @keypath(this, footerProcessing), nil];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    dout_debug(@"Scrolling at %.2f", scrollView.contentOffset.y);
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:scrollView];
    }

    if (!self.hasFetched) {
        [self updateFooterDisplay:NO];
        self.hasFetched = YES;
    }

    [self onDistanceBetweenContentAndTopChanged];
    [self onDistanceBetweenContentAndBottomChanged];
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

    [self updateHeaderDisplay:decelerate];
    [self updateFooterDisplay:decelerate];

    dout_debug(@"headerContainer = %@", self.headerContainer)
    dout_debug(@"footerContainer = %@", self.footerContainer)
    dout_debug(@"contentInset = %@", NSStringFromUIEdgeInsets(scrollView.contentInset))

    if (scrollView.contentOffset.y < self.draggingTrackPoint.y) {
        dout_debug(@"Drag down");
        if (!self.headerFetchingEnabled) return;

        if (!self.isFetching && scrollView.distanceBetweenContentAndTop > self.headerContainer.height) {
            [self triggerHeaderProcess];
            return;
        }
    }

    if (scrollView.contentOffset.y > self.draggingTrackPoint.y) {
        dout_debug(@"Drag up");
        if (!self.footerFetchingEnabled || self.footerReachEnd) return;

        if (!self.isFetching && scrollView.distanceBetweenContentAndBottom > self.footerContainer.height) {
            [self triggerFooterProcess];
            return;
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
}

@end
