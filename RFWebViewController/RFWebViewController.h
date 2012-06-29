/*!
    RFUI
    RFWebViewController

    ver -.-.-
 */

#import <UIKit/UIKit.h>

@protocol RFWebViewControllerDelegate;


@interface RFWebViewController : UIViewController <UIWebViewDelegate> {
	NSTimeInterval titleMonitorInterval;		// 0.5f
	NSTimeInterval titleMonitorIntervalAfterLoaded;	// 20.f
	int titleMonitorFlag;
}
@property (assign, nonatomic) id<RFWebViewControllerDelegate> delegate;
@property (RF_STRONG, nonatomic) IBOutlet UIWebView *webView;
@property (RF_STRONG, nonatomic) IBOutlet UIView * toolbarView;

@property (copy, nonatomic) NSString *webPageTitle;
@property (RF_STRONG, nonatomic) IBOutlet UILabel *webPageTitleLabel;
@property (strong, atomic) NSTimer * webPageTitleMonitor;

- (void)loadRequest:(NSURLRequest *)request;
- (void)showToolbar:(BOOL)animated;
- (void)hideToolbar:(BOOL)animated;

- (IBAction)onTest1:(id)sender;
- (IBAction)onExit:(id)sender;
@end


@protocol RFWebViewControllerDelegate <NSObject>
@optional
- (void)RFWebViewController:(RFWebViewController *)vc viewWillAppear:(BOOL)animated;
- (void)RFWebViewController:(RFWebViewController *)vc viewWillDisappear:(BOOL)animated;
- (void)onRFWebViewControllerExitTap:(RFWebViewController *)vc;


@end
