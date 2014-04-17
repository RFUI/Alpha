
#import "RFAPIDefine.h"

@implementation RFAPIDefine

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, name = %@, path = %@>", self.class, self, self.name, self.path];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    RFAPIDefine *clone = [(RFAPIDefine *)[self.class allocWithZone:zone] init];

    clone.name = self.name;

    clone.baseURL = self.baseURL;
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
    clone.responseList = self.responseList;
    clone.responseClass = self.responseClass;

    clone.userInfo = self.userInfo;

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
