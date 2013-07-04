
#import "NSManagedObject+RFCoreDataSyncPurge.h"

@implementation NSManagedObject (RFCoreDataSyncPurge)

+ (void)syncPurgeManagedObjectContext:(NSManagedObjectContext *)context {
    NSManagedObject<RFCoreDataSyncPurging> *this;
    if ([self countWithPredicate:[NSPredicate predicateWithFormat:@"%K = YES", @keypath(this, syncFlag)] inContext:context] == 0) return;
    
    for (this in [self allObjectsInContext:context]) {
        if (this.syncFlag) {
            this.syncFlag = NO;
        }
        else {
            [this delete];
        }
    }
}

@end
