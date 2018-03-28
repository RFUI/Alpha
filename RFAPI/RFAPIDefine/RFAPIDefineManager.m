
#import "RFAPIDefineManager.h"
#import "RFAPI.h"
#import "RFAPIDefineConfigFileKeys.h"

#import "AFURLRequestSerialization.h"
#import "AFURLResponseSerialization.h"

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
    NSMutableDictionary *rule = [self.rawRules[defineName] mutableCopy];
    [rule rf_setObject:value forKey:key];
    self.rawRules[defineName] = rule;
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
            NSString *encodedParameter = [[parameter description] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
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
    
    if (parameters[RFAPIRequestForceQuryStringParametersKey]) {
        NSDictionary *forceQuryStringParameters = parameters[RFAPIRequestForceQuryStringParametersKey];
        [parameters removeObjectForKey:RFAPIRequestForceQuryStringParametersKey];
        NSMutableArray *queryStringPair = [NSMutableArray array];
        for (NSString *key in forceQuryStringParameters.allKeys) {
            [queryStringPair addObject:[NSString stringWithFormat:@"%@=%@", key, forceQuryStringParameters[key]]];
        }
        NSString *query = [queryStringPair componentsJoinedByString:@"&"];
        url = [NSURL URLWithString:[url.absoluteString stringByAppendingFormat:url.query.length ? @"&%@" : @"?%@", query]];
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

#define RFAPIDefineConfigFileValue_(KEY)\
    value = nil;\
    if ((value = rule[KEY]))

#define RFAPIDefineConfigFileProperty_(PROPERTY, KEY)\
    RFAPIDefineConfigFileValue_(KEY) {\
        self.PROPERTY = value;\
    }

#define RFAPIDefineConfigFileDictionaryProperty_(PROPERTY, KEY)\
    RFAPIDefineConfigFileValue_(KEY) {\
        if (![value isKindOfClass:[NSDictionary class]]) {\
            dout_error(@"%@ must be a dictionary.", KEY);\
            return nil;\
        }\
        self.PROPERTY = value;\
    }

#define RFAPIDefineConfigFileClassProperty_(PROPERTY, KEY)\
    RFAPIDefineConfigFileValue_(KEY) {\
        Class aClass = NSClassFromString(value);\
        if (aClass) {\
            self.PROPERTY = aClass;\
        }\
        else {\
            dout_warning(@"Can not get class from name: %@", value);\
        }\
    }

#define RFAPIDefineConfigFileEnumCase_(PROPERTY, ENUM)\
    case ENUM:\
        self.PROPERTY = ENUM;\
        break;

        RFAPIDefineConfigFileValue_(RFAPIDefineBaseKey) {
            NSURL *url = [NSURL URLWithString:value];
            if (url) {
                self.baseURL = url;
            }
        }

        RFAPIDefineConfigFileProperty_(pathPrefix, RFAPIDefinePathPrefixKey)
        RFAPIDefineConfigFileProperty_(path, RFAPIDefinePathKey)
        RFAPIDefineConfigFileProperty_(method, RFAPIDefineMethodKey)
        RFAPIDefineConfigFileDictionaryProperty_(HTTPRequestHeaders, RFAPIDefineHeadersKey)

        RFAPIDefineConfigFileDictionaryProperty_(defaultParameters, RFAPIDefineParametersKey)

        RFAPIDefineConfigFileValue_(RFAPIDefineAuthorizationKey) {
            self.needsAuthorization = [value boolValue];
        }
        RFAPIDefineConfigFileClassProperty_(requestSerializerClass, RFAPIDefineRequestSerializerKey)

        RFAPIDefineConfigFileValue_(RFAPIDefineCachePolicyKey) {
            switch ([value shortValue]) {
                RFAPIDefineConfigFileEnumCase_(cachePolicy, RFAPICachePolicyDefault)
                RFAPIDefineConfigFileEnumCase_(cachePolicy, RFAPICachePolicyProtocol)
                RFAPIDefineConfigFileEnumCase_(cachePolicy, RFAPICachePolicyAlways)
                RFAPIDefineConfigFileEnumCase_(cachePolicy, RFAPICachePolicyExpire)
                RFAPIDefineConfigFileEnumCase_(cachePolicy, RFAPICachePolicyNoCache)
                default:
                    dout_error(@"Unknow cache policy: %@", value)
                    return nil;
            }
        }

        RFAPIDefineConfigFileValue_(RFAPIDefineExpireKey) {
            self.expire = [value intValue];
        }

        RFAPIDefineConfigFileValue_(RFAPIDefineOfflinePolicyKey) {
            switch ([value shortValue]) {
                    RFAPIDefineConfigFileEnumCase_(offlinePolicy, RFAPIOfflinePolicyDefault)
                    RFAPIDefineConfigFileEnumCase_(offlinePolicy, RFAPIOfflinePolicyLoadCache)
                default:
                    dout_error(@"Unknow offline policy: %@", value)
                    return nil;
            }
        }

        RFAPIDefineConfigFileValue_(RFAPIDefineResponseTypeKey) {
            self.responseExpectType = [value intValue];
        }
        RFAPIDefineConfigFileValue_(RFAPIDefineResponseAcceptNullKey) {
            self.responseAcceptNull = [value boolValue];
        }
        RFAPIDefineConfigFileClassProperty_(responseSerializerClass, RFAPIDefineResponseSerializerKey)

        RFAPIDefineConfigFileClassProperty_(responseClass, RFAPIDefineResponseClassKey)
        RFAPIDefineConfigFileDictionaryProperty_(userInfo, RFAPIDefineUserInfoKey)
        RFAPIDefineConfigFileProperty_(notes, RFAPIDefineNotesKey)

#undef RFAPIDefineConfigFileValue_
#undef RFAPIDefineConfigFileProperty_
#undef RFAPIDefineConfigFileDictionaryProperty_
#undef RFAPIDefineConfigFileClassProperty_
#undef RFAPIDefineConfigFileEnumCase_
    }
    return self;
}

@end
