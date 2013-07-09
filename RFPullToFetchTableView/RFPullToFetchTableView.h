/*!
    RFPullToFetchTableView
    RFUI

    Copyright (c) 2013 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php
 
    Alpha
 */

#import "RFRuntime.h"
#import "RFInitializing.h"
#import "UIScrollView+RFScrollViewContentDistance.h"

// Only RFAutoFetchTableContainerStyleStatic implemented at this time.
typedef enum {
    RFAutoFetchTableContainerStyleNone = 0,
	RFAutoFetchTableContainerStyleStatic = 1,
	RFAutoFetchTableContainerStyleFloat = 4,
	RFAutoFetchTableContainerStyleFloatFixed = 5,
} RFAutoFetchTableContainerStyle;

@interface RFPullToFetchTableView : UITableView
<RFInitializing>

// Default YES.
@property(assign, nonatomic, getter = isHeaderFetchingEnabled) BOOL headerFetchingEnabled;
@property(assign, nonatomic, getter = isFooterFetchingEnabled) BOOL footerFetchingEnabled;

#pragma mark - Layout

@property(weak, nonatomic) UIView *headerContainer;
@property(weak, nonatomic) UIView *footerContainer;

@property(assign, nonatomic) RFAutoFetchTableContainerStyle headerStyle;
@property(assign, nonatomic) RFAutoFetchTableContainerStyle footerStyle;

- (void)setHeaderContainerVisible:(BOOL)isVisible animated:(BOOL)animated;
- (void)setFooterContainerVisible:(BOOL)isVisible animated:(BOOL)animated;

@property(copy, nonatomic) void (^headerVisibleChangeBlock)(BOOL isVisible, CGFloat visibleHeight, BOOL isCompleteVisible, BOOL isProccessing);
- (void)setHeaderVisibleChangeBlock:(void (^)(BOOL isVisible, CGFloat visibleHeight, BOOL isCompleteVisible, BOOL isProccessing))headerVisibleChangeBlock;

@property(copy, nonatomic) void (^footerVisibleChangeBlock)(BOOL isVisible, CGFloat visibleHeight, BOOL isCompleteVisible, BOOL isProccessing, BOOL reachEnd);
- (void)setFooterVisibleChangeBlock:(void (^)(BOOL isVisible, CGFloat visibleHeight, BOOL isCompleteVisible, BOOL isProccessing, BOOL reachEnd))footerVisibleChangeBlock;

#pragma mark - Event
@property(readonly, getter = isFetching, nonatomic) BOOL fetching;

@property(readonly, getter = isHeaderProcessing, nonatomic) BOOL headerProcessing;
@property(readonly, getter = isFooterProcessing, nonatomic) BOOL footerProcessing;

@property(copy, nonatomic) void (^headerProccessBlock)(void);
@property(copy, nonatomic) void (^footerProccessBlock)(void);

// Call them method to notice proccess is finished.
- (void)footerProccessFinshed;
- (void)headerProccessFinshed;

// For manually trigger.
- (void)triggerHeaderProccess;
- (void)triggerFooterProccess;

// If set `YES`, footer proccess will not be proccessed and `footerContainer` will be visiable. Usually for noticing user there are no more data. Header proccess will reset this property.
@property(assign, nonatomic) BOOL footerReachEnd;

// Default `YES`
@property(assign, nonatomic) BOOL shouldScrollToTopWhenHeaderEventTrigged;

// Default `YES`, not work rightnow.
@property(assign, nonatomic) BOOL shouldScrollToLastVisibleRowBeforeTriggeAfterFooterProccessFinished;

// Default `NO`
//@property (assign, nonatomic) BOOL shouldScrollToBottomWhenFooterEventTrigged;

@end
