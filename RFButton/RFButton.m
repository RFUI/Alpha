
#import "RFButton.h"

@interface RFButton ()
@property (copy, nonatomic, setter = setTappedBlock:) void (^onTappedBlock)(RFButton *);
@property (copy, nonatomic, setter = setTouchDownBlock:) void (^onTouchDownBlock)(RFButton *);
@property (copy, nonatomic, setter = setTouchUpBlock:) void (^onTouchUpBlock)(RFButton *);
@end

@implementation RFButton
@synthesize agentButton;
@synthesize icon;
@synthesize titleLabel;
@synthesize onTappedBlock, onTouchDownBlock, onTouchUpBlock;

- (void)setup {
    if (self.agentButton == nil) {
        self.agentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.agentButton.frame = self.bounds;
        [self addSubview:self.agentButton];
        [self.agentButton bringToFront];
    }
    
    [self.agentButton addTarget:self action:@selector(onTouchDown) forControlEvents:UIControlEventTouchDown];
    [self.agentButton addTarget:self action:@selector(onTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self.agentButton addTarget:self action:@selector(onTouchUp) forControlEvents:UIControlEventTouchUpOutside];
    [self.agentButton addTarget:self action:@selector(onTouchUp) forControlEvents:UIControlEventTouchCancel];
}
- (void)awakeFromNib {
    [self setup];
}

- (void)highlight {
    self.titleLabel.highlighted = YES;
    self.agentButton.highlighted = YES;
    if (self.onTouchDownBlock) {
        self.onTouchDownBlock(self);
    }
}
- (void)unhighlight {
    self.titleLabel.highlighted = NO;
    self.agentButton.highlighted = NO;
    if (self.onTouchUpBlock) {
        self.onTouchUpBlock(self);
    }
}

- (void)onTouchDown {
    [self highlight];
}
- (void)onTouchUp {
    [self unhighlight];
}
- (void)onTouchUpInside {
    if (self.onTappedBlock) {
        self.onTappedBlock(self);
    }
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self unhighlight];
    });
}

@end
