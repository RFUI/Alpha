
#import "RFNetworkSVProgressHUDActivityIndicator.h"
#import "SVProgressHUD.h"

@interface RFNetworkSVProgressHUDActivityIndicator ()
@property (strong, nonatomic) id dismissObserver;
@end

@implementation RFNetworkSVProgressHUDActivityIndicator

- (void)afterInit {
    [super afterInit];

    @weakify(self);
    self.dismissObserver = [[NSNotificationCenter defaultCenter] addObserverForName:SVProgressHUDWillDisappearNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        @strongify(self);
        [self hideDisplayingMessage];
    }];
}

- (void)replaceMessage:(RFNetworkActivityIndicatorMessage *)displayingMessage withNewMessage:(RFNetworkActivityIndicatorMessage *)message {
    if (!message) {
        [SVProgressHUD dismiss];
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
}

@end
