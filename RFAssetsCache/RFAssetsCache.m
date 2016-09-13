
#import "RFAssetsCache.h"
#import "RFCoreData.h"
#import "RFAssetsCacheRecord.h"
#import "RFAssetsCacheData.h"

@interface RFAssetsCacheOperation : NSBlockOperation
@property (copy, nonatomic) NSString *URI;
@end

@implementation RFAssetsCacheOperation
@end

@interface RFAssetsCache ()
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, readwrite, nonatomic) NSOperationQueue *operationQueue;
@property (copy, nonatomic) NSString *cacheFileName;
@end

@implementation RFAssetsCache
RFInitializingRootForNSObject

- (instancetype)initWithCacheFileName:(NSString *)cacheFileName {
    self = [super init];
    if (self) {
        _cacheFileName = cacheFileName;
        [self onInit];
        [self performSelector:@selector(afterInit) withObject:self afterDelay:0];
    }
    return self;
}

- (void)onInit {
    NSOperationQueue *oq = [[NSOperationQueue alloc] init];
    [oq setName:@"com.github.RFUI.RFAssetsCacheQueue"];
    [oq setMaxConcurrentOperationCount:1];
    self.operationQueue = oq;

    [oq addOperationWithBlock:^{
        [self setupContext];
    }];
}

- (void)afterInit {
    // Nothing
}

- (void)setupContext {
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"RFAssetsCache" withExtension:@"mom" subdirectory:@"RFAssetsCache.momd"];
    RFAssert(modelURL, nil);
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSURL *cacheDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
    NSURL *cacheURL = [cacheDirectoryURL URLByAppendingPathComponent:self.cacheFileName?: @"com.github.RFUI.RFAssetsCacheRecord"];
    RFAssert(cacheURL, nil);
    NSError __autoreleasing *e = nil;
    if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:modelURL options:@{
          NSMigratePersistentStoresAutomaticallyOption : @YES,
          NSInferMappingModelAutomaticallyOption : @YES } error:&e]) {
        if (e) dout_error(@"%@", e);
        [[NSFileManager defaultManager] removeItemAtURL:cacheURL error:nil];
        [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:modelURL options:nil error:nil];
    };
    self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [self.context setPersistentStoreCoordinator:psc];
    douto(self.context)
}

- (void)dealloc {
    RF_dispatch_release(self.operationQueue);
}

- (void)cacheWithURI:(NSString *)uri data:(NSData *)data briefData:(NSData *)briefData age:(NSTimeInterval)age etag:(NSString *)etag completionHandler:(void (^)(NSError *error))completionHandler {
    
    @weakify(self);
    RFAssetsCacheOperation *op = [RFAssetsCacheOperation blockOperationWithBlock:^{
        @strongify(self);
        
        NSError __autoreleasing *e = nil;
        
        RFAssetsCacheRecord *record = [self recordWithURI:uri error:&e];
        if (e) dout_error(@"%@", e);
        
        if (!record) {
            record = [NSEntityDescription insertNewObjectForEntityForName:RFAssetsCacheRecord.entityName inManagedObjectContext:self.context];
            record.indexHash = uri.hash;
            record.uri = uri;
        }
        
        record.briefData = briefData;
        record.age = age;
        record.etag = etag;
        if (record.rowData) {
            record.rowData.data = data;
        }
        else {
            RFAssetsCacheData *rowData = [NSEntityDescription insertNewObjectForEntityForName:RFAssetsCacheData.entityName inManagedObjectContext:self.context];
            rowData.data = data;
            record.rowData = rowData;
        }
        
        if (completionHandler) {
            completionHandler(e);
        }
    }];
    
    op.URI = uri;
    [self.operationQueue addOperation:op];
}

- (void)requestCacheWithURI:(NSString *)uri completionHandler:(void (^)(NSData *response, RFAssetsCacheStatus status, NSObject<RFAssetsCacheRecord> *record, NSError *error))completionHandler {
    @weakify(self);
    RFAssetsCacheOperation *op = [RFAssetsCacheOperation blockOperationWithBlock:^{
        @strongify(self);
        
        NSError __autoreleasing *e = nil;
        
        RFAssetsCacheRecord *record = [self recordWithURI:uri error:&e];
        if (e) dout_error(@"%@", e);
        
        if (completionHandler) {
            completionHandler(record.rowData.data, RFAssetsCacheStatusOK, (NSObject<RFAssetsCacheRecord> *)record, e);
        }
    }];
    
    op.URI = uri;
    [self.operationQueue addOperation:op];
}

- (RFAssetsCacheRecord *)recordWithURI:(NSString *)uri error:(NSError *__autoreleasing *)error {
    NSFetchRequest *request = RFAssetsCacheRecord.fetchRequest;
    request.predicate = [NSPredicate predicateWithFormat:@"%K == %d && %K == %@", @keypathClassInstance(RFAssetsCacheRecord, indexHash), uri.hash, @keypathClassInstance(RFAssetsCacheRecord, uri), uri];
    
    NSError __autoreleasing *e = nil;
    NSArray *objects = [self.context executeFetchRequest:request error:&e];
    if (e) {
        if (error) {
            error = &e;
        }
        else {
            dout_error(@"%@", e);
        }
    }
    
    RFAssert(objects.count < 2, nil);
    return objects.firstObject;
}


@end
