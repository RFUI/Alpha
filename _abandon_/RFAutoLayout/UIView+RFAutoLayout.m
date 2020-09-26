
#import "UIView+RFAutoLayout.h"

@implementation UIView (RFAutoLayout)

- (void)addSubview:(UIView *)view likeBarWithBarPosition:(RFBarPosition)barPosition barHeight:(CGFloat)height {
    view.translatesAutoresizingMaskIntoConstraints = NO;

    BOOL hasHeightConstraint = NO;
    for (NSLayoutConstraint *lc in view.constraints) {
        if (lc.firstItem == self && lc.firstAttribute == NSLayoutAttributeHeight && lc.secondItem == nil && lc.relation == NSLayoutRelationEqual) {
            lc.constant = height;
            hasHeightConstraint = YES;
        }
    }

    if (!hasHeightConstraint) {
        [view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:height]];
    }

    [self addSubview:view];

    NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    NSLayoutConstraint *c3 = [NSLayoutConstraint constraintWithItem:view attribute:(barPosition == RFBarPositionBottom)? NSLayoutAttributeBottom : NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:(barPosition == RFBarPositionBottom)? NSLayoutAttributeBottom : NSLayoutAttributeTop multiplier:1 constant:0];
    [self addConstraints:@[ c1, c2, c3 ]];
}

@end
