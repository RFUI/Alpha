
#import "RFShareRenrenClient.h"
#import "NSURL+RFKit.h"
#import "RFShareAuthorizeWebViewController.h"
#import "NSJSONSerialization+RFKit.h"
#import "AFNetworking.h"

NSString *const RFShareRenrenClientKeychainServiceName = @"com.github.RFUI.RFShare.renren";

@interface RFShareRenrenClient ()
@property (strong, nonatomic) AFHTTPClient *renrenHttpClient;

@end

@implementation RFShareRenrenClient

- (id)initWithClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret redirectURI:(NSString *)redirectURI {
    self = [super initWithClientID:clientID clientSecret:clientSecret redirectURI:redirectURI];
    if (self) {
        self.renrenHttpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.renren.com/"]];
    }
    return self;
}



- (void)postStatus:(NSString *)status withImage:(UIImage *)image {
    if (image) {
        NSMutableURLRequest *request = [self.renrenHttpClient multipartFormRequestWithMethod:@"POST" path:@"restserver.do" parameters:@{
            @"access_token" : self.accessToken,
            @"format" : @"json",
            @"method" : @"photos.upload",
            @"caption" : status,
        } constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
            NSData *data = UIImageJPEGRepresentation(image, 0.5);
            dout_int(data.length)
            [formData appendPartWithFileData:data name:@"upload" fileName:@"upload.png" mimeType:@"image/jpeg"];
        }];
        AFHTTPRequestOperation *r = [self.renrenHttpClient HTTPRequestOperationWithRequest:request
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
               dout(@"上传成功！！！")
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               dout(@"上传失败！！！")
        }];
        [r setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
        }];
        [self.renrenHttpClient enqueueHTTPRequestOperation:r];
    }
    else {
        [self.renrenHttpClient postPath:@"restserver.do" parameters:@{
             @"access_token" : self.accessToken,
             @"format" : @"json",
             @"method" : @"status.set",
             @"status" : status
         } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *info = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            if ([info isKindOfClass:[NSDictionary class]]) {
                if ([[info valueForKey:@"result"] intValue]==1) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发布状态成功" message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
                    [alert show];
                }
            }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发布状态失败" message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
            [alert show];
        }];
    }
}

#pragma mark - Authorize
- (void)requestAuthorize {
    if (!self.isAuthorized) {
        [self presentRenrenAuthorizeWebViewController];
    }
}

- (void)presentRenrenAuthorizeWebViewController {
    RFShareAuthorizeWebViewController *vc = [[RFShareAuthorizeWebViewController alloc] init];
    vc.delegate = self;
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.authorizePresentedViewController presentViewController:vc animated:YES completion:^{
        [vc.webView loadRequest:[self.renrenHttpClient requestWithMethod:@"GET" path:@"https://graph.renren.com/oauth/authorize" parameters:@{
             @"client_id" : self.clientID,
             @"redirect_uri" : self.redirectURI,
             @"response_type" : @"code",
             @"scope":@"status_update photo_upload"
         }]];
    }];
}

- (void)onReceivedAuthorizeRequest:(NSURLRequest *)request {
    self.authorizedCode = [request.URL queryDictionary][@"code"];
    if (self.authorizedCode) {
        dout_error(@"Authorize failed: %@", [request.URL queryDictionary][@"error_description"])
    }
    douto(self.authorizedCode)
    
    if (!self.accessToken) {
        [self requestAccessToken];
    }
}

#pragma mark - Access token
- (void)requestAccessToken {
    [self.renrenHttpClient postPath:@"https://graph.renren.com/oauth/token" parameters:@{
         @"grant_type" : @"authorization_code",
         @"client_id" : self.clientID,
         @"client_secret" : self.clientSecret,
         @"redirect_uri" : self.redirectURI,
         @"code" : self.authorizedCode
     } success:^(AFHTTPRequestOperation *operation, id responseObject) {
         douto(operation.responseString)
         NSDictionary *info = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
         self.accessToken = info[@"access_token"];
         NSLog(@"access_token ===%@",self.accessToken);
         self.accessExpires = [NSDate dateWithTimeIntervalSinceNow:([info[@"expires_in"] intValue])];
         // TODO: refresh_token：用于刷新Access Token 的 Refresh Token，长期有效，不会过期；
         [self saveSecret];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         douto(error)
     }];
}

#pragma mark - Secret staues
- (void)saveSecret {
    [self saveSecretInfo:@{
     @"Authorize Code" : (self.authorizedCode)?: [NSNull null],
     @"Access Token" : (self.accessToken)?: [NSNull null],
     @"Access Expires" : (self.accessExpires)?: [NSNull null]
     } forService:RFShareRenrenClientKeychainServiceName account:[NSBundle mainBundle].bundleIdentifier];
}

- (void)loadSecret {
    NSDictionary *secInfo = [self loadSecretInfoWithService:RFShareRenrenClientKeychainServiceName account:[NSBundle mainBundle].bundleIdentifier];
    self.authorizedCode = secInfo[@"Authorize Code"];
    self.accessToken = secInfo[@"Access Token"];
    self.accessExpires = secInfo[@"Access Expires"];
}

@end
