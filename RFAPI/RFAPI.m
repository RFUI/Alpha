
#import "RFAPI.h"
#import "RFAssetsCache.h"
#import "RFMessageManager+RFDisplay.h"

@interface RFAPI ()
@end

@implementation RFAPI

- (void)alertError:(NSError *)error title:(NSString *)title {
    [self.networkActivityIndicatorManager alertError:error title:title];
}

@end
