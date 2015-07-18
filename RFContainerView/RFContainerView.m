
#import "RFContainerView.h"

@interface RFContainerView ()
@property (strong, nullable, nonatomic) id embedViewController;
@property (readwrite, nonatomic) BOOL embedViewControllerLoaded;
@end

@implementation RFContainerView
RFInitializingRootForUIView

- (void)onInit {
}

- (void)afterInit {
}

- (void)awakeFromNib {
    [super awakeFromNib];
    if (!self.lazyLoad && !self.embedViewControllerLoaded) {
        [self loadEmbedViewController];
    }
}

#if TARGET_INTERFACE_BUILDER
- (void)drawRect:(CGRect)rect {
    CGRect frame = self.bounds;

    NSString* textContent = [NSString stringWithFormat:@"%@\n%@", self.storyboardName?: @"This", self.instantiationIdentifier?: @"InitialViewController"];

    NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [textStyle setAlignment: NSTextAlignmentCenter];

    NSDictionary* textFontAttributes = @{
                                         NSFontAttributeName: [UIFont systemFontOfSize: 16],
                                         NSForegroundColorAttributeName: [UIColor blackColor],
                                         NSParagraphStyleAttributeName: textStyle
                                         };
    CGRect textRect = [textContent boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame) - 20, CGRectGetHeight(frame) - 20) options:NSStringDrawingTruncatesLastVisibleLine attributes:textFontAttributes context:nil];
    textRect = CGRectMakeWithCenterAndSize(CGPointOfRectCenter(frame), textRect.size);
    [textContent drawInRect:textRect withAttributes:textFontAttributes];

    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame))];
    [bezierPath addLineToPoint:CGPointMake(CGRectGetMaxX(frame), CGRectGetMaxY(frame))];

    [bezierPath moveToPoint: CGPointMake(CGRectGetMaxX(frame), CGRectGetMinY(frame))];
    [bezierPath addLineToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMaxY(frame))];

    [self.tintColor setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
}
#endif

- (void)didMoveToSuperview {
    dispatch_after_seconds(0, ^{
        if (!self.lazyLoad && !self.embedViewControllerLoaded) {
            [self loadEmbedViewController];
        }
    });
}

- (void)setParentViewController:(UIViewController *)parentViewController {
    _parentViewController = parentViewController;
    if (parentViewController) {
        [self loadEmbedViewController];
    }
}

- (void)loadEmbedViewController {
    if (self.embedViewControllerLoaded) return;

    UIViewController *parentViewController = self.parentViewController?: self.viewController;
    RFAssert(parentViewController, @"Cannot load embed view controller, no parent view controller");
    RFAssert(self.storyboardName || self.instantiationIdentifier, @"Either storyboardName or instantiationIdentifier set");

    UIViewController *vc = self.embedViewController;
    if (!vc) {
        UIStoryboard *sb = self.storyboardName?  [UIStoryboard storyboardWithName:self.storyboardName bundle:nil] : parentViewController.storyboard;
        vc = self.instantiationIdentifier? [sb instantiateViewControllerWithIdentifier:self.instantiationIdentifier] : [sb instantiateInitialViewController];
        self.embedViewController = vc;
    }

    if (vc) {
        self.embedViewControllerLoaded = YES;
        [parentViewController addChildViewController:vc];
        vc.view.autoresizingMask = UIViewAutoresizingFlexibleSize;
        [self addSubview:vc.view resizeOption:RFViewResizeOptionFill];
        [vc didMoveToParentViewController:parentViewController];
    }
}

- (void)unloadEmbedViewController:(BOOL)shouldReleaseEmbedViewController {
    if (!self.embedViewControllerLoaded) return;

    [self.embedViewController removeFromParentViewControllerAndView];
    if (shouldReleaseEmbedViewController) {
        self.embedViewController = nil;
    }
    self.embedViewControllerLoaded = NO;
}

@end
