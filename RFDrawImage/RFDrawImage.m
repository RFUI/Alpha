
#import "RFDrawImage.h"

@implementation RFDrawImage

+ (UIImage *)imageWithSizeColor:(CGSize)imageSize fillColor:(UIColor *)color {
    NSParameterAssert(imageSize.width > 0 && imageSize.height > 0);

    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    [color set];
    CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageWithRoundingCorners:(UIEdgeInsets)cornerRadius size:(CGSize)imageSize fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor strokeWidth:(CGFloat)strokeWidth boxMargin:(UIEdgeInsets)margin resizableCapInsets:(UIEdgeInsets)resizableCapInsets scaleFactor:(CGFloat)scaleFactor {
    NSParameterAssert(imageSize.width > 0 && imageSize.height > 0);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, scaleFactor);

    CGFloat r_lt = cornerRadius.top;
    CGFloat r_lb = cornerRadius.left;
    CGFloat r_rb = cornerRadius.bottom;
    CGFloat r_rt = cornerRadius.right;

    CGRect bounds = CGRectMake(0 + margin.left, 0 + margin.top, imageSize.width - margin.right - margin.left, imageSize.height - margin.bottom - margin.top);
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
    [path addClip];                     // Stop stroke draw outside
    [fillColor setFill];
    [path fill];

    if (strokeWidth > 0) {
        [strokeColor setStroke];
        path.lineWidth = strokeWidth * 2; // Double due to the chip
        [path stroke];
    }

	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    return [image resizableImageWithCapInsets:resizableCapInsets];
}



@end
