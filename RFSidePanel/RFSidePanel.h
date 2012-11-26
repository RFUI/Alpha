/*!
    RFSidePanel
    RFUI
    ver 0.5.0
 
    Copyright (c) 2012 BB9z
    http://github.com/bb9z/RFUIAlpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php
 */

#import "RFKit.h"

@class RFSidePanel;

@protocol RFSidePanelDelegate <NSObject>

- (void)sidePanelWillShow:(RFSidePanel *)sidePanel;
- (void)sidePanelDidShow:(RFSidePanel *)sidePanel;
- (void)sidePanelWillHidden:(RFSidePanel *)sidePanel;
- (void)sidePanelDidHidden:(RFSidePanel *)sidePanel;
@end


@interface RFSidePanel : UIViewController
<UIGestureRecognizerDelegate>

/// 只需设置这个属性就可以把 rootViewController 的 view 加到侧边栏内了
@property (RF_STRONG, nonatomic) UIViewController *rootViewController;

@property (RF_WEAK, nonatomic) id<RFSidePanelDelegate> delegate;

@property (readonly, nonatomic) BOOL isShow;
- (void)show:(BOOL)animated;
- (void)hide:(BOOL)animated;
- (BOOL)toggle:(BOOL)animated;

- (IBAction)onPanelDragging:(UIPanGestureRecognizer *)sender;
- (IBAction)onHide:(UIButton *)sender;
- (IBAction)onShow:(UIButton *)sender;

@property (RF_WEAK, nonatomic) IBOutlet UIView *containerView;
@property (RF_WEAK, nonatomic) IBOutlet UIImageView *containerBackground;

@property (RF_WEAK, nonatomic) IBOutlet UIImageView *separatorBackground;
@property (RF_WEAK, nonatomic) IBOutlet UIButton *separatorButtonOFF;
@property (RF_WEAK, nonatomic) IBOutlet UIButton *separatorButtonON;
@end
