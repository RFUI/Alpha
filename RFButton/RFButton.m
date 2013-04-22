
#import "RFButton.h"

@interface RFButton ()
@property (weak, nonatomic, readwrite) UIButton *agentButton;
@property (copy, nonatomic, setter = setHighlightEffectBlock:) void (^highlightEffectBlock)(RFButton *);
@property (copy, nonatomic, setter = setUnhighlightEffectBlock:) void (^unhighlightEffectBlock)(RFButton *);
@end

@implementation RFButton

- (id)init {
    self = [super init];
    if (self) {
        [self onInit];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self onInit];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self onInit];
    }
    return self;
}

- (void)onInit {
    if (!self.agentButton) {
        UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
        aButton.autoresizingMask = UIViewAutoresizingFlexibleSize;
        [self addSubview:aButton resizeOption:RFViewResizeOptionFill];
        self.agentButton = aButton;
    }
    
    [self.agentButton addTarget:self action:@selector(onTouchDown) forControlEvents:UIControlEventTouchDown];
    [self.agentButton addTarget:self action:@selector(onTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self.agentButton addTarget:self action:@selector(onTouchUp) forControlEvents:UIControlEventTouchUpOutside];
    [self.agentButton addTarget:self action:@selector(onTouchUp) forControlEvents:UIControlEventTouchCancel];
}

#pragma mark -
- (void)highlight {
    self.titleLabel.highlighted = YES;
    self.agentButton.highlighted = YES;
    if (self.highlightEffectBlock) {
        self.highlightEffectBlock(self);
    }
}
- (void)unhighlight {
    self.titleLabel.highlighted = NO;
    self.agentButton.highlighted = NO;
    if (self.unhighlightEffectBlock) {
        self.unhighlightEffectBlock(self);
    }
}

- (void)onTouchDown {
    [self highlight];
}
- (void)onTouchUp {
    [self unhighlight];
}
- (void)onTouchUpInside {
    if (self.tappedBlock) {
        self.tappedBlock(self);
    }
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self unhighlight];
    });
}

@end
