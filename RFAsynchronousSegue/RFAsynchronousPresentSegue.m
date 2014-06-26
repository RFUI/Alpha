
#import "RFAsynchronousPresentSegue.h"

@implementation RFAsynchronousPresentSegue

- (void)RFPerform {
    [self noticeDelegateWillPerform];
    [(UIViewController *)self.sourceViewController presentViewController:self.destinationViewController animated:YES completion:^{
        [self noticeDelegateDidPerformed];
    }];
}

@end
