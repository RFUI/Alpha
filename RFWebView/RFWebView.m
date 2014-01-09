
#import "RFWebView.h"
#import "UIWebView+RFKit.h"

@interface RFWebView ()
@end

@implementation RFWebView
RFInitializingRootForUIView

- (void)onInit {
    self.delegate = self;
    self.backgroundColor = [UIColor clearColor];
    [self clearBackgroundImages];
}

- (void)afterInit {
    self.userInteractionEnabled = NO;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(self.bounds.size.width, self.scrollView.contentSize.height);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self invalidateIntrinsicContentSize];
}

@end
