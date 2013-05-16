
#import "RFShareAuthorizeWebViewController.h"
#import "UIAlertView+RFKit.h"

@interface RFShareAuthorizeWebViewController ()
@end

@implementation RFShareAuthorizeWebViewController

- (void)RFSegueWillReturn:(id)sender {
    [self.webView loadHTMLString:nil baseURL:nil];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([self.delegate respondsToSelector:@selector(RFShareAuthorizeWebViewController:shouldLoadWithRequest:)]) {
        return [self.delegate RFShareAuthorizeWebViewController:self shouldLoadWithRequest:request];
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.loadIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.loadIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.loadIndicator stopAnimating];
    
    [UIAlertView showWithTitle:@"载入错误" message:[error localizedDescription] buttonTitle:nil];
}

@end
