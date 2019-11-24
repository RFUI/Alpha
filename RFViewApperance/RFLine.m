
#import "RFLine.h"

@implementation RFLine

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGRect frame = self.bounds;
    CGFloat width = CGRectGetWidth(frame);
    CGFloat height = CGRectGetHeight(frame);

    BOOL isDrawingVertically = (height > width);
    CGFloat pixelOffsetX = 0;
    CGFloat pixelOffsetY = 0;
    UIWindow *window = self.window ?: UIApplication.sharedApplication.keyWindow;
    CGFloat pixelScale = window.screen.scale;
    if (self.onePixel) {
        CGFloat pixelAdjust = 1. / pixelScale / 2.;
        if (isDrawingVertically) {
            // Sign notes
            //     ┌──┬──┐
            //  -  │ +  ┊  - │ +
            //     └──┴──┘
            //     0          right
            CGFloat x = frame.origin.x;
            CGFloat rightMargin = CGRectGetWidth(self.superview.bounds) - CGRectGetWidth(frame) - x;
            pixelOffsetX = (x < 0 || (x > rightMargin && rightMargin >= 0))? pixelAdjust : -pixelAdjust;
        }
        else {
            CGFloat y = frame.origin.y;
            CGFloat bottomMargin = CGRectGetHeight(self.superview.bounds) - CGRectGetHeight(frame) - y;
            pixelOffsetY = (y < 0 || (y > bottomMargin && bottomMargin >= 0))? pixelAdjust : -pixelAdjust;
        }
    }

    CGPoint startPoint = (isDrawingVertically)? CGPointMake(CGRectGetMidX(frame) + pixelOffsetX, CGRectGetMinY(frame)) : CGPointMake(CGRectGetMinX(frame), CGRectGetMidY(frame) + pixelOffsetY);
    CGPoint endPoint = (isDrawingVertically)? CGPointMake(CGRectGetMidX(frame) + pixelOffsetX, CGRectGetMaxY(frame)) : CGPointMake(CGRectGetMaxX(frame), CGRectGetMidY(frame) + pixelOffsetY);

    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:startPoint];
    [bezierPath addLineToPoint:endPoint];
    if (self.dashLinePatternValue1 || self.dashLinePatternValue2) {
        CGFloat dashPattern[] = {self.dashLinePatternValue1, self.dashLinePatternValue2};
        [bezierPath setLineDash:dashPattern count:2 phase:0];
    }
    bezierPath.lineCapStyle = self.lineCapStyle;

    CGFloat lineWidth = 1;
    if (self.onePixel) {
        lineWidth = 1 / pixelScale;
    }
    else {
        lineWidth = (isDrawingVertically)? width : height;
    }
    bezierPath.lineWidth = lineWidth;
    [self.color setStroke];
    [bezierPath stroke];
}

@end
