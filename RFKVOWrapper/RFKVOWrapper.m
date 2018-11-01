
#import "RFKVOWrapper.h"
#import <RFKit/RFRuntime.h>
#import <objc/runtime.h>

/**
 We will keep this class secret some thime.

 Conveniently and safely use KVO, modelling KVO each observation as an object.
 */
@interface RFKVOController : NSObject

/// The object that is the target of the observation
@property (weak) id observedObject;

/// The block that will be called whenver an observation fires
@property (copy) void (^callbackBlock)(RFKVOController *observation, NSDictionary *changeDictionary);

/// The keypath of the observedObject that is being observed
@property (copy) NSString *keyPath;

/// KVO options for the observation
@property NSKeyValueObservingOptions options;

/// False if the observation has been invalidated (either manually or because the target object was deallocated)
@property (nonatomic, readonly) BOOL isValid;

/**
 Returns a started observation
 */
+ (RFKVOController *)observe:(id)observedObject keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options queue:(NSOperationQueue *)queue callback:(void (^)(RFKVOController *observation, NSDictionary *changeDictionary))callbackBlock;

/**
 Returns an observation that will automatically update the `boundObjectKeyPath` on the `boundObject` whenever the `observedKeyPath` changes on the `observedObject`
 */
+ (RFKVOController *)bind:(id)observedObject keyPath:(NSString *)observedKeyPath toObject:(id)boundObject keyPath:(NSString *)boundObjectKeyPath;

/**
 Returns a pair of observations that will automatically keep the keypaths on the respective objects in sync. Care is taken not to enter an infinite loop :)
 */
+ (NSArray<RFKVOController *> *)bidirectionallyBind:(id)objectA keyPath:(NSString *)objectAKeyPath withObject:(id)objectB keyPath:(NSString *)objectBKeyPath;

/**
 Start the observation (only necessary if you alloc/init yourself)
 */
- (BOOL)observe;

/**
 Stop the observation (not noramlly necessary if the observation object lifecycle/dealloc will go away at the appropriate time)
 */
- (void)invalidate;

@end


#define NormaliseNil(v) (v == [NSNull null] ? nil : v)

static const char *RFKVOControllerClassIsSwizzledKey = "RFKVOControllerClassIsSwizzledKey";
static const NSString *RFKVOControllerClassIsSwizzledLockKey = @"RFKVOControllerClassIsSwizzledLockKey";
static const char *RFKVOControllerObjectObserversKey = "RFKVOControllerObjectObserversKey";

@interface RFKVOController ()
@property NSOperationQueue *queue;
@end

@implementation RFKVOController

- (instancetype)init {
    self = [super init];
    if (self) {
        _isValid = NO;
    }
    return self;
}

- (void)dealloc {
    [self invalidate];
}

#pragma mark - convenience constructors

+ (RFKVOController *)observe:(id)observedObject keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options queue:(NSOperationQueue *)queue callback:(void (^)(RFKVOController * observation, NSDictionary * changeDictionary))callbackBlock {
    RFKVOController *obj = self.new;

    obj.observedObject = observedObject;
    obj.keyPath = keyPath;
    obj.options = options;
    obj.queue = queue;
    obj.callbackBlock = callbackBlock;

    if (obj.observe) return obj;
    return nil;
}

+ (RFKVOController *)bind:(id)observedObject keyPath:(NSString *)observedKeyPath toObject:(id)boundObject keyPath:(NSString *)boundObjectKeyPath {
    RFKVOController * observation = [self new];

    observation.observedObject = observedObject;
    observation.keyPath = observedKeyPath;
    observation.options = NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;

    @weakify(boundObject);
    observation.callbackBlock = ^(RFKVOController *observation, NSDictionary *changeDictionary) {
        @strongify(boundObject);
        id val = changeDictionary[NSKeyValueChangeNewKey];
        [boundObject setValue:NormaliseNil(val) forKeyPath:boundObjectKeyPath];
    };

    if ([observation observe]) return observation;

    return nil;
}

+ (NSArray<RFKVOController *> *)bidirectionallyBind:(id)objectA keyPath:(NSString *)keypathA withObject:(id)objectB keyPath:(NSString *)keypathB {
    RFKVOController *observationA = self.new;
    RFKVOController *observationB = self.new;

    observationA.observedObject = objectA;
    observationA.keyPath = keypathA;
    observationA.options = NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew;

    observationB.observedObject = objectB;
    observationB.keyPath = keypathB;
    observationB.options = NSKeyValueObservingOptionNew;

    __block BOOL bindingUpdateInProgress = NO;

    @weakify(objectB);
    observationA.callbackBlock = ^(RFKVOController *observation, NSDictionary *changeDictionary) {
        @strongify(objectB);
        if (bindingUpdateInProgress) return;
        bindingUpdateInProgress = YES;
        id val = changeDictionary[NSKeyValueChangeNewKey];
        [objectB setValue:NormaliseNil(val) forKeyPath:keypathB];
        bindingUpdateInProgress = NO;
    };

    @weakify(objectA);
    observationB.callbackBlock = ^(RFKVOController *observation, NSDictionary *changeDictionary) {
        @strongify(objectA);
        if (bindingUpdateInProgress) return;
        bindingUpdateInProgress = YES;
        id val = changeDictionary[NSKeyValueChangeNewKey];
        [objectA setValue:NormaliseNil(val) forKeyPath:keypathA];
        bindingUpdateInProgress = NO;
    };

    if (observationB.observe) {
        if (observationA.observe) {
            return @[observationA, observationB];
        }
        [observationB invalidate];
    }

    return nil;
}

