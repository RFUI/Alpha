//
//  RFAssetsCacheRecord.h
//  BoYaSchool
//
//  Created by BB9z on 12/11/13.
//  Copyright (c) 2013 Chinamobo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RFAssetsCacheData;

@interface RFAssetsCacheRecord : NSManagedObject

@property (nonatomic, retain) NSData * briefData;
@property (nonatomic) int64_t indexHash;
@property (nonatomic, retain) NSString * uri;
@property (nonatomic, retain) NSString * etag;
@property (nonatomic) NSTimeInterval age;
@property (nonatomic, retain) RFAssetsCacheData *rowData;

@end
