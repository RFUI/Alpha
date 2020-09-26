

#import <UIKit/UIKit.h>

typedef NS_ENUM(short, RFBarPosition) {
    RFBarPositionTop = 0,
    RFBarPositionBottom
};

@interface UIView (RFAutoLayout)
- (void)addSubview:(UIView *)view likeBarWithBarPosition:(RFBarPosition)barPosition barHeight:(CGFloat)height;

@end
