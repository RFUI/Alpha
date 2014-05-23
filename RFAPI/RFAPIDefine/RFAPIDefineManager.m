
#import "RFAPIDefineManager.h"
#import "RFAPI.h"
#import "AFURLRequestSerialization.h"
#import "AFURLResponseSerialization.h"
#import "RFAPIDefineConfigFileKeys.h"

@interface RFAPIDefineManager ()
@property (strong, nonatomic) NSCache *defineCache;

@property (strong, nonatomic, readwrite) NSMutableDictionary *defaultRule;
@property (strong, nonatomic) NSMutableDictionary *rawRules;
@end

@implementation RFAPIDefineManager
RFInitializingRootForNSObject

- (void)onInit {
    _defineCache = [[NSCache alloc] init];
    _defineCache.name = @"RFAPIDefineCache";

    _defaultRule = [[NSMutableDictionary alloc] initWithCapacity:20];
    _rawRules = [[NSMutableDictionary alloc] initWithCapacity:50];
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

- (void)setNeedsUpdateDefaultRule {
    [self.defineCache removeAllObjects];
}

- (void)mergeWithRules:(NSDictionary *)rules {
    [self.defineCache removeAllObjects];

    // Check and add.
    [rules enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSDictionary *rule, BOOL *stop) {
        RFAPIDefine *define = [[RFAPIDefine alloc] initWithRule:rule name:name];
        if (define) {
            if ([name isEqualToString:RFAPIDefineDefaultKey]) {
                [self.defaultRule setDictionary:rule];
                [self setNeedsUpdateDefaultRule];
            }

            [self.rawRules setObject:rule forKey:name];
        }
        else {
            dout_warning(@"Bad rule(%@): %@", name, rule);
        }
    }];
}

- (NSDictionary *)mergedRuleForName:(NSString *)defineName {
    NSDictionary *rule = self.rawRules[defineName];
    if (!rule) {
        dout_warning(@"Can not find a rule with name: %@", defineName);
        return nil;
    }

    NSMutableDictionary *mergedRule = [self.defaultRule mutableCopy];
    [mergedRule addEntriesFromDictionary:rule];
    return mergedRule;
}

- (RFAPIDefine *)defineForName:(NSString *)defineName {
    NSParameterAssert(defineName.length);

    RFAPIDefine *define = [self.defineCache objectForKey:defineName];
    if (define) {
        return define;
    }

    NSDictionary *rule = [self mergedRuleForName:defineName];
    if (!rule) {
        return nil;
    }

    define = [[RFAPIDefine alloc] initWithRule:rule name:defineName];
    if (!define) {
        return nil;
    }

    [self.defineCache setObject:define forKey:defineName];
    return define;
}

#pragma mark - RFAPI Support

- (NSURL *)requestURLForDefine:(RFAPIDefine *)define error:(NSError *__autoreleasing *)error {
    NSString *URLString = define.pathPrefix? [define.pathPrefix stringByAppendingString:define.path] : define.path;
    NSURL *url = [NSURL URLWithString:URLString relativeToURL:define.baseURL];
    if (!url) {
#if RFDEBUG
        dout_error(@"无法拼接路径 %@ 到 %@\n请检查接口定义", define.path, define.baseURL);
#endif
        if (error) {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:@{
                NSLocalizedDescriptionKey : @"内部错误，无法创建请求",
                NSLocalizedFailureReasonErrorKey : @"很可能是应用 bug",
                NSLocalizedRecoverySuggestionErrorKey : @"请再试一次，如果依旧请尝试重启应用。给您带来不便，敬请谅解"
            }];
        }
        return nil;
    }
    return url;
}

- (id)requestSerializerForDefine:(RFAPIDefine *)define {
    if (define.requestSerializerClass) {
        return [define.requestSerializerClass serializer];
    }
    return self.master.requestSerializer;
}

- (id)responseSerializerForDefine:(RFAPIDefine *)define {
    if (define.responseSerializerClass) {
        return [define.responseSerializerClass serializer];
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
    __RFAPIDefineConfigFileValue(KEY) {\
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
            self.PROPERTY = aClass;\
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

        __RFAPIDefineConfigFileProperty(pathPrefix, RFAPIDefinePathPrefixKey)
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

        __RFAPIDefineConfigFileValue(RFAPIDefineResponseTypeKey) {
            self.responseExpectType = [value intValue];
        }

        __RFAPIDefineConfigFileClassProperty(responseSerializerClass, RFAPIDefineResponseSerializerKey)

        __RFAPIDefineConfigFileClassProperty(responseClass, RFAPIDefineResponseClassKey)
        __RFAPIDefineConfigFileDictionaryProperty(userInfo, RFAPIDefineUserInfoKey)
        __RFAPIDefineConfigFileProperty(notes, RFAPIDefineNotesKey)

#undef __RFAPIDefineConfigFileValue
#undef __RFAPIDefineConfigFileProperty
#undef __RFAPIDefineConfigFileDictionaryProperty
#undef __RFAPIDefineConfigFileClassProperty
#undef __RFAPIDefineConfigFileEnumCase
    }
    return self;
}

@end
