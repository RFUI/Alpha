
#import "RFLine.h"
#import "UIView+RFAnimate.h"

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
    if (self.onePixel) {
        CGFloat pixelOffset = 1 / self.window.screen.scale / 2;
        if (isDrawingVertically) {
            pixelOffsetX = (ABS(self.x) > ABS(self.rightMargin))? pixelOffset : - pixelOffset;
        }
        else {
            pixelOffsetY = (ABS(self.y) > ABS(self.bottomMargin))? pixelOffset : -pixelOffset;
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

    CGFloat lineWidth = 1;
    if (self.onePixel) {
        lineWidth = 1 / self.window.screen.scale;
    }
    else {
        lineWidth = (isDrawingVertically)? width : height;
    }
    bezierPath.lineWidth = lineWidth;
    [self.color setStroke];
    [bezierPath stroke];
}

@end
