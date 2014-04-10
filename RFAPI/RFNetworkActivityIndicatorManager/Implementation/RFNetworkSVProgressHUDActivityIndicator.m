
#import "RFNetworkSVProgressHUDActivityIndicator.h"
#import "SVProgressHUD.h"

@interface RFNetworkSVProgressHUDActivityIndicator ()
@property (strong, nonatomic) id dismissObserver;

- (RFNetworkActivityIndicatorMessage *)popNextMessageToDisplay;
@end

@implementation RFNetworkSVProgressHUDActivityIndicator

- (void)afterInit {
    [super afterInit];

    @weakify(self);
    self.dismissObserver = [[NSNotificationCenter defaultCenter] addObserverForName:SVProgressHUDWillDisappearNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        @strongify(self);
        doutwork()
        if (self.popNextMessageToDisplay && self.displayingMessage) {
            RFAssert(self.displayingMessage.identifier, @"empty string");
            [self hideWithIdentifier:self.displayingMessage.identifier];
        }
    }];
}

- (void)dealloc {
    self.dismissObserver = nil;
}

- (void)replaceMessage:(RFNetworkActivityIndicatorMessage *)displayingMessage withNewMessage:(RFNetworkActivityIndicatorMessage *)message {
    [super replaceMessage:displayingMessage withNewMessage:message];

    if (!message) {
        [SVProgressHUD dismiss];
        douts(([NSString stringWithFormat:@"After replace : %@", self]))
        return;
    }

    NSString *stautsString = message.title? [NSString stringWithFormat:@"%@: %@", message.title, message.message] : message.message;

    SVProgressHUDMaskType maskType = message.modal? SVProgressHUDMaskTypeGradient : SVProgressHUDMaskTypeNone;
    switch (message.status) {
        case RFNetworkActivityIndicatorStatusSuccess: {
            [SVProgressHUD showSuccessWithStatus:stautsString];
            break;
        }

        case RFNetworkActivityIndicatorStatusFail: {
            [SVProgressHUD showErrorWithStatus:stautsString];
            break;
        }
        case RFNetworkActivityIndicatorStatusDownloading:
        case RFNetworkActivityIndicatorStatusUploading: {
            [SVProgressHUD showProgress:message.progress status:stautsString maskType:maskType];
        }
        default: {
            [SVProgressHUD showWithStatus:stautsString maskType:maskType];
        }
    }
    douts(([NSString stringWithFormat:@"After replace : %@", self]))
}

@end
