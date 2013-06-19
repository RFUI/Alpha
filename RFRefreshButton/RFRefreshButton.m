
#import "RFRefreshButton.h"

static void *const RFRefreshButtonKVOContext = (void *)&RFRefreshButtonKVOContext;

@interface RFRefreshButton ()
@property (readwrite, nonatomic) BOOL observing;
@property (weak, readwrite, nonatomic) id observeTarget;
@property (copy, readwrite, nonatomic) NSString *observeKeypath;
@property (copy, nonatomic) BOOL (^evaluateBlock)(id evaluatedVaule);

@end

@implementation RFRefreshButton

- (id)init {
    self = [super init];
    if (self) {
        [self onInit];
        [self performSelector:@selector(afterInit) withObject:self afterDelay:0];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self onInit];
        [self performSelector:@selector(afterInit) withObject:self afterDelay:0];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self onInit];
        [self performSelector:@selector(afterInit) withObject:self afterDelay:0];
    }
    return self;
}

- (void)onInit {
}

- (void)afterInit {
    if (!self.iconImageView) {
        UIImage *rimage = [self imageForState:UIControlStateNormal];
        if (rimage) {
            [self setImage:nil forState:UIControlStateNormal];
        }
        
        UIImageView *iv = [[UIImageView alloc] initWithFrame:self.bounds];
        iv.image = rimage;
        iv.contentMode = UIViewContentModeCenter;
        iv.autoresizingMask = UIViewAutoresizingFlexibleSize;
        iv.hidden = !self.enabled;
        [self addSubview:iv];
        self.iconImageView = iv;
    }
    
    if (!self.activityIndicatorView) {        
        UIActivityIndicatorView *ai = (self.activityIndicatorView)? : [[UIActivityIndicatorView alloc] initWithFrame:self.bounds];
        ai.autoresizingMask = UIViewAutoresizingFlexibleSize;
        ai.hidesWhenStopped = YES;
        if (self.enabled) {
            [ai stopAnimating];
        }
        else {
            [ai startAnimating];
        }
        [self addSubview:ai];
        self.activityIndicatorView = ai;
    }
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    
    self.iconImageView.hidden = !enabled;
    if (enabled) {
        [self.activityIndicatorView stopAnimating];
    }
    else {
        [self.activityIndicatorView startAnimating];
    }
}

#pragma mark - Observe

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context != RFRefreshButtonKVOContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    if (object == self.observeTarget && [keyPath isEqualToString:self.observeKeypath]) {
        [self evaluateEnableStatus];
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)evaluateEnableStatus {
    if (self.evaluateBlock) {
        self.enabled = !self.evaluateBlock([self.observeTarget valueForKeyPath:self.observeKeypath]);
    }
    else {
        self.enabled = ![[self.observeTarget valueForKeyPath:self.observeKeypath] boolValue];
    }
}

- (void)observeTarget:(id)target forKeyPath:(NSString *)keypath evaluateBlock:(BOOL (^)(id evaluatedVaule))ifProccessingBlock {
    NSParameterAssert(target && keypath.length);
    self.observeTarget = target;
    self.observeKeypath = keypath;
    self.evaluateBlock = ifProccessingBlock;

    [self evaluateEnableStatus];
    [self.observeTarget addObserver:self forKeyPath:self.observeKeypath options:NSKeyValueObservingOptionNew context:RFRefreshButtonKVOContext];
    self.observing = YES;
}

- (void)stopObserve {
    if (self.observing) {
        [self.observeTarget removeObserver:self forKeyPath:self.observeKeypath context:RFRefreshButtonKVOContext];
        self.observing = NO;
    }
}

- (void)dealloc {
    [self stopObserve];
}

@end
