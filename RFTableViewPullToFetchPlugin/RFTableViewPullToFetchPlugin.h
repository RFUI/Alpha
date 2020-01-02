/*!
 RFTableViewPullToFetchPlugin
 RFAlpha
 
 Copyright © 2014-2015, 2017-2018 RFUI.
 https://github.com/RFUI/RFAlpha
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */

#import <RFDelegateChain/RFDelegateChain.h>

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
    
    /// Keeps visable, unable to trigger process
    RFPullToFetchIndicatorStatusFrozen
};

@class RFTableViewPullToFetchPlugin;

typedef void (^RFPullToFetchIndicatorStatusChangeBlock)(RFTableViewPullToFetchPlugin *__nonnull control, id __nonnull indicatorView, RFPullToFetchIndicatorStatus status, CGFloat visibleHeight, UITableView *__nonnull tableView);

@interface RFTableViewPullToFetchPlugin : RFDelegateChain <
    UITableViewDelegate
>

@property (weak, nullable, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nullable, nonatomic) IBOutlet id<UITableViewDelegate> delegate;

#pragma mark - Status

@property (readonly, getter = isFetching) BOOL fetching;
@property (readonly, getter = isHeaderProcessing) BOOL headerProcessing;
@property (readonly, getter = isFooterProcessing) BOOL footerProcessing;

/// Default YES.
@property (nonatomic, getter = isHeaderFetchingEnabled) IBInspectable BOOL headerFetchingEnabled;
@property (nonatomic, getter = isFooterFetchingEnabled) IBInspectable BOOL footerFetchingEnabled;

/**
 Default, a fetch will be triggered only when user end dragging the table view.
 Set this property to `YES` will make the table view auto fetching near bottom.
 Default vaule is `NO`.
 */
@property IBInspectable BOOL autoFetchWhenScroll;
@property IBInspectable CGFloat autoFetchTolerateDistance;

#pragma mark - Layout

@property (nullable) UIView *headerContainer;
@property (nullable) UIView *footerContainer;

//@property RFPullToFetchTableIndicatorLayoutType headerStyle;
//@property RFPullToFetchTableIndicatorLayoutType footerStyle;

@property (nullable) RFPullToFetchIndicatorStatusChangeBlock headerStatusChangeBlock;
@property (readonly) RFPullToFetchIndicatorStatus headerStatus;

@property(nullable) RFPullToFetchIndicatorStatusChangeBlock footerStatusChangeBlock;
@property (readonly) RFPullToFetchIndicatorStatus footerStatus;

- (void)setNeedsDisplayHeader;
- (void)setNeedsDisplayFooter;

#pragma mark - Event

@property (nullable) void (^headerProcessBlock)(void);
@property (nullable) void (^footerProcessBlock)(void);

/// Call them method to notice proccess is finished.
- (void)markProcessFinshed;
- (void)headerProcessFinshed;
- (void)footerProcessFinshed;

/// For manually trigger.
- (void)triggerHeaderProcess;
- (void)triggerFooterProcess;

#pragma mark - Control

/// Default `YES`.
@property IBInspectable BOOL shouldHideHeaderWhenFooterProcessing;
@property IBInspectable BOOL shouldHideFooterWhenHeaderProcessing;

/**
 If set `YES`, footer proccess will not be proccessed and `footerContainer` will be visiable.
 Usually for noticing user there are no more data. Header proccess will reset this property.
 */
@property (nonatomic) BOOL footerReachEnd;

/// Default `NO`
@property IBInspectable BOOL shouldScrollToTopWhenHeaderEventTrigged;

/// Default `NO`, not work rightnow.
@property IBInspectable BOOL shouldScrollToLastVisibleRowBeforeTriggeAfterFooterProccessFinished;

/// Default `NO`
//@property BOOL shouldScrollToBottomWhenFooterEventTrigged;

@end
