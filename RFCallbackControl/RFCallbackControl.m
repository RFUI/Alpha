
#import "RFCallbackControl.h"
#import <RFKit/NSArray+RFKit.h>

@interface RFCallback ()
- (BOOL)_performFrom:(id)source;
@end

@interface RFCallbackControl ()
@property (nonnull) NSMutableArray *_RFCallbackControl_callbacks;
@end

@implementation RFCallbackControl

- (instancetype)init {
    if (!(self = [super init])) return self;
    _objectClass = _objectClass?: RFCallback.class;
    __RFCallbackControl_callbacks = __RFCallbackControl_callbacks?: [NSMutableArray.alloc initWithCapacity:20];
    return self;
}

- (BOOL)hasCallback {
    return self._RFCallbackControl_callbacks.count > 0;
}

- (id)addCallbackWithTarget:(id)target selector:(SEL)selector refrenceObject:(id)object {
    if (!object) return nil;
    __kindof RFCallback *co = self.objectClass.new;
    co.refrenceObject = object;
    co.target = target;
    co.selector = selector;
    @synchronized(self) {
        [self._RFCallbackControl_callbacks addObject:co];
    }
    return co;
}

- (id)addCallback:(id)callback refrenceObject:(id)object {
    if (!object) return nil;
    __kindof RFCallback *co = self.objectClass.new;
    co.refrenceObject = object;
    co.block = callback;
    @synchronized(self) {
        [self._RFCallbackControl_callbacks addObject:co];
    }
    return co;
}

- (void)removeCallback:(id)callbackRefrence {
    if (!callbackRefrence) return;
    @synchronized(self) {
        [self._RFCallbackControl_callbacks removeObject:callbackRefrence];
    }
}

- (void)removeCallbackOfRefrenceObject:(id)object {
    if (!object) return;
    @synchronized(self) {
        [self._RFCallbackControl_callbacks removeObjectsPassingTest:^BOOL(RFCallback *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return obj.refrenceObject == object;
        }];
    }
}

- (void)removeAllCallbacks {
    @synchronized(self) {
        [self._RFCallbackControl_callbacks removeAllObjects];
    }
}

- (void)performWithSource:(id)source filter:(NS_NOESCAPE BOOL (^)(id _Nonnull, NSUInteger, BOOL * _Nonnull))predicate {
    NSArray *cbs = self._RFCallbackControl_callbacks.copy;
    if (predicate) {
        NSIndexSet *is = [cbs indexesOfObjectsPassingTest:predicate];
        cbs = [cbs objectsAtIndexes:is];
    }
    
    for (RFCallback *cb in cbs) {
        if ([cb _performFrom:source]) continue;
        @synchronized(self) {
            [self._RFCallbackControl_callbacks removeObject:cb];
        }
    }
}

@end

@implementation RFCallback

- (BOOL)_performFrom:(id)source {
    if (!self.refrenceObject) return NO;
    id target = self.target;
    SEL aSelector = self.selector;
    if (target && aSelector) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector:aSelector withObject:source];
#pragma clang diagnostic pop
        return [self _updateLiveCounter];
    }
    id cb = self.block;
    if (cb) {
        [self perfromBlock:cb source:source];
        return [self _updateLiveCounter];
    }
    return NO;
}

- (BOOL)_updateLiveCounter {
    int c = self.liveCounter;
    if (c == 0) return YES;
    self.liveCounter = c - 1;
    return c > 1;
}

- (void)perfromBlock:(id)block source:(id)source {
    dispatch_block_t cb = block;
    cb();
}

@end
