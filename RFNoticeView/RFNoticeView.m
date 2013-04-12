
#import "RFNoticeView.h"

NSTimeInterval const RFNoticeViewMinimumDisplayTimeInterval = 0.1f;
NSTimeInterval const RFNoticeViewDefaultDisplayTimeInterval = 1.f;


@interface RFNoticeViewItem : NSObject
@property (copy, nonatomic) NSString *message;
@property (assign, nonatomic) NSTimeInterval displayTimeInterval;
@end

@interface RFNoticeView ()
@property (RF_STRONG, atomic) NSMutableArray *items;
@property (assign, atomic, getter = isDisplaying) BOOL displaying;
@property (RF_WEAK, nonatomic) RFNoticeViewItem *currentItem;
@property (RF_STRONG, nonatomic) NSDate *currentItemDisplayTime;
@end

@implementation RFNoticeView
#define RFDebugLevel 5

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
    self.items = [NSMutableArray arrayWithCapacity:20];
    [self addObserver:self forKeyPath:@keypath(self, items) options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)noticeWithMessage:(NSString *)message displayTimeInterval:(NSTimeInterval)timeInterval {
    RFNoticeViewItem *item = [[RFNoticeViewItem alloc] init];
    item.message = message;
    item.displayTimeInterval = timeInterval;
    [[self mutableArrayValueForKey:@keypath(self, items)] addObject:item];
}

- (NSTimeInterval)tureDisplayTimeInterval:(NSTimeInterval)referenceTimeInterval {
    if (referenceTimeInterval < RFNoticeViewMinimumDisplayTimeInterval) {
        referenceTimeInterval = RFNoticeViewDefaultDisplayTimeInterval;
    }
    NSTimeInterval tureTimeInterval = 1/log(self.items.count+1)*referenceTimeInterval;
    _dout(@"1/log10(%d) = %f", self.items.count, 1/log10(self.items.count))
    if (tureTimeInterval < RFNoticeViewMinimumDisplayTimeInterval) {
        tureTimeInterval = RFNoticeViewMinimumDisplayTimeInterval;
    }
    _dout_float(tureTimeInterval)
    return tureTimeInterval;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self && [keyPath isEqualToString:@keypath(self, items)]) {
        switch ([change[NSKeyValueChangeKindKey] integerValue]) {
            case NSKeyValueChangeInsertion:
                [self onMessageAdded];
                break;
                
            case NSKeyValueChangeRemoval:
                [self onMessageRemoved];
                break;
                
            default:
                break;
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)onMessageAdded {
    if (self.isDisplaying) {
        // Change current item display time.
        NSTimeInterval ctCalc = [self tureDisplayTimeInterval:self.currentItem.displayTimeInterval];
        NSTimeInterval delay = ctCalc+[self.currentItemDisplayTime timeIntervalSinceNow];
        [self removeCurrentItemAfterTimeInterval:delay];
        _dout(@"Time update to: %f", delay)
    }
    else {
        // Start display
        self.hidden = NO;
        [self displayItem];
        self.displaying = YES;
    }
}

- (void)onMessageRemoved {
    if (self.items.count) {
        [self displayItem];
    }
    else {
        // End display
        self.textLabel.text = nil;
        self.hidden = YES;
        self.displaying = NO;
    }
}

- (void)displayItem {
    RFNoticeViewItem *item = [self.items firstObject];
    self.currentItem = item;
    self.textLabel.text = item.message;
    self.currentItemDisplayTime = [NSDate date];
    
    [self removeCurrentItemAfterTimeInterval:[self tureDisplayTimeInterval:item.displayTimeInterval]];
}

- (void)removeCurrentItemAfterTimeInterval:(NSTimeInterval)time {
    __strong RFNoticeViewItem *item = self.currentItem;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (![self.items containsObject:item]) return;
        
        [[self mutableArrayValueForKey:@keypath(self, items)] removeObject:self.currentItem];
    });
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@keypath(self, items)];
}

@end

@implementation RFNoticeViewItem
@end
