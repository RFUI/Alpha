/*!
    RFDataSourceArray

    Copyright (c) 2015 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    TEST
 */
#import <Foundation/Foundation.h>

@protocol RFDataSourceArrayDataSource;

/**
 If dataSource not set, this class behave just like an normal NSArray object.
 */
@interface RFDataSourceArray : NSArray

- (void)setArray:(NSArray *)otherArray;

#pragma mark - Data Source mode

@property (weak, nonatomic) id<RFDataSourceArrayDataSource> dataSource;
- (void)reloadData;

@end

@protocol RFDataSourceArrayDataSource <NSObject>
@required

- (NSUInteger)numberOfObjectInDataSourceArray:(RFDataSourceArray *)array;
- (id)dataSourceArray:(RFDataSourceArray *)array objectAtIndex:(NSUInteger)index;

@end
