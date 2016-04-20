
#import "RFAPIDefine.h"
#import "dout.h"

@implementation RFAPIDefine

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, name = %@, path = %@>", self.class, (void *)self, self.name, self.path];
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
            "\t responseAcceptNull = %@,\n"
            "\t responseClass = %@,\n"
            "\t userInfo = %@\n"
            "\t notes = %@\n"
            ">", self.class, (void *)self, self.name,
            self.baseURL, self.pathPrefix, self.path, self.method,
            self.HTTPRequestHeaders, self.defaultParameters, @(self.needsAuthorization),
            self.responseSerializerClass,
            self.cachePolicy, self.expire, self.offlinePolicy,
            self.responseSerializerClass, @(self.responseExpectType), @(self.responseAcceptNull), self.responseClass,
            self.userInfo, self.notes];
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

#pragma mark - NSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (!self) {
        return nil;
    }

    self.name = [decoder decodeObjectOfClass:[NSString class] forKey:@keypath(self, name)];
    self.baseURL = [decoder decodeObjectOfClass:[NSURL class] forKey:@keypath(self, baseURL)];
    self.pathPrefix = [decoder decodeObjectOfClass:[NSString class] forKey:@keypath(self, pathPrefix)];
    self.path = [decoder decodeObjectOfClass:[NSString class] forKey:@keypath(self, path)];
    self.method = [decoder decodeObjectOfClass:[NSString class] forKey:@keypath(self, method)];
    self.HTTPRequestHeaders = [decoder decodeObjectOfClass:[NSDictionary class] forKey:@keypath(self, HTTPRequestHeaders)];
    self.defaultParameters = [decoder decodeObjectOfClass:[NSDictionary class] forKey:@keypath(self, defaultParameters)];
    self.needsAuthorization = [[decoder decodeObjectOfClass:[NSNumber class] forKey:@keypath(self, needsAuthorization)] boolValue];
    self.requestSerializerClass = NSClassFromString((id)[decoder decodeObjectOfClass:[NSString class] forKey:@keypath(self, requestSerializerClass)]);
    self.cachePolicy = [[decoder decodeObjectOfClass:[NSNumber class] forKey:@keypath(self, cachePolicy)] shortValue];
    self.expire = [[decoder decodeObjectOfClass:[NSNumber class] forKey:@keypath(self, expire)] doubleValue];
    self.offlinePolicy = [[decoder decodeObjectOfClass:[NSNumber class] forKey:@keypath(self, offlinePolicy)] shortValue];
    self.responseSerializerClass = NSClassFromString((id)[decoder decodeObjectOfClass:[NSString class] forKey:@keypath(self, responseSerializerClass)]);
    self.responseExpectType = [[decoder decodeObjectOfClass:[NSNumber class] forKey:@keypath(self, responseExpectType)] shortValue];
    self.responseAcceptNull = [[decoder decodeObjectOfClass:[NSNumber class] forKey:@keypath(self, responseExpectType)] boolValue];
    self.responseClass = NSClassFromString((id)[decoder decodeObjectOfClass:[NSString class] forKey:@keypath(self, responseClass)]);
    self.userInfo = [decoder decodeObjectOfClass:[NSDictionary class] forKey:@keypath(self, userInfo)];
    self.notes = [decoder decodeObjectOfClass:[NSString class] forKey:@keypath(self, notes)];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@keypath(self, name)];
    [aCoder encodeObject:self.baseURL forKey:@keypath(self, baseURL)];
    [aCoder encodeObject:self.pathPrefix forKey:@keypath(self, pathPrefix)];
    [aCoder encodeObject:self.path forKey:@keypath(self, path)];
    [aCoder encodeObject:self.method forKey:@keypath(self, method)];
    [aCoder encodeObject:self.HTTPRequestHeaders forKey:@keypath(self, HTTPRequestHeaders)];
    [aCoder encodeObject:self.defaultParameters forKey:@keypath(self, defaultParameters)];
    [aCoder encodeObject:@(self.needsAuthorization) forKey:@keypath(self, needsAuthorization)];
    [aCoder encodeObject:NSStringFromClass(self.requestSerializerClass) forKey:@keypath(self, requestSerializerClass)];
    [aCoder encodeObject:@(self.cachePolicy) forKey:@keypath(self, cachePolicy)];
    [aCoder encodeObject:@(self.expire) forKey:@keypath(self, expire)];
    [aCoder encodeObject:@(self.offlinePolicy) forKey:@keypath(self, offlinePolicy)];
    [aCoder encodeObject:NSStringFromClass(self.responseSerializerClass) forKey:@keypath(self, responseSerializerClass)];
    [aCoder encodeObject:@(self.responseExpectType) forKey:@keypath(self, responseExpectType)];
    [aCoder encodeObject:@(self.responseAcceptNull) forKey:@keypath(self, responseAcceptNull)];
    [aCoder encodeObject:NSStringFromClass(self.responseClass) forKey:@keypath(self, responseClass)];
    [aCoder encodeObject:self.userInfo forKey:@keypath(self, userInfo)];
    [aCoder encodeObject:self.notes forKey:@keypath(self, notes)];
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
    clone.responseAcceptNull = self.responseAcceptNull;
    clone.responseClass = self.responseClass;

    clone.userInfo = self.userInfo;
    clone.notes = self.notes;
    
    return clone;
}

@end
