
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RFAssetsCacheRecord;

@interface RFAssetsCacheData : NSManagedObject

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) RFAssetsCacheRecord *info;

@end
