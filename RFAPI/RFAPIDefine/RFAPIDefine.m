
#import "RFAPIDefine.h"

@implementation RFAPIDefine

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, name = %@, path = %@>", self.class, self, self.name, self.path];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p,\n"
            "\t name = %@,\n"
            "\t baseURL = %@,\n"
            "\t pathPrefix = %@,\n"
            "\t path = %@,\n"
            "\t method = %@,\n"
            "\t HTTPRequestHeaders = %@,\n"
            "\t defaultParameters = %@,\n"
            "\t needsAuthorization = %@,\n"
            "\t requestSerializerClass = %@,\n"
            "\t cachePolicy = %d,\n"
            "\t expire = %f,\n"
            "\t offlinePolicy = %d,\n"
            "\t responseSerializerClass = %@,\n"
            "\t responseExpectType = %@,\n"
            "\t responseClass = %@,\n"
            "\t userInfo = %@\n"
            "\t notes = %@\n"
            ">", self.class, self, self.name,
            self.baseURL, self.pathPrefix, self.path, self.method,
            self.HTTPRequestHeaders, self.defaultParameters, @(self.needsAuthorization),
            self.responseSerializerClass,
            self.cachePolicy, self.expire, self.offlinePolicy,
            self.responseSerializerClass, @(self.responseExpectType), self.responseClass,
            self.userInfo, self.notes];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    RFAPIDefine *clone = [(RFAPIDefine *)[self.class allocWithZone:zone] init];

    clone.name = self.name;

    clone.baseURL = self.baseURL;
    clone.pathPrefix = self.pathPrefix;
    clone.path = self.path;
    clone.method = self.method;
    clone.HTTPRequestHeaders = self.HTTPRequestHeaders;

    clone.defaultParameters = self.defaultParameters;
    clone.needsAuthorization = self.needsAuthorization;
    clone.requestSerializerClass = self.requestSerializerClass;

    clone.cachePolicy = self.cachePolicy;
    clone.expire = self.expire;
    clone.offlinePolicy = self.offlinePolicy;

    clone.responseSerializerClass = self.responseSerializerClass;
    clone.responseExpectType = self.responseExpectType;
    clone.responseClass = self.responseClass;

    clone.userInfo = self.userInfo;
    clone.notes = self.notes;

    return clone;
}

- (void)setBaseURL:(NSURL *)baseURL {
    if (_baseURL != baseURL) {
        // Ensure terminal slash for baseURL path, so that NSURL +URLWithString:relativeToURL: works as expected
        if (baseURL.path.length && ![baseURL.absoluteString hasSuffix:@"/"]) {
            baseURL = [baseURL URLByAppendingPathComponent:@""];
        }

        _baseURL = baseURL;
    }
}

- (void)setMethod:(NSString *)method {
    if (!method) {
        _method = nil;
        return;
    }

    RFAssert(method.length, @"Method can not be empty string.");

    if (_method != method) {
        _method = [method uppercaseString];
    }
}

@end
