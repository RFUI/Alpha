
#import "RFRoundingCornersView.h"

@implementation RFRoundingCornersView

- (void)drawRect:(CGRect)rect {

    UIEdgeInsets cr = self.cornerRadius;
    CGFloat r_lt = cr.top;
    CGFloat r_lb = cr.left;
    CGFloat r_rb = cr.bottom;
    CGFloat r_rt = cr.right;

    CGRect bounds = self.bounds;
    CGFloat x_l = CGRectGetMinX(bounds);
    CGFloat x_r = CGRectGetMaxX(bounds);

    CGFloat y_t = CGRectGetMinY(bounds);
    CGFloat y_b = CGRectGetMaxY(bounds);

    CGPoint c_lt = (CGPoint){x_l + r_lt, y_t + r_lt};
    CGPoint c_lb = (CGPoint){x_l + r_lb, y_b - r_lb};
    CGPoint c_rb = (CGPoint){x_r - r_rb, y_b - r_rb};
    CGPoint c_rt = (CGPoint){x_r - r_rt, y_t + r_rt};

    UIBezierPath *path = [UIBezierPath new];
    [path addArcWithCenter:c_lt radius:r_lt startAngle:M_PI_2 *3 endAngle:M_PI clockwise:NO];
    [path addArcWithCenter:c_lb radius:r_lb startAngle:M_PI endAngle:M_PI_2 clockwise:NO];
    [path addArcWithCenter:c_rb radius:r_rb startAngle:M_PI_2 endAngle:0 clockwise:NO];
    [path addArcWithCenter:c_rt radius:r_rt startAngle:0 endAngle:M_PI_2 *3 clockwise:NO];

    [path closePath];
    [self.color setFill];
    [path fill];
}

@end
