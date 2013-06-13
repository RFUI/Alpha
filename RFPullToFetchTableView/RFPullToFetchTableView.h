/*!
    RFPullToFetchTableView
    RFUI

    Copyright (c) 2013 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php
 
    Theory Test
 */

#import "RFRuntime.h"

// 未实现
typedef enum {
    RFAutoFetchTableContainerStyleNone = 0,
	RFAutoFetchTableContainerStyleStatic = 1,
	RFAutoFetchTableContainerStyleFloat = 4,
	RFAutoFetchTableContainerStyleFloatSolid = 5,
} RFAutoFetchTableContainerStyle;

@interface RFPullToFetchTableView : UITableView

@property (assign, nonatomic, getter = isHeaderFetchingEnabled) BOOL headerFetchingEnabled;
@property (assign, nonatomic, getter = isFooterFetchingEnabled) BOOL footerFetchingEnabled;

@property (RF_WEAK, nonatomic) UIView *headerContainer;
@property (RF_WEAK, nonatomic) UIView *footerContainer;

@property (assign, nonatomic) BOOL headerProcessing;
@property (assign, nonatomic) BOOL footerProcessing;

@property (assign, nonatomic) CGFloat *headerVisibleHight;
@property (assign, nonatomic) CGFloat *footerVisibleHight;

@property (assign, nonatomic) RFAutoFetchTableContainerStyle headerStyle;
@property (assign, nonatomic) RFAutoFetchTableContainerStyle footerStyle;

@property (copy, nonatomic) void (^headerProccessBlock)(void);
@property (copy, nonatomic) void (^footerProccessBlock)(void);

- (void)onFooterProccessFinshed;
- (void)onHeaderProccessFinshed;

- (void)setFooterContainerVisible:(BOOL)isVisible animated:(BOOL)animated;

@end

@protocol RFAutoFetchTableDelegate <NSObject>



@end
