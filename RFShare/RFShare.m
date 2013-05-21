
#import "RFShare.h"
#import "NSURL+RFKit.h"
#import "NSJSONSerialization+RFKit.h"
#import "SSKeychain.h"
#import "UIViewController+RFKit.h"

NSString *const RFShareKeychainServiceName = @"com.github.RFUI.RFShare.weibo";

@interface RFShareClient ()
@property (readwrite, copy, nonatomic) NSString *clientID;
@property (readwrite, copy, nonatomic) NSString *clientSecret;
@property (readwrite, copy, nonatomic) NSString *redirectURI;

@end

@implementation RFShareClient
#pragma mark - init overwrite
- (id)init {
    RFAssert(false, @"Please call initWithClientID:clientSecret:redirectURI: instead.");
    return nil;
}

- (id)initWithClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret redirectURI:(NSString *)redirectURI {
    self = [super init];
    if (self) {
        self.clientID = clientID;
        self.clientSecret = clientSecret;
        self.redirectURI = redirectURI;
    }
    return nil;
}

#pragma mark - Authorize
- (BOOL)isAuthorized {
    return self.authorizedCode.length > 0;
}

+ (NSSet *)keyPathsForValuesAffectingAuthorized {
    return [NSSet setWithObject:@keypathClassInstance(RFShareClient, authorizedCode)];
}

- (UIViewController *)authorizePresentedViewController {
    if (!_authorizePresentedViewController) {        
        _authorizePresentedViewController = [UIViewController rootViewControllerWhichCanPresentModalViewController];
    }
    return _authorizePresentedViewController;
}

- (void)requestAuthorize {
    // For overwrite
}

- (BOOL)RFShareAuthorizeWebViewController:(RFShareAuthorizeWebViewController *)controller shouldLoadWithRequest:(NSURLRequest *)request {
    if ([request.URL.absoluteString hasPrefix:self.redirectURI]) {
        [self onReceivedAuthorizeRequest:request];
        [controller.webView loadHTMLString:@"验证成功..." baseURL:nil];
        [self.authorizePresentedViewController dismissModalViewControllerAnimated:YES];
        return NO;
    }
    return YES;
}

- (void)onReceivedAuthorizeRequest:(NSURLRequest *)request {
    // For overwrite
}

#pragma mark - Token
- (void)requestAccessToken {
    // For overwrite
}

#pragma mark - Secret staues
- (BOOL)saveSecretInfo:(NSDictionary<NSSecureCoding> *)info forService:(NSString *)serviceName account:(NSString *)account {
    SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
    query.service = serviceName;
    query.account = account;
    query.passwordObject = info;
    NSError __autoreleasing *e = nil;
    BOOL status = [query save:&e];
    if (e) dout_error(@"%@", e);
    return status;
}

- (NSDictionary *)loadSecretInfoWithService:(NSString *)serviceName account:(NSString *)account {
    SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
    query.service = serviceName;
    query.account = account;
    NSError __autoreleasing *e = nil;
    [query fetch:&e];
    if (e) dout_error(@"%@", e);
    douto(query.passwordObject)
    return (NSDictionary *)query.passwordObject;
}

@end
