
#import "RFAsynchronousNavigationPushSegue.h"

@implementation RFAsynchronousNavigationPushSegue

- (void)RFPerform {
    [[(UIViewController *)self.sourceViewController navigationController] pushViewController:self.destinationViewController animated:YES];
}

@end
