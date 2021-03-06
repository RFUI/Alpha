
#import "RFCarouselView.h"
#import "RFTimer.h"
#import <RFKit/UIView+RFKit.h>
#import <RFKit/UIView+RFAnimate.h>

@interface RFCarouselView ()
@property (nonatomic) RFTimer *RFCarouselView_animationTimer;
@end

@implementation RFCarouselView
RFInitializingRootForUIView

- (void)onInit {
    self.clipsToBounds = YES;
}

- (void)afterInit {
    // Nothing
}

- (NSTimeInterval)duration {
    if (_duration == 0) {
        _duration = 3;
    }
    return _duration;
}

- (void)setAnimating:(BOOL)animating {
    if (_animating == animating) return;
    _animating = animating;
    if (animating) {
        self.RFCarouselView_animationTimer.suspended = NO;
    }
    else {
        self.RFCarouselView_animationTimer.suspended = YES;
        [self.layer removeAllAnimations];
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    if (newWindow) {
        if (self.animating) {
            self.RFCarouselView_animationTimer.suspended = NO;
        }
    }
    else {
        _RFCarouselView_animationTimer.suspended = YES;
    }
}

- (RFTimer *)RFCarouselView_animationTimer {
    if (!_RFCarouselView_animationTimer) {
        @weakify(self);
        _RFCarouselView_animationTimer = [RFTimer scheduledTimerWithTimeInterval:self.duration repeats:YES fireBlock:^(RFTimer *timer, NSUInteger repeatCount) {
            @strongify(self);
            [self _doAnimation];
        }];
    }
    return _RFCarouselView_animationTimer;
}

- (void)setIndex:(NSInteger)index {
    _index = index % self.count;
    UIView *content = self.contentView;
    if (self.setupContentViewAtIndex && content) {
        self.setupContentViewAtIndex(self.index, content);
    }
}

- (void)_doAnimation {
    if (!self.count
        || !self.contentView) return;
    
    UIView *new = self.contentView;
    UIView *old = [new snapshotViewAfterScreenUpdates:NO];
    old.frame = new.frame;
    [self insertSubview:old belowSubview:new];
    self.index++;
    
    CGFloat offset = self.height;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animated:YES beforeAnimations:^{
        new.transform = CGAffineTransformMakeTranslation(0, offset);
        new.alpha = 0;
    } animations:^{
        old.transform = CGAffineTransformMakeTranslation(0, -offset);
        old.alpha = 0;
        new.transform = CGAffineTransformIdentity;
        new.alpha = 1;
    } completion:^(BOOL finished) {
        [old removeFromSuperview];
    }];
}

@end
