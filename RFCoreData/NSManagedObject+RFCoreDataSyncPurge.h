/*!
    NSManagedObject (RFCoreDataSyncPurge)
    RFCoreData

    Copyright (c) 2013 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Alpha
 */

#import "RFCoreData.h"

@interface NSManagedObject (RFCoreDataSyncPurge)
+ (void)syncPurgeManagedObjectContext:(NSManagedObjectContext *)context;
@end

@protocol RFCoreDataSyncPurging <NSObject>
@required
@property (nonatomic) BOOL syncFlag;
@end
