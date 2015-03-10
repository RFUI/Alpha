
#import "RFAPIDefineManager.h"
#import "RFAPI.h"
#import "RFAPIDefineConfigFileKeys.h"

@interface RFAPIDefineManager ()
@property (strong, nonatomic) NSCache *defineCache;

@property (strong, nonatomic, readwrite) NSMutableDictionary *defaultRule;
@property (strong, nonatomic, readwrite) NSMutableDictionary *rawRules;

@property (strong, nonatomic, readwrite) NSMutableDictionary *authorizationHeader;
@property (strong, nonatomic, readwrite) NSMutableDictionary *authorizationParameters;

@end

@implementation RFAPIDefineManager
RFInitializingRootForNSObject

+ (NSRegularExpression *)cachedPathParameterRegularExpression {
    static NSRegularExpression *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[NSRegularExpression alloc] initWithPattern:@"\\{\\w+\\}" options:NSRegularExpressionAnchorsMatchLines error:nil];
        RFAssert(sharedInstance, @"Cannot create path parameter regular expression");
    });
    return sharedInstance;
}

- (void)onInit {
    _defineCache = [[NSCache alloc] init];
    _defineCache.name = @"RFAPIDefineCache";

    _defaultRule = [[NSMutableDictionary alloc] initWithCapacity:20];
    _rawRules = [[NSMutableDictionary alloc] initWithCapacity:50];
    _authorizationHeader = [[NSMutableDictionary alloc] initWithCapacity:3];
    _authorizationParameters = [[NSMutableDictionary alloc] initWithCapacity:3];
}
- (void)afterInit {
}

- (void)setNeedsUpdateDefaultRule {
    [self.defineCache removeAllObjects];
}

- (void)setDefinesWithRulesInfo:(NSDictionary *)rules {
    [self.defineCache removeAllObjects];

    // Check and add.
    [rules enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSDictionary *rule, BOOL *stop) {
        RFAPIDefine *define = [[RFAPIDefine alloc] initWithRule:rule name:name];
        if (define) {
            if ([name isEqualToString:RFAPIDefineDefaultKey]) {
                [self.defaultRule setDictionary:rule];
            }

            (self.rawRules)[name] = rule;
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

#pragma mark - Access raw rule values

- (id)valueForRule:(NSString *)key defineName:(NSString *)defineName {
    return self.rawRules[defineName][key];
}

- (void)setValue:(id)value forRule:(NSString *)key defineName:(NSString *)defineName {
    (self.rawRules[defineName])[key] = value;
}

- (void)removeRule:(NSString *)key withDefineName:(NSString *)defineName {
    NSMutableDictionary *dict = [self.rawRules[defineName] mutableCopy];
    [dict removeObjectForKey:key];
    self.rawRules[defineName] = dict;
}

#pragma mark - RFAPI Support

- (NSURL *)requestURLForDefine:(RFAPIDefine *)define parameters:(NSMutableDictionary *)parameters error:(NSError *__autoreleasing *)error {
    NSMutableString *path = [define.path mutableCopy];

    // Replace {PARAMETER} in path
    NSArray *matches = [[RFAPIDefineManager cachedPathParameterRegularExpression] matchesInString:path options:kNilOptions range:NSMakeRange(0, path.length)];

    for (NSTextCheckingResult *match in matches.reverseObjectEnumerator) {
        NSRange keyRange = match.range;
        keyRange.location++;
        keyRange.length -= 2;
        NSString *key = [path substringWithRange:keyRange];

        id parameter = parameters[key];
        if (parameter) {
            NSString *encodedParameter = [[parameter description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [path replaceCharactersInRange:match.range withString:encodedParameter];
            [parameters removeObjectForKey:key];
        }
        else {
            [path replaceCharactersInRange:match.range withString:@""];
        }
    }

    NSURL *url;
    if ([path hasPrefix:@"http://"] || [path hasPrefix:@"https://"]) {
        url = [NSURL URLWithString:path];
    }
    else {
        NSString *URLString = define.pathPrefix? [define.pathPrefix stringByAppendingString:path] : path;
        url = [NSURL URLWithString:URLString relativeToURL:define.baseURL];
    }
    if (!url) {
#if RFDEBUG
        dout_error(@"无法拼接路径 %@ 到 %@\n请检查接口定义", path, define.baseURL);
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
    return self.defaultRequestSerializer;
}

- (id)responseSerializerForDefine:(RFAPIDefine *)define {
    if (define.responseSerializerClass) {
        return [define.responseSerializerClass serializer];
    }
    return self.defaultResponseSerializer;
}

- (id<AFURLRequestSerialization>)defaultRequestSerializer {
    if (!_defaultRequestSerializer) {
        _defaultRequestSerializer = [AFHTTPRequestSerializer serializer];
    }
    return _defaultRequestSerializer;
}

- (id<AFURLResponseSerialization>)defaultResponseSerializer {
    if (!_defaultResponseSerializer) {
        _defaultResponseSerializer = [AFJSONResponseSerializer serializer];
    }
    return _defaultResponseSerializer;
}

@end


@implementation RFAPIDefine (RFConfigFile)

- (instancetype)initWithRule:(NSDictionary *)rule name:(NSString *)name {
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
                    __RFAPIDefineConfigFileEnumCase(offlinePolicy, RFAPIOfflinePolicyDefault)
                    __RFAPIDefineConfigFileEnumCase(offlinePolicy, RFAPIOfflinePolicyLoadCache)
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
