
#import "RFAsynchronousPushAsRootSegue.h"

@implementation RFAsynchronousPushAsRootSegue

- (void)RFPerform {
    [self noticeDelegateWillPerform];
    UINavigationController *nav = [self.sourceViewController navigationController];
    [nav setViewControllers:@[ self.destinationViewController ] animated:YES];
    dispatch_after_seconds(RFSegueNavigationTransitionDuration, ^{
        [self noticeDelegateDidPerformed];
    });
}

@end
