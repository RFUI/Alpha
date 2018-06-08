
#import "RFDataSourceArray.h"

@interface RFDataSourceArray ()
@property (nonatomic) NSMutableArray *_RFDataSourceArray_staticStore;
@property (nonatomic) NSMapTable *_RFDataSourceArray_cachedObjectMap;
@property (nonatomic) NSNumber *_RFDataSourceArray_cachedCount;
@end

@implementation RFDataSourceArray

- (NSMutableArray *)_RFDataSourceArray_staticStore {
    if (__RFDataSourceArray_staticStore) return __RFDataSourceArray_staticStore;
    __RFDataSourceArray_staticStore = NSMutableArray.new;
    return __RFDataSourceArray_staticStore;
}

- (NSMapTable *)_RFDataSourceArray_cachedObjectMap {
    if (__RFDataSourceArray_cachedObjectMap) return __RFDataSourceArray_cachedObjectMap;
    __RFDataSourceArray_cachedObjectMap = NSMapTable.strongToStrongObjectsMapTable;
    return __RFDataSourceArray_cachedObjectMap;
}

- (NSUInteger)count {
    if (!self.dataSource) {
        return super.count;
    }

    if (!self._RFDataSourceArray_cachedCount) {
        self._RFDataSourceArray_cachedCount = @([self.dataSource numberOfObjectInDataSourceArray:self]);
    }
    return self._RFDataSourceArray_cachedCount.unsignedIntegerValue;
}

- (id)objectAtIndex:(NSUInteger)index {
    if (index >= self.count) {
        return nil;
    }
    if (!self.dataSource) {
        return [super objectAtIndex:index];
    }

    id obj = [self._RFDataSourceArray_cachedObjectMap objectForKey:@(index)];
    if (obj) return obj;

    obj = [self.dataSource dataSourceArray:self objectAtIndex:index];
    NSAssert(obj, @"DataSource return nil at index: %ld", (unsigned long)index);
    [self._RFDataSourceArray_cachedObjectMap setObject:obj forKey:@(index)];
    return obj;
}

- (void)setArray:(NSArray *)otherArray {
    [self._RFDataSourceArray_staticStore setArray:otherArray];
}

- (void)setDataSource:(id<RFDataSourceArrayDataSource>)dataSource {
    _dataSource = dataSource;
    [self reloadData];
}

- (void)reloadData {
    self._RFDataSourceArray_cachedCount = nil;
    [self._RFDataSourceArray_cachedObjectMap removeAllObjects];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes {
    if (!self.dataSource) {
        [self._RFDataSourceArray_staticStore removeObjectsAtIndexes:indexes];
        return;
    }

    if (__RFDataSourceArray_cachedObjectMap) {
        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [self._RFDataSourceArray_cachedObjectMap removeObjectForKey:@(idx)];
        }];
    }
    self._RFDataSourceArray_cachedCount = nil;
}

@end
