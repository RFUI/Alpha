
#import "RFShareSinaWeiboClient.h"
#import "SSKeychain.h"
#import "NSJSONSerialization+RFKit.h"
#import "NSURL+RFKit.h"
#import "AFNetworking.h"

NSString *const RFShareSinaWeiboClientKeychainServiceName = @"com.github.RFUI.RFShare.weibo";

#define DebugRFShareSkipOAuth 0
#define DebugClearKeychainDuringInitialize 0

@interface RFShareSinaWeiboClient ()
@property (strong, nonatomic) AFHTTPClient *httpClient;
@end

@implementation RFShareSinaWeiboClient

- (id)initWithClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret redirectURI:(NSString *)redirectURI {
    self = [super initWithClientID:clientID clientSecret:clientSecret redirectURI:redirectURI];
    if (self) {
        self.httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.weibo.com/"]];
        [self loadSecret];
    }
    return self;
}

- (void)dealloc {
    doutwork()
}

#pragma mark - Authorize
- (void)requestAuthorize {
    if (!self.isAuthorized) {
        [self presentDefaultAuthorizeWebViewController];
    }
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

- (void)onReceivedAuthorizeRequest:(NSURLRequest *)request {
    self.authorizedCode = [request.URL queryDictionary][@"code"];
    douto(self.authorizedCode)
    
    if (!self.accessToken) {
        [self requestAccessToken];
    }
}

#pragma mark - Access token
- (void)requestAccessToken {
    [self.httpClient postPath:@"oauth2/access_token" parameters:@{
         @"client_id" : self.clientID,
         @"client_secret" : self.clientSecret,
         @"grant_type" : @"authorization_code",
         @"code" : self.authorizedCode,
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

#pragma mark -
- (void)postStatus:(NSString *)statusString image:(UIImage *)image {
    if (image) {
        NSMutableURLRequest *request = [self.httpClient multipartFormRequestWithMethod:@"POST" path:@"https://upload.api.weibo.com/2/statuses/upload.json" parameters:@{
            @"access_token" : [self.accessToken dataUsingEncoding:NSUTF8StringEncoding],
            @"status" : [statusString dataUsingEncoding:NSUTF8StringEncoding] } constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
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
        [self.httpClient postPath:@"2/statuses/update.json" parameters:@{ @"access_token" : self.accessToken, @"status" : statusString  } success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

#pragma mark - Secret staues
- (void)saveSecret {
    [self saveSecretInfo:@{
         @"Authorize Code" : (self.authorizedCode)?: [NSNull null],
         @"Access Token" : (self.accessToken)?: [NSNull null],
         @"Access Expires" : (self.accessExpires)?: [NSNull null]
     } forService:RFShareSinaWeiboClientKeychainServiceName account:[NSBundle mainBundle].bundleIdentifier];
}

- (void)loadSecret {
    NSDictionary *secInfo = [self loadSecretInfoWithService:RFShareSinaWeiboClientKeychainServiceName account:[NSBundle mainBundle].bundleIdentifier];
    self.authorizedCode = secInfo[@"Authorize Code"];
    self.accessToken = secInfo[@"Access Token"];
    self.accessExpires = secInfo[@"Access Expires"];
}

@end
