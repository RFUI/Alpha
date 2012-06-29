/*!
    RFButton
    RFUI
 
    ver -.-.-
 */

#import <UIKit/UIKit.h>

@interface RFButton : UIView
@property (RF_STRONG, nonatomic) __block IBOutlet UIButton *agentButton;
@property (RF_STRONG, nonatomic) IBOutlet UIImageView *icon;
@property (RF_STRONG, nonatomic) IBOutlet UILabel *titleLabel;

- (void)setTappedBlock:(void (^)(RFButton *sender))onTappedBlock;
- (void)setTouchDownBlock:(void (^)(RFButton *sender))onTouchDownBlock;
- (void)setTouchUpBlock:(void (^)(RFButton *sender))onTouchUpBlock;

- (void)onTouchUpInside;
@end
