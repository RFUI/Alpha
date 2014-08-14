
#import "RFSVProgressMessageManager.h"
#import "SVProgressHUD.h"
#import "dout.h"

@interface RFSVProgressMessageManager ()
@property (strong, nonatomic) id dismissObserver;
@end

@implementation RFSVProgressMessageManager

- (void)dealloc {
    [self deactiveAutoDismissObserver];
}

- (void)replaceMessage:(RFNetworkActivityIndicatorMessage *)displayingMessage withNewMessage:(RFNetworkActivityIndicatorMessage *)message {
    _dout_info(@"Replace message %@ with %@", displayingMessage, message)
    [super replaceMessage:displayingMessage withNewMessage:message];

    if (!message) {
        [SVProgressHUD dismiss];
        return;
    }

    NSString *stautsString = (message.title.length && message.message.length)? [NSString stringWithFormat:@"%@: %@", message.title, message.message] : [NSString stringWithFormat:@"%@%@", message.title?: @"", message.message?: @""];

    SVProgressHUDMaskType maskType = message.modal? SVProgressHUDMaskTypeGradient : SVProgressHUDMaskTypeNone;
    switch (message.status) {
        case RFNetworkActivityIndicatorStatusSuccess: {
            [self activeAutoDismissObserver];
            [SVProgressHUD showSuccessWithStatus:stautsString];
            break;
        }

        case RFNetworkActivityIndicatorStatusFail: {
            [self activeAutoDismissObserver];
            [SVProgressHUD showErrorWithStatus:stautsString];
            break;
        }
        case RFNetworkActivityIndicatorStatusDownloading:
        case RFNetworkActivityIndicatorStatusUploading: {
            [self deactiveAutoDismissObserver];
            [SVProgressHUD showProgress:message.progress status:stautsString maskType:maskType];
        }
        default: {
            if (stautsString.length) {
                [SVProgressHUD showWithStatus:stautsString maskType:maskType];
            }
            else {
                [SVProgressHUD showWithMaskType:maskType];
            }
        }
    }

    _dout_info(@"After replacing, self = %@", self);
}

- (void)activeAutoDismissObserver {
    if (self.dismissObserver) return;

    @weakify(self);
    self.dismissObserver = [[NSNotificationCenter defaultCenter] addObserverForName:SVProgressHUDWillDisappearNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        @strongify(self);
        _dout_info(@"Receive SVProgressHUDWillDisappearNotification")
        if (self.displayingMessage) {
            RFAssert(self.displayingMessage.identifier, @"empty string");
            [self hideWithIdentifier:self.displayingMessage.identifier];
        }
    }];
}

- (void)deactiveAutoDismissObserver {
    if (self.dismissObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.dismissObserver];
        self.dismissObserver = nil;
    }
}

@end
