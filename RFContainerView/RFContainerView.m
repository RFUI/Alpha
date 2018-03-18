
#import "RFContainerView.h"

@interface RFContainerView ()
@property (nullable) __kindof UIViewController *embedViewController;
@property BOOL embedViewControllerLoaded;
@end

@implementation RFContainerView
RFInitializingRootForUIView

- (void)onInit {
}

- (void)afterInit {
}

- (void)awakeFromNib {
    [super awakeFromNib];
    if (!self.lazyLoad
        && !self.embedViewControllerLoaded) {
        [self loadEmbedViewController];
    }
}

#if defined(TARGET_INTERFACE_BUILDER) && TARGET_INTERFACE_BUILDER
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
    [super didMoveToSuperview];
    if (self.lazyLoad
        || self.embedViewControllerLoaded
        || !self.superview) return;

    @weakify(self);
    dispatch_after_seconds(0, ^{
        @strongify(self);
        if (!self
            || self.lazyLoad) return;
        [self loadEmbedViewController];
    });
}

- (void)setParentViewController:(UIViewController *)parentViewController {
    _parentViewController = parentViewController;
    if (parentViewController) {
        [self loadEmbedViewController];
    }
}

- (void)loadEmbedViewControllerWithPrepareBlock:(void (^ __nullable)(__kindof UIViewController *__nonnull viewController, RFContainerView * __nonnull container))prepareBlock {
    if (self.embedViewControllerLoaded) return;

    UIViewController *parentViewController = self.parentViewController?: self.viewController;
    RFAssert(parentViewController, @"Cannot load embed view controller, no parent view controller");
    NSString *storyboardName = self.storyboardName;
    NSString *vcIdentifier = self.instantiationIdentifier;
    RFAssert(storyboardName || vcIdentifier, @"Either storyboardName or instantiationIdentifier set");

    UIViewController *vc = self.embedViewController;
    if (!vc) {
        UIStoryboard *sb = storyboardName? [UIStoryboard storyboardWithName:storyboardName bundle:nil] : parentViewController.storyboard;
        vc = vcIdentifier? [sb instantiateViewControllerWithIdentifier:vcIdentifier] : [sb instantiateInitialViewController];
        self.embedViewController = vc;
    }

    if (vc) {
        if (prepareBlock) {
            prepareBlock(vc, self);
        }
        [parentViewController addChildViewController:vc];
        vc.view.autoresizingMask = UIViewAutoresizingFlexibleSize;
        [self addSubview:vc.view resizeOption:RFViewResizeOptionFill];
        [vc didMoveToParentViewController:parentViewController];
        self.embedViewControllerLoaded = YES;
    }
}

- (void)loadEmbedViewController {
    [self loadEmbedViewControllerWithPrepareBlock:nil];
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
