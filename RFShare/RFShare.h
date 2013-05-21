// Pre TEST

#import "RFKit.h"
#import "RFShareAuthorizeWebViewController.h"

@interface RFShareClient : NSObject
<RFShareAuthorizeWebViewControllerDelegate>

@property (readonly, copy, nonatomic) NSString *clientID;
@property (readonly, copy, nonatomic) NSString *clientSecret;
@property (readonly, copy, nonatomic) NSString *redirectURI;

- (id)initWithClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret redirectURI:(NSString *)redirectURI;

#pragma mark - Authorize
@property (readonly, assign, nonatomic, getter = isAuthorized) BOOL authorized;

// For overwrite
- (void)requestAuthorize;

// For overwrite
- (void)onReceivedAuthorizeRequest:(NSURLRequest *)request;


@property (readonly, copy, nonatomic) NSString *authorizedCode;
@property (weak, nonatomic) UIViewController *authorizePresentedViewController;

#pragma mark - Token
@property (readonly, copy, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSDate *accessExpires;

- (void)requestAccessToken;

#pragma mark -
- (BOOL)saveSecretInfo:(NSDictionary<NSSecureCoding> *)info forService:(NSString *)serviceName account:(NSString *)account;
- (NSDictionary *)loadSecretInfoWithService:(NSString *)serviceName account:(NSString *)account;

@end
