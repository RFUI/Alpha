
#import "RFAsynchronousPushSegue.h"

@implementation RFAsynchronousPushSegue

- (void)RFPerform {
    [[(UIViewController *)self.sourceViewController navigationController] pushViewController:self.destinationViewController animated:YES];
}

@end
