/*!
    NSManagedObject (RFCoreData)
    RFCoreData

    Copyright (c) 2013 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Alpha
 */

#import <CoreData/CoreData.h>

@interface NSManagedObject (RFCoreData)

// Use class name by default.
+ (NSString *)entityName;

// Create a fecth request based on the class
+ (NSFetchRequest *)fetchRequest;

// Find a object with simple key-value pairs. If there are more than one objects match the key-value pairs, only first will returned.
+ (instancetype)objectWithValue:(id)value forKey:(NSString *)key inContext:(NSManagedObjectContext *)context;
+ (instancetype)objectWithValue:(id)value forKey:(NSString *)key inContext:(NSManagedObjectContext *)context creatIfNotExist:(BOOL)creatIfNotExist;

+ (NSArray *)objectsWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context;
+ (NSArray *)allObjectsInContext:(NSManagedObjectContext *)context;

// The number of objects.
// Return NSNotFound if an error occurs.
+ (NSUInteger)countWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;

// Delete an object from its managedObjectContext.
- (void)delete;

@end
