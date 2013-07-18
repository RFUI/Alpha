
#import "NSManagedObject+RFCoreData.h"
#import "dout.h"

@implementation NSManagedObject (RFCoreData)

+ (NSString *)entityName {
    return NSStringFromClass(self);
}

+ (NSFetchRequest *)fetchRequest {
    return [NSFetchRequest fetchRequestWithEntityName:self.entityName];
}

+ (instancetype)objectWithValue:(id)value forKey:(NSString *)key inContext:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", key, value];
    NSFetchRequest *request = self.fetchRequest;
    request.fetchLimit = 1;
    request.predicate = predicate;
    
    NSError __autoreleasing *e = nil;
    NSArray *objects = [context executeFetchRequest:request error:&e];
    if (e) dout_error(@"%@", e);
    return [objects lastObject];
}

+ (instancetype)objectWithValue:(id)value forKey:(NSString *)key inContext:(NSManagedObjectContext *)context creatIfNotExist:(BOOL)creatIfNotExist {
    id object = [self objectWithValue:value forKey:key inContext:context];
    if (!object) {
        object = [NSEntityDescription insertNewObjectForEntityForName:self.entityName inManagedObjectContext:context];
        [object setValue:value forKey:key];
    }
    return object;
}

+ (NSArray *)objectsWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = self.fetchRequest;
    request.sortDescriptors = sortDescriptors;
    request.predicate = predicate;
    
    NSError __autoreleasing *e = nil;
    NSArray *objects = [context executeFetchRequest:request error:&e];
    if (e) dout_error(@"%@", e);
    return objects;
}

+ (NSArray *)allObjectsInContext:(NSManagedObjectContext *)context {
    return [self objectsWithPredicate:nil sortDescriptors:nil inContext:context];
}

+ (NSUInteger)countWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = self.fetchRequest;
    request.predicate = predicate;
    
    NSError __autoreleasing *e = nil;
    NSUInteger count = [context countForFetchRequest:request error:&e];
    if (e) dout_error(@"%@", e);
    return count;
}

- (void)delete {
    [self.managedObjectContext deleteObject:self];
}

@end
