#import "RFWebViewController.h"

@interface RFWebViewController ()
//@property (readwrite, atomic) NSTimer * webPageTitleMonitor;
@property (copy, nonatomic) NSString *lastWebPageTitle;

- (void)deactiveTitleMonitor;
@end

@implementation RFWebViewController
@synthesize delegate, webView, toolbarView;
@synthesize webPageTitle, lastWebPageTitle, webPageTitleLabel;
@synthesize webPageTitleMonitor;

- (void)awakeFromNib {
    [self performSelector:@selector(doAfterInit) withObject:self afterDelay:0];
}

- (void)doAfterInit {
	RFKit_RUN_ONCE_START
	self.webView.delegate = self;
	
	titleMonitorInterval = 0.5;
	titleMonitorIntervalAfterLoaded = 5;
	self.lastWebPageTitle = @"";
	
	RFKit_RUN_ONCE_END
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	_doutwork()
	_douto(keyPath)
	_douto(change)
	
//	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.

	[self addObserver:self forKeyPath:@"webPageTitle" options:NSKeyValueIntersectSetMutation context:NULL];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.z
//	[self removeObserver:self.webView.request forKeyPath:@"URL"];
	[self deactiveTitleMonitor];
}

- (void)viewWillAppear:(BOOL)animated {
//	doutwork()
	if ([self.delegate respondsToSelector:@selector(RFWebViewController:viewWillAppear:)]) {
		[self.delegate RFWebViewController:self viewWillAppear:animated];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
//	doutwork()
	if ([self.delegate respondsToSelector:@selector(RFWebViewController:viewWillDisappear:)]) {
		[self.delegate RFWebViewController:self viewWillDisappear:animated];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)loadRequest:(NSURLRequest *)request {
    douto(request)
	[self.webView loadRequest:request];
}

- (IBAction)onTest1:(id)sender {
	[self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.google.com/"]]];
}

- (IBAction)onExit:(id)sender {
//	static BOOL tt;
//	if (tt) {
////		[self hideToolbar:YES];
//		self.view.hidden = YES;
//	}
//	else {
////		[self showToolbar:YES];
//	}
//	tt = !tt;
	NSString *blankPath = [[NSBundle mainBundle] pathForResource:@"RFWebViewController_blank" ofType:@"html"];
	NSURL *blankPage = [NSURL fileURLWithPath:blankPath];
	[self.webView stopLoading];
	[self.webView loadRequest:[NSURLRequest requestWithURL:blankPage]];
	if ([self.delegate respondsToSelector:@selector(onRFWebViewControllerExitTap:)]) {
		[self.delegate onRFWebViewControllerExitTap:self];
	}
}

- (void)onURLChanged {
	
}

#pragma mark Toolbar
- (void)showToolbar:(BOOL)animated {
	if (animated) {
		[UIView beginAnimations:@"RFWebViewController_showToolbar" context:nil];
		[UIView setAnimationDuration:0.5];
	}
	[self.toolbarView moveToX:0 Y:0];
	if (animated) {
		[UIView commitAnimations];
	}
}
- (void)hideToolbar:(BOOL)animated {
	if (animated) {
		[UIView beginAnimations:@"RFWebViewController_hideToolbar" context:nil];
		[UIView setAnimationDuration:0.5];
	}
	CGFloat height = self.toolbarView.bounds.size.height;
	[self.toolbarView moveToX:0 Y:-height];
	if (animated) {
		[UIView commitAnimations];
	}
}

#pragma mark Title monitoring
- (void)deactiveTitleMonitor {
//	doutwork()
	if (self.webPageTitleMonitor) {
		[self.webPageTitleMonitor invalidate];
		self.webPageTitleMonitor = nil;
	}
}

- (void)activeTitleMonitor:(BOOL)isFastMode {
//	doutwork()
	[self deactiveTitleMonitor];
	if (isFastMode) {
		titleMonitorFlag = 1;
		self.webPageTitleMonitor = [NSTimer scheduledTimerWithTimeInterval:titleMonitorInterval target:self selector:@selector(processTitleMonitor) userInfo:nil repeats:YES];
	}
	else {
		titleMonitorFlag = 2;
		self.webPageTitleMonitor = [NSTimer scheduledTimerWithTimeInterval:titleMonitorIntervalAfterLoaded target:self selector:@selector(processTitleMonitor) userInfo:nil repeats:YES];
	}
}

- (BOOL)tryGotWebPageTitle:(BOOL)foceMode {
	NSString *page_title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
//	dout(@"tryGotWebPageTitle >> tt: %@", page_title)
	if (!foceMode && ![page_title isEqualToString:self.lastWebPageTitle]) {
//		douts(@"title right")
		self.lastWebPageTitle = self.webPageTitle;
		self.webPageTitle = page_title;
		self.webPageTitleLabel.text = page_title;
		return YES;
	}
	else {
		self.webPageTitle = page_title;
		self.webPageTitleLabel.text = page_title;
	}
	return NO;
}

- (void)processTitleMonitor {
//	dout(@"processTitleMonitor >> flag: %d", titleMonitorFlag)
	switch (titleMonitorFlag) {
		case -1:
			[self deactiveTitleMonitor];
			break;
		case 0:
			break;
		case 1:
			if (self.webPageTitleMonitor) {
				if ([self tryGotWebPageTitle:NO]) {
					[self activeTitleMonitor:NO];
				}
			}
			else {
				[self activeTitleMonitor:YES];
			}	
			break;
		case 2:
			if (self.webPageTitleMonitor) {
				[self tryGotWebPageTitle:YES];
			}
			else {
				[self activeTitleMonitor:NO];
			}
			break;
		case 3:
			[self tryGotWebPageTitle:YES];
			[self deactiveTitleMonitor];
			break;
	}
}

/** titleMonitorFlag
	-2	
	-1	应该停止
	0
	1	快速模式
	2	慢速模式
	3	执行一次后停止
	4	需要更新
 */
#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//	douto(request)
	return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
//	doutwork()
//	[self activeTitleMonitor:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
	[self tryGotWebPageTitle:YES];
//	[self deactiveTitleMonitor];
//	[self activeTitleMonitor:NO];
//	dout(@"webViewDidFinishLoad %@", aWebView.request)
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[self tryGotWebPageTitle:YES];
//	titleMonitorFlag = 3;
//	[self processTitleMonitor];
//	douto(error)
}

@end
