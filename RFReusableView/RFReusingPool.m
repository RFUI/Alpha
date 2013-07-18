
#import "RFReusingPool.h"

@interface RFReusingPool ()
@property(strong, atomic) NSMutableDictionary *pool;
@end

@implementation RFReusingPool

- (id)init {
    self = [super init];
    if (self) {
        [self onInit];
        [self performSelector:@selector(afterInit) withObject:nil afterDelay:0];
    }
    return self;
}

- (void)onInit {
    self.pool = [NSMutableDictionary dictionary];
}
- (void)afterInit {
}

- (id<RFReusing>)dequeueReusableObjectWithIdentifier:(NSString *)identifier {
    NSParameterAssert(identifier);
    NSMutableSet *subPool = self.pool[identifier];
    if (!subPool) return nil;
    
    @synchronized(subPool) {
        id<RFReusing> obj = [subPool anyObject];
        if (obj) {
            [subPool removeObject:obj];
            if ([obj respondsToSelector:@selector(willReused)]) {
                [obj willReused];
            }
            return obj;
        }
    }
    return nil;
}

- (void)recycleObject:(id<RFReusing>)object {
    NSString *identifier = object.reuseIdentifier;
    NSParameterAssert(identifier);
    NSMutableSet *subPool = self.pool[identifier];
    if (!subPool) {
        @synchronized(self.pool) {
            NSMutableSet *tmpPool = self.pool[identifier];
            if (tmpPool) {
                subPool = tmpPool;
            }
            else {
                subPool = [NSMutableSet set];
                _dout(@"Add sub pool %@:%p", identifier, subPool);
                self.pool[identifier] = subPool;
            }
        }
    }
    
    [subPool addObject:object];
    if ([object respondsToSelector:@selector(didRecycled)]) {
        [object didRecycled];
    }
}

- (void)cleanPool {
    @synchronized(self.pool) {
        [self.pool enumerateKeysAndObjectsUsingBlock:^(id key, NSArray *subPool, BOOL *stop) {
            if (!subPool.count) {
                [self.pool removeObjectForKey:key];
            }
        }];
    }
}

@end
