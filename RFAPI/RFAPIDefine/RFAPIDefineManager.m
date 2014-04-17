
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
- (void)afterInit {
}

- (id)initWithRules:(NSDictionary *)rules {
    self = [self init];
    if (self) {
        [self mergeWithRules:rules];
    }
    return self;
}

- (void)mergeWithRules:(NSDictionary *)rules {
    _douto(rules)
    [rules enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSDictionary *rule, BOOL *stop) {
        RFAPIDefine *define = [[RFAPIDefine alloc] initWithRule:rule name:name];
        if (define) {
            if ([name isEqualToString:RFAPIDefineDefaultKey]) {
                self.defaultDefine = define;
            }
            else {
                [self.rules setObject:define forKey:name];
            }
        }
    }];
    _douto(self.rules)
}

- (RFAPIDefine *)defineForName:(NSString *)defineName {
    return [self.rules objectForKey:defineName];
}

#pragma mark - RFAPI Support

- (id)requestSerializerForDefine:(RFAPIDefine *)define {
    if (define.requestSerializerClass) {
        return [define.requestSerializerClass serializer];
    }
    return self.master.requestSerializer;
}

- (id)responseSerializerForDefine:(RFAPIDefine *)define {
    if (define.responseClass) {
        return [define.responseClass serializer];
    }
    return self.master.responseSerializer;
}

@end

@implementation RFAPIDefine (RFConfigFile)

- (id)initWithRule:(NSDictionary *)rule name:(NSString *)name {
    NSParameterAssert(name);
    NSParameterAssert(rule);
    self = [self init];
    if (self) {
        self.name = name;

        id value;

#define __RFAPIDefineConfigFileValue(KEY)\
    value = nil;\
    if ((value = rule[KEY]))

#define __RFAPIDefineConfigFileProperty(PROPERTY, KEY)\
    __RFAPIDefineConfigFileValue(KEY) {\
        self.PROPERTY = value;\
    }

#define __RFAPIDefineConfigFileDictionaryProperty(PROPERTY, KEY)\
    __RFAPIDefineConfigFileValue(RFAPIDefineHeadersKey) {\
        if (![value isKindOfClass:[NSDictionary class]]) {\
            dout_error(@"%@ must be a dictionary.", KEY);\
            return nil;\
        }\
        self.PROPERTY = value;\
    }

#define __RFAPIDefineConfigFileClassProperty(PROPERTY, KEY)\
    __RFAPIDefineConfigFileValue(KEY) {\
        Class aClass = NSClassFromString(value);\
        if (aClass) {\
            self.PROPERTY = value;\
        }\
        else {\
            dout_warning(@"Can not get class from name: %@", value);\
        }\
    }

#define __RFAPIDefineConfigFileEnumCase(PROPERTY, ENUM)\
    case ENUM:\
        self.PROPERTY = ENUM;\
        break;

        __RFAPIDefineConfigFileValue(RFAPIDefineBaseKey) {
            NSURL *url = [NSURL URLWithString:value];
            if (url) {
                self.baseURL = url;
            }
        }

        __RFAPIDefineConfigFileProperty(path, RFAPIDefinePathKey)
        __RFAPIDefineConfigFileProperty(method, RFAPIDefineMethodKey)
        __RFAPIDefineConfigFileDictionaryProperty(HTTPRequestHeaders, RFAPIDefineHeadersKey)

        __RFAPIDefineConfigFileDictionaryProperty(defaultParameters, RFAPIDefineParametersKey)

        __RFAPIDefineConfigFileValue(RFAPIDefineAuthorizationKey) {
            self.needsAuthorization = [value boolValue];
        }
        __RFAPIDefineConfigFileClassProperty(requestSerializerClass, RFAPIDefineRequestSerializerKey)

        __RFAPIDefineConfigFileValue(RFAPIDefineCachePolicyKey) {
            switch ([value shortValue]) {
                __RFAPIDefineConfigFileEnumCase(cachePolicy, RFAPICachePolicyDefault)
                __RFAPIDefineConfigFileEnumCase(cachePolicy, RFAPICachePolicyProtocol)
                __RFAPIDefineConfigFileEnumCase(cachePolicy, RFAPICachePolicyAlways)
                __RFAPIDefineConfigFileEnumCase(cachePolicy, RFAPICachePolicyExpire)
                __RFAPIDefineConfigFileEnumCase(cachePolicy, RFAPICachePolicyNoCache)
                default:
                    dout_error(@"Unknow cache policy: %@", value)
                    return nil;
            }
        }

        __RFAPIDefineConfigFileValue(RFAPIDefineExpireKey) {
            self.expire = [value intValue];
        }

        __RFAPIDefineConfigFileValue(RFAPIDefineOfflinePolicyKey) {
            switch ([value shortValue]) {
                    __RFAPIDefineConfigFileEnumCase(offlinePolicy, RFAPOfflinePolicyDefault)
                    __RFAPIDefineConfigFileEnumCase(offlinePolicy, RFAPOfflinePolicyLoadCache)
                default:
                    dout_error(@"Unknow offline policy: %@", value)
                    return nil;
            }
        }

        __RFAPIDefineConfigFileClassProperty(responseSerializerClass, RFAPIDefineResponseSerializerKey)

        __RFAPIDefineConfigFileValue(RFAPIDefineResponseListKey) {
            self.responseList = [value boolValue];
        }

        __RFAPIDefineConfigFileClassProperty(responseClass, RFAPIDefineResponseClassKey)
        __RFAPIDefineConfigFileDictionaryProperty(userInfo, RFAPIDefineUserInfoKey)

#undef __RFAPIDefineConfigFileValue
#undef __RFAPIDefineConfigFileProperty
#undef __RFAPIDefineConfigFileDictionaryProperty
#undef __RFAPIDefineConfigFileClassProperty
#undef __RFAPIDefineConfigFileEnumCase
    }
    return self;
}

@end
