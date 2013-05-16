
#import "RFShare.h"
#import "NSURL+RFKit.h"
#import "RFShareAuthorizeWebViewController.h"

@interface RFShare ()
<RFShareAuthorizeWebViewControllerDelegate>
@property (strong, nonatomic) AFHTTPClient *httpClient;
@property (readwrite, copy, nonatomic) NSString *accessToken;
@end

@implementation RFShare

- (UIViewController *)authorizePresentedViewController {
    if (!_authorizePresentedViewController) {
        UIViewController *vc = ([UIApplication sharedApplication].keyWindow.rootViewController)? : [(UIWindow *)[[UIApplication sharedApplication].windows firstObject] rootViewController];
        
        while (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }
        
        _authorizePresentedViewController = vc;
    }
    return _authorizePresentedViewController;
}

+ (instancetype)sharedInstance {
	static RFShare *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
	return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.weibo.com/"]];
    }
    return self;
}

- (void)test {
    self.redirectURI = @"https://github.com/bb9z";
    self.clientID = @"3215399857";
    self.clientSecret = @"7312fbb6da68c764d477d48faecd8c8d";
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self presentDefaultAuthorizeWebViewController];
    });
}

- (void)presentDefaultAuthorizeWebViewController {
    RFShareAuthorizeWebViewController *vc = [[RFShareAuthorizeWebViewController alloc] init];
    vc.delegate = self;
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.authorizePresentedViewController presentViewController:vc animated:YES completion:^{
        [vc.webView loadRequest:[self.httpClient requestWithMethod:@"POST" path:@"oauth2/authorize" parameters:@{
            @"client_id" : self.clientID,
            @"redirect_uri" : self.redirectURI,
            @"scope" : @"email, follow_app_official_microblog",
            @"display" : @"mobile"
        }]];
    }];
}

- (BOOL)RFShareAuthorizeWebViewController:(RFShareAuthorizeWebViewController *)controller shouldLoadWithRequest:(NSURLRequest *)request {

    if ([request.URL.absoluteString hasPrefix:self.redirectURI]) {
        self.accessToken = [request.URL queryDictionary][@"code"];
        [controller.webView loadHTMLString:@"验证成功..." baseURL:nil];
        [self.authorizePresentedViewController dismissModalViewControllerAnimated:YES];
        return NO;
    }    
    return YES;
}

@end
