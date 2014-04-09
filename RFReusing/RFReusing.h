// TEST

#import "RFUI.h"

@protocol RFReusing <NSObject>
@required
@property (copy, readonly, nonatomic) NSString *reuseIdentifier;

@optional
- (void)willReused;
- (void)didResued;

- (void)willRecycled;
- (void)didRecycled;
@end
