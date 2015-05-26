
#import "RFDataSourceArray.h"

@interface RFDataSourceArray ()
@property (strong, nonatomic) NSMutableArray *staticStore;
@property (strong, nonatomic) NSMapTable *cachedObjectMap;
@property (strong, nonatomic) NSNumber *cachedCount;
@end

@implementation RFDataSourceArray

#pragma mark - Init



#pragma mark -

- (NSMutableArray *)staticStore {
    if (_staticStore) return _staticStore;
    _staticStore = [NSMutableArray new];
    return _staticStore;
}

- (NSMapTable *)cachedObjectMap {
    if (_cachedObjectMap) return _cachedObjectMap;
    _cachedObjectMap = [NSMapTable strongToStrongObjectsMapTable];
    return _cachedObjectMap;
}

- (NSUInteger)count {
    if (!self.dataSource) {
        return [super count];
    }

    if (!self.cachedCount) {
        self.cachedCount = @([self.dataSource numberOfObjectInDataSourceArray:self]);
    }
    return [self.cachedCount unsignedIntegerValue];
}

- (id)objectAtIndex:(NSUInteger)index {
    if (!self.dataSource) {
        return [super objectAtIndex:index];
    }

    id obj = [self.cachedObjectMap objectForKey:@(index)];
    if (obj) return obj;

    obj = [self.dataSource dataSourceArray:self objectAtIndex:index];
    NSAssert(obj, @"DataSource return nil at index: %ld", (unsigned long)index);
    [self.cachedObjectMap setObject:obj forKey:@(index)];
    return obj;
}

- (void)setArray:(NSArray *)otherArray {
    [self.staticStore setArray:otherArray];
}

- (void)setDataSource:(id<RFDataSourceArrayDataSource>)dataSource {
    _dataSource = dataSource;
    [self reloadData];
}

- (void)reloadData {
    self.cachedCount = nil;
    [self.cachedObjectMap removeAllObjects];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes {
    if (!self.dataSource) {
        [self.staticStore removeObjectsAtIndexes:indexes];
        return;
    }

    if (_cachedObjectMap) {
        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [self.cachedObjectMap removeObjectForKey:@(idx)];
        }];
    }
}

@end
