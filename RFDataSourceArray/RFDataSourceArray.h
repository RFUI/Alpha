/*!
 RFDataSourceArray
 
 Copyright © 2015, 2018 BB9z
 https://github.com/RFUI/Alpha
 
 The MIT License (MIT)
 http://www.opensource.org/licenses/mit-license.php
 */
#import <Foundation/Foundation.h>

@protocol RFDataSourceArrayDataSource;

/**
 If dataSource not set, this class behave just like an normal NSArray object.
 */
@interface RFDataSourceArray<__covariant ObjectType> : NSArray

- (void)setArray:(nullable NSArray<ObjectType> *)otherArray;

#pragma mark - Data Source mode

@property (weak, nullable, nonatomic) id<RFDataSourceArrayDataSource> dataSource;

/**
 If contents for the dataSource changed, you may call this method to refresh.
 */
- (void)reloadData;

/**
 Removes the objects at the specified indexes from the array.
 
 @param indexes Must not be `nil`, or an exception raises.
 */
- (void)removeObjectsAtIndexes:(nonnull NSIndexSet *)indexes;

@end

@protocol RFDataSourceArrayDataSource <NSObject>
@required

- (NSUInteger)numberOfObjectInDataSourceArray:(nonnull RFDataSourceArray *)array;

/**
 @return The object located at index, must not be nil.
 */
- (nonnull id)dataSourceArray:(nonnull RFDataSourceArray *)array objectAtIndex:(NSUInteger)index;

@end
