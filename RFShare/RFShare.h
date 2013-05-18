// Pre TEST

#import "RFKit.h"
#import "AFNetworking.h"
#import "SSKeychain.h"

@interface RFShare : NSObject
<UIWebViewDelegate>

+ (instancetype)sharedInstance;

@property (copy, nonatomic) NSString *redirectURI;
@property (copy, nonatomic) NSString *clientID;
@property (readonly, copy, nonatomic) NSString *accessToken;
@property (readonly, copy, nonatomic) NSString *authorizeCode;
@property (copy, nonatomic) NSString *clientSecret;
@property (strong, nonatomic) NSDate *accessExpires;

- (void)test;

@property (weak, nonatomic) UIViewController *authorizePresentedViewController;

- (void)presentDefaultAuthorizeWebViewController;

@end
