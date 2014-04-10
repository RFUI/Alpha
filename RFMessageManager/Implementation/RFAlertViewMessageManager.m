
#import "RFAlertViewMessageManager.h"
#import "UIAlertView+RFKit.h"

@implementation RFAlertViewMessageManager

- (void)replaceMessage:(RFNetworkActivityIndicatorMessage *)displayingMessage withNewMessage:(RFNetworkActivityIndicatorMessage *)message {
    [super replaceMessage:displayingMessage withNewMessage:message];

    if (message.status == RFNetworkActivityIndicatorStatusFail) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message.title message:message.message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self hideWithIdentifier:self.displayingMessage.identifier];
}

@end
