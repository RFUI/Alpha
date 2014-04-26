
#import "RFLine.h"

@implementation RFLine

- (void)drawRect:(CGRect)rect {
    CGRect frame = self.bounds;
    CGFloat width = CGRectGetWidth(frame);
    CGFloat height = CGRectGetHeight(frame);

    BOOL isDrawingVertically = (height > width);
    CGPoint startPoint = (isDrawingVertically)? CGPointMake(CGRectGetMidX(frame), CGRectGetMinY(frame)) : CGPointMake(CGRectGetMinX(frame), CGRectGetMidY(frame));
    CGPoint endPoint = (isDrawingVertically)? CGPointMake(CGRectGetMidX(frame), CGRectGetMaxY(frame)) : CGPointMake(CGRectGetMaxX(frame), CGRectGetMidY(frame));

    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:startPoint];
    [bezierPath addLineToPoint:endPoint];
    if (self.dashLinePatternValue1 || self.dashLinePatternValue2) {
        CGFloat dashPattern[] = {self.dashLinePatternValue1, self.dashLinePatternValue2};
        [bezierPath setLineDash:dashPattern count:2 phase:0];
    }
    bezierPath.lineWidth = (isDrawingVertically)? width : height;
    [self.color setStroke];
    [bezierPath stroke];
}

@end
