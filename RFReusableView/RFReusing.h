// TEST

#import "RFUI.h"

@protocol RFReusing <NSObject>
@required
@property (copy, readonly, nonatomic) NSString *reuseIdentifier;

- (void)prepareForReuse;
@end
