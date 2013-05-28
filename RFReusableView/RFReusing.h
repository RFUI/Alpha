// TEST

#import "RFUI.h"

@protocol RFReusing <NSObject>
@required
- (NSString *)reuseIdentifier;
- (instancetype)reusingCopy;
- (void)prepareForReuse;
@end
