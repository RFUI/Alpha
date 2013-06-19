/*!
    RFPullToFetchTableView
    RFUI

    Copyright (c) 2013 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php
 
    TEST
 */

#import "RFRuntime.h"
#import "RFInitializing.h"
#import "UIScrollView+RFScrollViewContentDistance.h"

// 未实现
typedef enum {
    RFAutoFetchTableContainerStyleNone = 0,
	RFAutoFetchTableContainerStyleStatic = 1,
	RFAutoFetchTableContainerStyleFloat = 4,
	RFAutoFetchTableContainerStyleFloatFixed = 5,
} RFAutoFetchTableContainerStyle;

@interface RFPullToFetchTableView : UITableView
<RFInitializing>

// Default YES.
@property (assign, nonatomic, getter = isHeaderFetchingEnabled) BOOL headerFetchingEnabled;
@property (assign, nonatomic, getter = isFooterFetchingEnabled) BOOL footerFetchingEnabled;

#pragma mark - Layout

@property (RF_WEAK, nonatomic) UIView *headerContainer;
@property (RF_WEAK, nonatomic) UIView *footerContainer;

@property (assign, nonatomic) RFAutoFetchTableContainerStyle headerStyle;
@property (assign, nonatomic) RFAutoFetchTableContainerStyle footerStyle;

//@property (assign, nonatomic) CGFloat *headerVisibleHight;
//@property (assign, nonatomic) CGFloat *footerVisibleHight;



- (void)setHeaderContainerVisible:(BOOL)isVisible animated:(BOOL)animated;
- (void)setFooterContainerVisible:(BOOL)isVisible animated:(BOOL)animated;



@property (copy, nonatomic) void (^headerVisibleChangeBlock)(BOOL isVisible, CGFloat visibleHeight, BOOL isCompleteVisible);
- (void)setHeaderVisibleChangeBlock:(void (^)(BOOL isVisible, CGFloat visibleHeight, BOOL isCompleteVisible))headerVisibleChangeBlock;

@property (copy, nonatomic) void (^footerVisibleChangeBlock)(BOOL isVisible, CGFloat visibleHeight, BOOL isCompleteVisible);
- (void)setFooterVisibleChangeBlock:(void (^)(BOOL isVisible, CGFloat visibleHeight, BOOL isCompleteVisible))footerVisibleChangeBlock;

#pragma mark - Event
@property (readonly, getter = isFetching, nonatomic) BOOL fetching;

@property (readonly, nonatomic) BOOL headerProcessing;
@property (readonly, nonatomic) BOOL footerProcessing;

@property (copy, nonatomic) void (^headerProccessBlock)(void);
@property (copy, nonatomic) void (^footerProccessBlock)(void);

// Call them method to notice proccess is finished.
- (void)footerProccessFinshed;
- (void)headerProccessFinshed;

- (void)onHeaderEventTriggered;
- (void)onFooterEventTriggered;

@end

@protocol RFAutoFetchTableDelegate <NSObject>

@end

