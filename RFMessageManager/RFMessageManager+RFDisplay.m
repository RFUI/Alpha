
#import "RFMessageManager+RFDisplay.h"
#import "dout.h"

@implementation RFMessageManager (RFDisplay)

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
    dout_error(@"Error: %@ (%d), URL:%@", error.domain, (int)error.code, error.userInfo[NSURLErrorFailingURLErrorKey]);
#endif

    [self showWithTitle:title?: @"不能完成请求" message:message status:RFNetworkActivityIndicatorStatusFail modal:NO priority:RFNetworkActivityIndicatorMessagePriorityHigh autoHideAfterTimeInterval:0 identifier:nil groupIdentifier:nil userInfo:nil];
}

- (void)showWithTitle:(NSString *)title message:(NSString *)message status:(RFNetworkActivityIndicatorStatus)status modal:(BOOL)modal priority:(RFNetworkActivityIndicatorMessagePriority)priority autoHideAfterTimeInterval:(NSTimeInterval)timeInterval identifier:(NSString *)identifier groupIdentifier:(NSString *)groupIdentifier userInfo:(NSDictionary *)userInfo {
    RFNetworkActivityIndicatorMessage *obj = [[RFNetworkActivityIndicatorMessage alloc] initWithIdentifier:identifier?: @"" title:title message:message status:status];
    obj.priority = priority;
    obj.groupIdentifier = groupIdentifier? : @"";
    obj.modal = modal;
    obj.userInfo = userInfo;
    obj.displayTimeInterval = timeInterval;

    [self showMessage:obj];
}

- (void)showProgress:(float)progress title:(NSString *)title message:(NSString *)message status:(RFNetworkActivityIndicatorStatus)status modal:(BOOL)modal identifier:(NSString *)identifier userInfo:(NSDictionary *)userInfo {
    RFNetworkActivityIndicatorMessage *obj = [[RFNetworkActivityIndicatorMessage alloc] initWithIdentifier:identifier?: @"" title:title message:message status:status];
    obj.modal = modal;
    obj.progress = progress;
    obj.userInfo = userInfo;
    [self showMessage:obj];
}

- (void)alertErrorWithMessage:(NSString *)message {
    [self showWithTitle:nil message:message status:RFNetworkActivityIndicatorStatusFail modal:NO priority:RFNetworkActivityIndicatorMessagePriorityHigh autoHideAfterTimeInterval:0 identifier:nil groupIdentifier:nil userInfo:nil];
}

@end
