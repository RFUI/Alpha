/*!
    RFSidePanel
    RFUI
    ver 0.4.0
 
    Copyright (c) 2012 BB9z
    http://github.com/bb9z/RFUIAlpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php
 */

#import "RFKit.h"

@interface RFSidePanel : UIViewController
<UIGestureRecognizerDelegate>

/// 只需设置这个属性就可以把 rootViewController 的 view 加到侧边栏内了
@property (RF_STRONG, nonatomic) UIViewController *rootViewController;

@property (readonly, nonatomic) BOOL isShow;
- (void)show:(BOOL)animated;
- (void)hide:(BOOL)animated;
- (BOOL)toggle:(BOOL)animated;

- (IBAction)onSwipeLeft:(UISwipeGestureRecognizer *)sender;
- (IBAction)onSwipRight:(UISwipeGestureRecognizer *)sender;
- (IBAction)onPanelDragging:(UIPanGestureRecognizer *)sender;

@property (RF_WEAK, nonatomic) IBOutlet UIView * containerView;

@end