#pragma mark - instance methods

+ (BOOL)automaticallyNotifiesObserversOfIsValid {
    return NO;
}

- (void)setIsValid:(BOOL)isValid {
    if (isValid == _isValid) return;

    [self willChangeValueForKey:@"isValid"];
    _isValid = isValid;
    [self didChangeValueForKey:@"isValid"];
}

- (void)_prepareObservedObjectAndClass {
    Class class = [self.observedObject class];

    @synchronized(RFKVOControllerClassIsSwizzledLockKey) {
        NSNumber *classIsSwizzled = objc_getAssociatedObject(class, RFKVOControllerClassIsSwizzledKey);
        if (!classIsSwizzled) {
            [self _swizzleDealloc:class];
        }

        // create the NSHashTable if needed - NSHashTable (when created as below) is bascially an NSMutableSet with weak references (doesn't require ARC)
        if (!objc_getAssociatedObject(self.observedObject, RFKVOControllerObjectObserversKey)) {
            NSHashTable * observeeObserverTrackingHashTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsStrongMemory];
            objc_setAssociatedObject(self.observedObject, RFKVOControllerObjectObserversKey, observeeObserverTrackingHashTable, OBJC_ASSOCIATION_RETAIN);
        }
    }
}

- (void)_swizzleDealloc:(Class)class {
    SEL deallocSel = NSSelectorFromString(@"dealloc");
    Method dealloc = class_getInstanceMethod(class, deallocSel);
    IMP origImpl = method_getImplementation(dealloc);
    IMP newImpl = imp_implementationWithBlock(^(void *obj) {
        @autoreleasepool {
            // I guess there is a possible race condition here with an observation being added *during* dealloc.
            // The copy means we won't crash here, but I imagine the observation will fail.
            
            NSHashTable *_observeeObserverTrackingHashTable = objc_getAssociatedObject((__bridge id)obj, RFKVOControllerObjectObserversKey);
            NSHashTable * observeeObserverTrackingHashTableCopy;
            @synchronized(_observeeObserverTrackingHashTable) {
                observeeObserverTrackingHashTableCopy = [_observeeObserverTrackingHashTable copy];
            }
            
            for (RFKVOController *observation in observeeObserverTrackingHashTableCopy) {
                //NSLog(@"Invalidating an observer in the swizzled dealloc");
                [observation _invalidateObservedObject:(__bridge id)obj andRemoveTargetAssociations:NO];
            }
        }
        ((void (*)(void *, SEL))origImpl)(obj, deallocSel);
    });
    
    class_replaceMethod(class, deallocSel, newImpl, method_getTypeEncoding(dealloc));
    objc_setAssociatedObject(class, RFKVOControllerClassIsSwizzledKey, @YES, OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)observe {
    if (self.isValid    // can't re-observe
        || !self.observedObject
        || !self.keyPath
        || !self.callbackBlock) return NO;
    
    // only swizzling the target dealloc for it to remove all observers - releasing/invalidating at the observer end
    // is its own responsibility
    [self _prepareObservedObjectAndClass];
    
    [self.observedObject addObserver:self forKeyPath:_keyPath options:_options context:NULL];
    
    NSHashTable *observeeObserverTrackingHashTable = objc_getAssociatedObject(self.observedObject, RFKVOControllerObjectObserversKey);
    @synchronized(observeeObserverTrackingHashTable) {
        [observeeObserverTrackingHashTable addObject:self];
    }
    self.isValid = YES;
    return YES;
}

- (void)invalidate {
    [self _invalidateObservedObject:self.observedObject andRemoveTargetAssociations:YES];
}

- (void)_invalidateObservedObject:(id)obj andRemoveTargetAssociations:(BOOL)removeTargetAssociations {
    if (!self.isValid) return;
    [self setIsValid:NO];
    [obj removeObserver:self forKeyPath:self.keyPath];

    if (removeTargetAssociations) {
        NSHashTable * observeeObserverTrackingHashTable = objc_getAssociatedObject(obj, RFKVOControllerObjectObserversKey);
        @synchronized(observeeObserverTrackingHashTable) {
            [observeeObserverTrackingHashTable removeObject:self];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (![self.keyPath isEqualToString:keyPath] || self.observedObject != object) {
        dout_error(@"RFKVOController: received observation for unexpected keyPath (%@) or object (%@)", keyPath, object);
        return;
    }

    if (!self.callbackBlock) {
        dout_error(@"RFKVOController: received observation but no callbackBlock is set");
        return;
    }

    if (!self.queue || self.queue == NSOperationQueue.currentQueue) {
        self.callbackBlock(self, change);
    }
    else {
        @weakify(self);
        [self.queue addOperationWithBlock:^{
            @strongify(self);
            self.callbackBlock(self, change);
        }];
    }
}

@end


@implementation NSObject (RFKVOWrapper)

- (id)RFAddObserver:(id)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options queue:(NSOperationQueue *)queue block:(void (^)(id _Nullable, NSDictionary * _Nonnull))block {
    NSParameterAssert(keyPath);
    @weakify(observer);
    RFKVOController *info = [RFKVOController observe:self keyPath:keyPath options:options queue:(NSOperationQueue *)queue callback:^(RFKVOController *observation, NSDictionary *changeDictionary) {
        if (block) {
            @strongify(observer);
            block(observer, changeDictionary);
        }
    }];
    return info;
}

- (BOOL)RFRemoveObserverWithIdentifier:(id)trampoline {
    if ([trampoline respondsToSelector:@selector(invalidate)]) {
        [trampoline invalidate];
        return YES;
    }
    return NO;
}

@end
