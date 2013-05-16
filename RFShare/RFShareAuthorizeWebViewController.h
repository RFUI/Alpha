// Pre test

#import <UIKit/UIKit.h>
#import "RFDismissModalBarButtonItem.h"

@protocol RFShareAuthorizeWebViewControllerDelegate;

@interface RFShareAuthorizeWebViewController : UIViewController
<RFSegueReturnDelegate, UIWebViewDelegate>

@property (weak, nonatomic) id<RFShareAuthorizeWebViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadIndicator;
@end

@protocol RFShareAuthorizeWebViewControllerDelegate <NSObject>
- (BOOL)RFShareAuthorizeWebViewController:(RFShareAuthorizeWebViewController *)controller shouldLoadWithRequest:(NSURLRequest *)request;
@end
