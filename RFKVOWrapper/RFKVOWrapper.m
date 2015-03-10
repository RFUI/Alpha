
#import "RFKVOWrapper.h"
#import "RFSwizzle.h"
@import ObjectiveC.runtime;

typedef void (^RFKVOBlock)(id, NSDictionary *);

static void *RFKVOTrampolinesKey = &RFKVOTrampolinesKey;
static void *RFKVOWrapperContext = &RFKVOWrapperContext;

static NSMutableSet *RFSwizzledClasses() {
    static dispatch_once_t onceToken;
    static NSMutableSet *swizzledClasses = nil;
    dispatch_once(&onceToken, ^{
        swizzledClasses = [NSMutableSet new];
    });

    return swizzledClasses;
}

@interface NSObject ()
// This set should only be manipulated while synchronized on the receiver.
@property (nonatomic, strong) NSMutableSet *RFKVOTrampolines;
@end

@interface RFKVOTrampoline : NSObject

- (id)initWithTarget:(NSObject *)target observer:(NSObject *)observer keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options queue:(NSOperationQueue *)queue block:(RFKVOBlock)block;

@property (nonatomic, readonly, copy) NSString *keyPath;
@property (nonatomic, readonly, strong) NSOperationQueue *queue;

// These properties should only be manipulated while synchronized on the receiver.
@property (nonatomic, copy) RFKVOBlock block;
@property (nonatomic, unsafe_unretained) NSObject *target;
@property (nonatomic, unsafe_unretained) NSObject *observer;

- (void)addAsTrampolineOnObject:(NSObject *)obj;

@end

@implementation RFKVOTrampoline

#pragma mark Lifecycle

- (id)initWithTarget:(NSObject *)target observer:(NSObject *)observer keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options queue:(NSOperationQueue *)queue block:(RFKVOBlock)block {
    self = [super init];
    if (!self) return nil;

    _keyPath = [keyPath copy];
    _queue = queue;

    self.block = block;
    self.target = target;
    self.observer = observer;

    [self.target addObserver:self forKeyPath:self.keyPath options:options context:&RFKVOWrapperContext];
    [self addAsTrampolineOnObject:self.target];
    [self addAsTrampolineOnObject:self.observer];

    return self;
}

- (void)addAsTrampolineOnObject:(NSObject *)obj {
    @synchronized (obj) {
        if (!obj.RFKVOTrampolines) {
            obj.RFKVOTrampolines = [NSMutableSet setWithObject:self];
        }
        else {
            [obj.RFKVOTrampolines addObject:self];
        }
    }
}

- (void)dealloc {
    [self stopObserving];
}

#pragma mark Observation

- (void)stopObserving {
    NSObject *target;
    NSObject *observer;

    @synchronized (self) {
        self.block = nil;

        target = self.target;
        observer = self.observer;

        self.target = nil;
        self.observer = nil;
    }

    @synchronized (target) {
        [target.RFKVOTrampolines removeObject:self];
    }

    @synchronized (observer) {
        [observer.RFKVOTrampolines removeObject:self];
    }

    [target removeObserver:self forKeyPath:self.keyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context != &RFKVOWrapperContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }

    RFKVOBlock block;
    id observer;
    // We need to keep the target alive until the notification's been delivered,
    // which could be some point later in time if we're not in `queue` currently.
    __block id target;

    @synchronized (self) {
        block = self.block;
        observer = self.observer;
        target = self.target;
    }

    void (^notificationBlock)(void) = ^{
        if (!block) return;
        block(observer, change);
    };

    if (!self.queue || self.queue == [NSOperationQueue currentQueue]) {
        notificationBlock();
    }
    else {
        [self.queue addOperationWithBlock:^{
            notificationBlock();
            target = nil;
        }];
    }
}

@end

@implementation NSObject (RFKVOWrapper)

- (void)_RFKVOWrapperSwizzed_dealloc {
    NSSet *trampolines;

    @synchronized (self) {
        trampolines = [self.RFKVOTrampolines copy];
        self.RFKVOTrampolines = nil;
    }

    // If we're currently delivering a KVO callback then niling the trampoline set might not dealloc the trampoline and therefore make them be dealloc'd. So we need to manually stop observing on all of them as well.
    [trampolines makeObjectsPerformSelector:@selector(stopObserving)];

    [self _RFKVOWrapperSwizzed_dealloc];
}

- (id)RFAddObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options queue:(NSOperationQueue *)queue block:(void (^)(id observer, NSDictionary *change))block {
    void (^swizzle)(Class) = ^(Class classToSwizzle){
        NSString *className = NSStringFromClass(classToSwizzle);
        if ([RFSwizzledClasses() containsObject:className]) return;

        RFSwizzleInstanceMethod(classToSwizzle, NSSelectorFromString(@"dealloc"), @selector(_RFKVOWrapperSwizzed_dealloc));
        [RFSwizzledClasses() addObject:className];
    };

    // We swizzle the dealloc for both the object being observed and the observer of the observation. Because when either gets dealloc'd, we need to tear down the observation.
    @synchronized (RFSwizzledClasses()) {
        swizzle(self.class);
        swizzle(observer.class);
    }

    return [[RFKVOTrampoline alloc] initWithTarget:self observer:observer keyPath:keyPath options:options queue:queue block:block];
}

- (BOOL)RFRemoveObserverWithIdentifier:(RFKVOTrampoline *)trampoline {
    if (trampoline.target != self) return NO;
    
    [trampoline stopObserving];
    return YES;
}

- (NSMutableSet *)RFKVOTrampolines {
    return objc_getAssociatedObject(self, RFKVOTrampolinesKey);
}

- (void)setRFKVOTrampolines:(NSMutableSet *)set {
    objc_setAssociatedObject(self, RFKVOTrampolinesKey, set, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end