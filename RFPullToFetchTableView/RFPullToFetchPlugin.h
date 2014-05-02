// TEST

#import "RFDelegateChain.h"

// Only RFPullToFetchTableIndicatorLayoutTypeStatic implemented at this time.
//typedef enum {
//    RFPullToFetchTableIndicatorLayoutTypeNone = 0,
//	RFPullToFetchTableIndicatorLayoutTypeStatic = 1,
//	RFPullToFetchTableIndicatorLayoutTypeFloat = 4,
//	RFPullToFetchTableIndicatorLayoutTypeFixed = 5,
//} RFPullToFetchTableIndicatorLayoutType;

typedef NS_ENUM(short, RFPullToFetchIndicatorStatus) {
    RFPullToFetchIndicatorStatusWaiting = 0,
    RFPullToFetchIndicatorStatusDragging,
    RFPullToFetchIndicatorStatusDecelerating,
    RFPullToFetchIndicatorStatusProcessing,
    RFPullToFetchIndicatorStatusFrozen
};

@class RFPullToFetchPlugin;

typedef void (^RFPullToFetchIndicatorStatusChangeBlock)(RFPullToFetchPlugin *control, id indicatorView, RFPullToFetchIndicatorStatus status, CGFloat visibleHeight, UITableView *tableView);

@interface RFPullToFetchPlugin : RFDelegateChain <
    UITableViewDelegate
>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet id<UITableViewDelegate> delegate;

#pragma mark - Status

@property(readonly, getter = isFetching, nonatomic) BOOL fetching;
@property(readonly, getter = isHeaderProcessing, nonatomic) BOOL headerProcessing;
@property(readonly, getter = isFooterProcessing, nonatomic) BOOL footerProcessing;


// Default YES.
@property(assign, nonatomic, getter = isHeaderFetchingEnabled) BOOL headerFetchingEnabled;
@property(assign, nonatomic, getter = isFooterFetchingEnabled) BOOL footerFetchingEnabled;

#pragma mark - Layout

@property(weak, nonatomic) UIView *headerContainer;
@property(weak, nonatomic) UIView *footerContainer;

//@property(assign, nonatomic) RFPullToFetchTableIndicatorLayoutType headerStyle;
//@property(assign, nonatomic) RFPullToFetchTableIndicatorLayoutType footerStyle;

@property(copy, nonatomic) RFPullToFetchIndicatorStatusChangeBlock headerStatusChangeBlock;
- (void)setHeaderStatusChangeBlock:(void (^)(RFPullToFetchPlugin *control, id indicatorView, RFPullToFetchIndicatorStatus status, CGFloat visibleHeight, UITableView *tableView))headerStatusChangeBlock;

@property(copy, nonatomic) RFPullToFetchIndicatorStatusChangeBlock footerStatusChangeBlock;
- (void)setFooterStatusChangeBlock:(void (^)(RFPullToFetchPlugin *control, id indicatorView, RFPullToFetchIndicatorStatus status, CGFloat visibleHeight, UITableView *tableView))footerStatusChangeBlock;

- (void)setNeedsDisplayHeader;
- (void)setNeedsDisplayFooter;

#pragma mark - Event

@property(copy, nonatomic) void (^headerProcessBlock)(void);
@property(copy, nonatomic) void (^footerProcessBlock)(void);

// Call them method to notice proccess is finished.
- (void)footerProcessFinshed;
- (void)headerProcessFinshed;

// For manually trigger.
- (void)triggerHeaderProcess;
- (void)triggerFooterProcess;

#pragma mark - Control

// Default `YES`.
@property (assign, nonatomic) BOOL shouldHideHeaderWhenFooterProcessing;
@property (assign, nonatomic) BOOL shouldHideFooterWhenHeaderProcessing;


// If set `YES`, footer proccess will not be proccessed and `footerContainer` will be visiable. Usually for noticing user there are no more data. Header proccess will reset this property.
@property(assign, nonatomic) BOOL footerReachEnd;

// Default `NO`
@property(assign, nonatomic) BOOL shouldScrollToTopWhenHeaderEventTrigged;

// Default `NO`, not work rightnow.
@property(assign, nonatomic) BOOL shouldScrollToLastVisibleRowBeforeTriggeAfterFooterProccessFinished;

// Default `NO`
//@property (assign, nonatomic) BOOL shouldScrollToBottomWhenFooterEventTrigged;

@end
