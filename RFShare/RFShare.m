
#import "RFShare.h"
#import "NSURL+RFKit.h"
#import "RFShareAuthorizeWebViewController.h"
#import "NSJSONSerialization+RFKit.h"

#define DebugRFShareSkipOAuth 0
#define DebugClearKeychainDuringInitialize 0
#define DebugRFShareTestOAuthAuthorizeCode nil

NSString *const RFShareKeychainServiceName = @"com.github.RFUI.RFShare.weibo";

@interface RFShare ()
<RFShareAuthorizeWebViewControllerDelegate>
@property (strong, nonatomic) AFHTTPClient *httpClient;
@property (readwrite, copy, nonatomic) NSString *accessToken;
@property (readwrite, copy, nonatomic) NSString *authorizeCode;

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

#pragma mark -
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
        [self.httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
        self.httpClient.parameterEncoding = AFJSONParameterEncoding;
        if (DebugClearKeychainDuringInitialize) {
            [SSKeychain deletePasswordForService:RFShareKeychainServiceName account:[NSBundle mainBundle].bundleIdentifier];
        }
        [self loadSecret];
    }
    return self;
}

- (void)test {
    self.redirectURI = @"https://github.com/bb9z";
    self.clientID = @"3215399857";
    self.clientSecret = @"7312fbb6da68c764d477d48faecd8c8d";
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"button" ofType:@"png"];
    douto(path)
    NSData *date = [NSData dataWithContentsOfFile:path];
    dout_int(date.length)

    if (!self.authorizeCode) {
        [self presentDefaultAuthorizeWebViewController];
        return;
    }
    
    if (!self.accessToken) {
        [self requestAccessToken];
        return;
    }

//    self.accessToken = @"2.00TeyXACB5UbVDbe5dc2bbf1LzSxjD";
    douto(self.accessToken)

    [self comment:@"Weibo API 测试" image:[UIImage imageNamed:@"button"]];
}

- (void)comment:(NSString *)commentString image:(UIImage *)image {
    if (image) {

        
        NSMutableURLRequest *request = [self.httpClient multipartFormRequestWithMethod:@"POST" path:@"https://upload.api.weibo.com/2/statuses/upload.json" parameters:@{
            @"access_token" : [self.accessToken dataUsingEncoding:NSUTF8StringEncoding],
            @"status" : [commentString dataUsingEncoding:NSUTF8StringEncoding] } constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
                NSData *data = UIImageJPEGRepresentation(image, 0.5);
                
                dout_int(data.length)
                [formData appendPartWithFileData:data name:@"pic" fileName:@"tt.png" mimeType:@"image/jpeg"];
        }];
        
        AFHTTPRequestOperation *r = [self.httpClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        }];
        
        [r setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
        }];
        [self.httpClient enqueueHTTPRequestOperation:r];
    }
    else {
        [self.httpClient postPath:@"2/statuses/update.json" parameters:@{ @"access_token" : self.accessToken, @"status" : commentString  } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            douto(operation.responseString)
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSDictionary *apiErrorInfo = [NSJSONSerialization JSONObjectWithString:error.localizedRecoverySuggestion];
            if ([apiErrorInfo[@"error_code"] intValue] == 20019) {
                dout_warning(@"发送重复微博")
                return;
            }
            douto(error)
        }];
    }
}

#pragma mark - Access token
- (void)requestAccessToken {
    [self.httpClient postPath:@"oauth2/access_token" parameters:@{
     @"client_id" : self.clientID,
     @"client_secret" : self.clientSecret,
     @"grant_type" : @"authorization_code",
     @"code" : self.authorizeCode,
     @"redirect_uri" : self.redirectURI
     } success:^(AFHTTPRequestOperation *operation, id responseObject) {
         douto(operation.responseString)
         douto(responseObject)
         NSDictionary *info = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
         self.accessToken = info[@"access_token"];
         self.accessExpires = [NSDate dateWithTimeIntervalSinceNow:([info[@"expires_in"] intValue]/1000)];
         douto(self.accessExpires)
         [self saveSecret];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         douto(error)
     }];
}

#pragma mark - Authorize
- (NSString *)authorizeCode {
    if (!_authorizeCode) {
        _authorizeCode = DebugRFShareTestOAuthAuthorizeCode;
        NSError __autoreleasing *e = nil;
        self.accessToken = [SSKeychain passwordForService:RFShareKeychainServiceName account:[NSBundle mainBundle].bundleIdentifier error:&e];
        if (e) dout_error(@"%@", e);
    }
    return _authorizeCode;
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
        self.authorizeCode = [request.URL queryDictionary][@"code"];
        douto(self.authorizeCode)
        
        [controller.webView loadHTMLString:@"验证成功..." baseURL:nil];
        [self.authorizePresentedViewController dismissModalViewControllerAnimated:YES];
        return NO;
    }
    return YES;
}

#pragma mark - Secret staues
- (void)saveSecret {
    SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
    query.service = RFShareKeychainServiceName;
    query.account = [NSBundle mainBundle].bundleIdentifier;
    query.passwordObject = @{
        @"Authorize Code" : (self.authorizeCode)?: [NSNull null],
        @"Access Token" : (self.accessToken)?: [NSNull null],
        @"Access Expires" : (self.accessExpires)?: [NSNull null]
     };
    NSError __autoreleasing *e = nil;
    [query save:&e];
    if (e) dout_error(@"%@", e);
}

- (void)loadSecret {
    SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
    query.service = RFShareKeychainServiceName;
    query.account = [NSBundle mainBundle].bundleIdentifier;
    NSError __autoreleasing *e = nil;
    [query fetch:&e];
    if (e) dout_error(@"%@", e);
    douto(query.passwordObject)
    NSDictionary *secInfo = (NSDictionary *)query.passwordObject;
    self.authorizeCode = secInfo[@"Authorize Code"];
    self.accessToken = secInfo[@"Access Token"];
    self.accessExpires = secInfo[@"Access Expires"];
}

@end
