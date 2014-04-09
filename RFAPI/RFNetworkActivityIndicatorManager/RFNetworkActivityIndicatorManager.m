
#import "RFNetworkActivityIndicatorManager.h"

@interface RFNetworkActivityIndicatorManager ()
@property (strong, nonatomic) NSMutableDictionary *messages;
@property (copy, nonatomic) NSString *displayingIdentifier;
@end

@implementation RFNetworkActivityIndicatorManager

- (void)onInit {
    self.messages = [NSMutableDictionary dictionary];
}

- (void)afterInit {
}

- (void)alertError:(NSError *)error title:(NSString *)title {
    NSMutableString *message = [NSMutableString string];
    if (error.localizedDescription) {
        [message appendFormat:@"%@\n", error.localizedDescription];
    }
    if (error.localizedFailureReason) {
        [message appendFormat:@"%@\n", error.localizedFailureReason];
    }
    if (error.localizedRecoverySuggestion) {
        [message appendFormat:@"%@\n", error.localizedRecoverySuggestion];
    }
#if RFDEBUG
    dout_error(@"Error: %@ (%d), URL:%@", error.domain, error.code, error.userInfo[NSURLErrorFailingURLErrorKey]);
#endif

    [self showWithTitle:title?: @"不能完成请求" message:message status:RFNetworkActivityIndicatorStatusFail modal:NO autoHideAfterTimeInterval:0 identifier:nil userinfo:nil];
}


- (void)showWithTitle:(NSString *)title message:(NSString *)message status:(RFNetworkActivityIndicatorStatus)status modal:(BOOL)modal autoHideAfterTimeInterval:(NSTimeInterval)timeInterval identifier:(NSString *)identifier userinfo:(NSDictionary *)userinfo {

}

- (void)showProgress:(float)progress title:(NSString *)title message:(NSString *)message status:(RFNetworkActivityIndicatorStatus)status modal:(BOOL)modal identifier:(NSString *)identifier userinfo:(NSDictionary *)userinfo {
}

- (void)hideWithIdentifier:(NSString *)identifier {

}

#pragma mark - For overwrite
- (void)showMessage:(RFNetworkActivityIndicatorMessage *)message {

}

- (void)hideMessage:(RFNetworkActivityIndicatorMessage *)message {

}


@end

@implementation RFNetworkActivityIndicatorMessage

@end