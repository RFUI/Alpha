
#import "RFLine.h"
#import <RFKit/UIView+RFAnimate.h>

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
    CGFloat pixelScale = (self.window.screen)? self.window.screen.scale : [UIApplication sharedApplication].keyWindow.screen.scale;
    if (self.onePixel) {
        CGFloat pixelAdjust = 1. / pixelScale / 2.;
        if (isDrawingVertically) {
            // Sign notes
            //     ┌──┬──┐
            //  -  │ +  ┊  - │ +
            //     └──┴──┘
            //     0          right
            pixelOffsetX = (self.x < 0 || (self.x > self.rightMargin && self.rightMargin >= 0))? pixelAdjust : -pixelAdjust;
        }
        else {
            pixelOffsetY = (self.y < 0 || (self.y > self.bottomMargin && self.bottomMargin >=0))? pixelAdjust : -pixelAdjust;
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
