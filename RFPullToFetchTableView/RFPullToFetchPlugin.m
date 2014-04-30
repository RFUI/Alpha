
#import "RFPullToFetchPlugin.h"
#import "UIScrollView+RFScrollViewContentDistance.h"
#import "UIView+RFAnimate.h"

#undef RFDebugLevel
#define RFDebugLevel 5

@interface RFPullToFetchPlugin ()
@property (readwrite, nonatomic) BOOL headerProcessing;
@property (readwrite, nonatomic) BOOL footerProcessing;

@property (strong, nonatomic) NSIndexPath *lastVisibleRowBeforeTriggeIndexPath;
@property (assign, nonatomic) CGPoint draggingTrackPoint;
@end

@implementation RFPullToFetchPlugin

- (void)onInit {
    self.headerStyle = RFPullToFetchTableIndicatorLayoutTypeStatic;
    self.footerStyle = RFPullToFetchTableIndicatorLayoutTypeStatic;

    self.headerFetchingEnabled = YES;
    self.footerFetchingEnabled = YES;
    self.shouldScrollToTopWhenHeaderEventTrigged = YES;
    self.shouldScrollToLastVisibleRowBeforeTriggeAfterFooterProccessFinished = YES;
}

- (void)afterInit {
    dout_debug(@"RFPullToFetchPlugin status: delegate = %@, tableView = %@, headerContainer = %@, footerContainer = %@", self.delegate, self.tableView, self.headerContainer, self.footerContainer);
}

- (void)setTableView:(UITableView *)tableView {
    if (_tableView != tableView) {
        _tableView.delegate = self.delegate;

        self.delegate = tableView.delegate;
        tableView.delegate = self;
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

        if (!headerFetchingEnabled) {
            [self setHeaderContainerVisible:NO animated:NO];
        }
    }
}

- (void)setFooterFetchingEnabled:(BOOL)footerFetchingEnabled {
    if (_footerFetchingEnabled != footerFetchingEnabled) {
        _footerFetchingEnabled = footerFetchingEnabled;

        if (!footerFetchingEnabled) {
            [self setFooterContainerVisible:NO animated:NO];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    _doutwork()
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:scrollView];
    }

    [self updateLayout:NO];
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

    if (scrollView.contentOffset.y > self.draggingTrackPoint.y) {
        dout_debug(@"Drag down");
        if (self.headerFetchingEnabled && !self.isFetching && scrollView.distanceBetweenContentAndTop > self.headerContainer.height) {
            [self triggerHeaderProccess];
        }
    }
    else {
        dout_debug(@"Drag up");
        if (self.footerFetchingEnabled && !self.footerReachEnd && !self.isFetching && scrollView.distanceBetweenContentAndBottom > self.footerContainer.height) {
            [self triggerFooterProccess];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.delegate scrollViewDidEndDecelerating:scrollView];
    }
    dout_debug(@"TableView did end decelerating.");

    [self updateLayout:NO];
}



- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [self.delegate scrollViewDidEndScrollingAnimation:scrollView];
    }

}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ([self.delegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
    dout_point(velocity)
}

- (void)onDistanceBetweenContentAndTopChanged {
    _dout_float(self.distanceBetweenContentAndTop);

    CGFloat distance = self.tableView.distanceBetweenContentAndTop;
    BOOL isVisible = (distance >= 0 && !self.footerProcessing);
    self.headerContainer.hidden = !isVisible;

    if (self.headerVisibleChangeBlock) {
        self.headerVisibleChangeBlock(isVisible, distance, (distance >= self.headerContainer.height), self.isHeaderProcessing);
    }
}

- (void)onDistanceBetweenContentAndBottomChanged {
    _dout_float(self.distanceBetweenContentAndBottom);

    CGFloat distance = self.tableView.distanceBetweenContentAndBottom;
    BOOL isVisible = (distance > 0 && !self.headerProcessing);
    // 解决内容过少总是显示 footer 的问题
    if (!self.headerContainer.hidden && !self.footerProcessing && !self.footerReachEnd) {
        isVisible = NO;
    }
    //    if (!(self.isDragging || self.isDecelerating) || self.footerProcessing) {
    //        isVisible = NO;
    //    }
    self.footerContainer.hidden = !isVisible;

    if (self.footerVisibleChangeBlock && isVisible) {
        self.footerVisibleChangeBlock(isVisible, distance, (distance >= self.footerContainer.height), self.isFooterProcessing, self.footerReachEnd);
    }
}

- (void)triggerHeaderProccess {
    doutwork()
    if (self.headerProcessing) return;
    self.headerProcessing = YES;
    self.footerReachEnd = NO;

    if (self.headerProccessBlock) {
        self.headerProccessBlock();
    }

    // The proccess may finished immediately after process block executed.
    if (self.headerProcessing) {
        [self setHeaderContainerVisible:YES animated:YES];
        if (self.shouldScrollToTopWhenHeaderEventTrigged) {
            CGPoint conentOffset = self.tableView.contentOffset;
            conentOffset.y = -self.headerContainer.height;
            [self.tableView setContentOffset:conentOffset animated:YES];
        }
    }
}

- (void)triggerFooterProccess {
    doutwork()
    if (self.footerProcessing) return;
    self.footerProcessing = YES;

    if (self.footerProccessBlock) {
        self.footerProccessBlock();
    }

    // The proccess may finished immediately after process block executed.
    if (self.footerProcessing) {
        [self setFooterContainerVisible:YES animated:YES];
        if (self.shouldScrollToLastVisibleRowBeforeTriggeAfterFooterProccessFinished) {
            self.lastVisibleRowBeforeTriggeIndexPath = [[self.tableView indexPathsForVisibleRows] lastObject];
        }
    }
}

- (void)headerProccessFinshed {
    doutwork()
    if (!self.headerProcessing) return;

    self.headerProcessing = NO;
    [self setHeaderContainerVisible:NO animated:YES];
}

- (void)footerProccessFinshed {
    doutwork()
    if (!self.footerProcessing) return;

    self.footerProcessing = NO;
    [self setFooterContainerVisible:NO animated:YES];
    if (self.shouldScrollToLastVisibleRowBeforeTriggeAfterFooterProccessFinished && self.lastVisibleRowBeforeTriggeIndexPath) {
        [self.tableView scrollToRowAtIndexPath:self.lastVisibleRowBeforeTriggeIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark - Layout
- (void)updateLayout:(BOOL)animated {
    if (self.headerContainer && !self.headerContainer.hidden) {
        switch (self.headerStyle) {
            case RFPullToFetchTableIndicatorLayoutTypeStatic:
                self.headerContainer.y = -self.headerContainer.height;
                break;
            case RFPullToFetchTableIndicatorLayoutTypeFloat:

                break;

            case RFPullToFetchTableIndicatorLayoutTypeFixed:
                self.headerContainer.x = 0;
                break;

            case RFPullToFetchTableIndicatorLayoutTypeNone:
                self.headerContainer.hidden = YES;
                break;
        }
    }

    if (self.footerContainer && !self.footerContainer.hidden) {
        switch (self.footerStyle) {
            case RFPullToFetchTableIndicatorLayoutTypeFixed:
                self.footerContainer.bottomMargin = 0;
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
    }
}

- (void)setHeaderContainerVisible:(BOOL)isVisible animated:(BOOL)animated {
    dout_debug(@"setHeaderContainerVisible:%@ animated:%@", isVisible? @"YES" : @"NO", animated? @"YES" : @"NO");
    if (isVisible) {
        self.headerContainer.hidden = NO;
    }
    [UIView animateWithDuration:.2f delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animated:animated beforeAnimations:nil animations:^{
        switch (self.headerStyle) {
            case RFPullToFetchTableIndicatorLayoutTypeStatic: {
                UIEdgeInsets edge = self.tableView.contentInset;
                edge.top = (isVisible? self.headerContainer.height : 0);
                self.tableView.contentInset = edge;
                break;
            }
            case RFPullToFetchTableIndicatorLayoutTypeFixed:
            case RFPullToFetchTableIndicatorLayoutTypeFloat:
            case RFPullToFetchTableIndicatorLayoutTypeNone:
                break;
        }
    } completion:^(BOOL finished) {
        self.headerContainer.hidden = !isVisible;
//        [self onDistanceBetweenContentAndTopChanged];   // fix after finish fetching header not show. ugly
        [self updateLayout:NO];
    }];
}

- (void)setFooterContainerVisible:(BOOL)isVisible animated:(BOOL)animated {
    dout_debug(@"setFooterContainerVisible:%@ animated:%@", isVisible? @"YES" : @"NO", animated? @"YES" : @"NO");
    if (isVisible) {
        self.footerContainer.hidden = NO;
    }
    [UIView animateWithDuration:.2f delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animated:animated beforeAnimations:nil animations:^{
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
//        [self onDistanceBetweenContentAndTopChanged];   // fix after finish fetching header not show. ugly
        [self updateLayout:NO];
    }];
}

#pragma mark - Other Status

- (BOOL)isFetching {
    return (self.headerProcessing || self.footerProcessing);
}

+ (NSSet *)keyPathsForValuesAffectingFetching {
    RFPullToFetchPlugin *this;
    return [NSSet setWithObjects:@keypath(this, headerProcessing), @keypath(this, footerProcessing), nil];
}



@end
