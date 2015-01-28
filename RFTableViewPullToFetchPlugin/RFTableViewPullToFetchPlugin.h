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

@class RFTableViewPullToFetchPlugin;

typedef void (^RFPullToFetchIndicatorStatusChangeBlock)(RFTableViewPullToFetchPlugin *control, id indicatorView, RFPullToFetchIndicatorStatus status, CGFloat visibleHeight, UITableView *tableView);

@interface RFTableViewPullToFetchPlugin : RFDelegateChain <
    UITableViewDelegate
>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet id<UITableViewDelegate> delegate;

#pragma mark - Status

@property(readonly, getter = isFetching, nonatomic) BOOL fetching;
@property(readonly, getter = isHeaderProcessing, nonatomic) BOOL headerProcessing;
@property(readonly, getter = isFooterProcessing, nonatomic) BOOL footerProcessing;


// Default YES.
@property(assign, nonatomic, getter = isHeaderFetchingEnabled) IBInspectable BOOL headerFetchingEnabled;
@property(assign, nonatomic, getter = isFooterFetchingEnabled) IBInspectable BOOL footerFetchingEnabled;

/**
 Default, a fetch will be triggered only when user end dragging the table view.
 Set this property to `YES` will make the table view auto fetching near bottom.
 Default vaule is `NO`.
 */
@property (assign, nonatomic) IBInspectable BOOL autoFetchWhenScroll;
@property (assign, nonatomic) IBInspectable CGFloat autoFetchTolerateDistance;

#pragma mark - Layout

@property(strong, nonatomic) UIView *headerContainer;
@property(strong, nonatomic) UIView *footerContainer;

//@property(assign, nonatomic) RFPullToFetchTableIndicatorLayoutType headerStyle;
//@property(assign, nonatomic) RFPullToFetchTableIndicatorLayoutType footerStyle;

@property(copy, nonatomic) RFPullToFetchIndicatorStatusChangeBlock headerStatusChangeBlock;
@property (readonly, nonatomic) RFPullToFetchIndicatorStatus headerStatus;
- (void)setHeaderStatusChangeBlock:(void (^)(RFTableViewPullToFetchPlugin *control, id indicatorView, RFPullToFetchIndicatorStatus status, CGFloat visibleHeight, UITableView *tableView))headerStatusChangeBlock;

@property(copy, nonatomic) RFPullToFetchIndicatorStatusChangeBlock footerStatusChangeBlock;
@property (readonly, nonatomic) RFPullToFetchIndicatorStatus footerStatus;
- (void)setFooterStatusChangeBlock:(void (^)(RFTableViewPullToFetchPlugin *control, id indicatorView, RFPullToFetchIndicatorStatus status, CGFloat visibleHeight, UITableView *tableView))footerStatusChangeBlock;

- (void)setNeedsDisplayHeader;
- (void)setNeedsDisplayFooter;

#pragma mark - Event

@property(copy, nonatomic) void (^headerProcessBlock)(void);
@property(copy, nonatomic) void (^footerProcessBlock)(void);

// Call them method to notice proccess is finished.
- (void)markProcessFinshed;
- (void)headerProcessFinshed;
- (void)footerProcessFinshed;

// For manually trigger.
- (void)triggerHeaderProcess;
- (void)triggerFooterProcess;

#pragma mark - Control

// Default `YES`.
@property (assign, nonatomic) IBInspectable BOOL shouldHideHeaderWhenFooterProcessing;
@property (assign, nonatomic) IBInspectable BOOL shouldHideFooterWhenHeaderProcessing;


// If set `YES`, footer proccess will not be proccessed and `footerContainer` will be visiable. Usually for noticing user there are no more data. Header proccess will reset this property.
@property(assign, nonatomic) BOOL footerReachEnd;

// Default `NO`
@property(assign, nonatomic) IBInspectable BOOL shouldScrollToTopWhenHeaderEventTrigged;

// Default `NO`, not work rightnow.
@property(assign, nonatomic) IBInspectable BOOL shouldScrollToLastVisibleRowBeforeTriggeAfterFooterProccessFinished;

// Default `NO`
//@property (assign, nonatomic) BOOL shouldScrollToBottomWhenFooterEventTrigged;

@end
