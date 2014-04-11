
#import "RFAPIDefineManager.h"
#import "RFAPI.h"
#import "AFURLRequestSerialization.h"
#import "AFURLResponseSerialization.h"
#import "RFAPIDefineConfigFileKeys.h"

@interface RFAPIDefineManager ()
@property (strong, nonatomic) NSMutableDictionary *rules;
@end

@implementation RFAPIDefineManager
RFInitializingRootForNSObject

- (void)onInit {
    _rules = [[NSMutableDictionary alloc] initWithCapacity:50];
}

- (id)initWithRules:(NSDictionary *)rules {
    self = [self init];
    if (self) {


        [rules enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary *rule, BOOL *stop) {

        }];
    }
    return self;
}

- (void)afterInit {
}

- (RFAPIDefine *)defineForName:(NSString *)defineName {
    return [self.rules objectForKey:defineName];
}

- (void)addDefine:(RFAPIDefine *)define {
    if (self.defaultDefine) {

    }

    [self.rules setObject:define forKey:define];
}

#pragma mark - RFAPI Support

- (id)requestSerializerForDefine:(RFAPIDefine *)define {
    if (define.serializerName.length) {
        return [NSClassFromString(define.serializerName) serializer];
    }
    return self.master.requestSerializer;
}

- (id)responseSerializerForDefine:(RFAPIDefine *)define {
    if (define.responseSerializerName.length) {
        return [NSClassFromString(define.responseSerializerName) serializer];
    }
    return self.master.responseSerializer;
}

@end

@implementation RFAPIDefine (RFConfigFile)

- (id)initWithRule:(NSDictionary *)rule {
    self = [self init];
    if (self) {

    }
    return self;
}

@end
