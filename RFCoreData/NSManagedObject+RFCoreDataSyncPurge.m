
#import "NSManagedObject+RFCoreDataSyncPurge.h"

@implementation NSManagedObject (RFCoreDataSyncPurge)

+ (void)syncPurgeManagedObjectContext:(NSManagedObjectContext *)context entityName:(NSString *)entityName {
    NSManagedObject<RFCoreDataSyncPurging> *this;
    NSFetchRequest *syncedRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    syncedRequest.predicate = [NSPredicate predicateWithFormat:@"%K = YES", @keypath(this, syncFlag)];
    NSArray *syncedObjects = [context executeFetchRequest:syncedRequest error:nil];
    if (syncedObjects.count == 0) return;
    
    NSFetchRequest *allObjectRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSError __autoreleasing *e = nil;
    NSArray *allObjects = [context executeFetchRequest:allObjectRequest error:&e];
    if (e) dout_error(@"%@", e);
    for (this in allObjects) {
        if (this.syncFlag) {
            this.syncFlag = NO;
        }
        else {
            [context deleteObject:this];
        }
    }
}

@end
