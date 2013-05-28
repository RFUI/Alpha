// Alpha

#import "RFButton.h"
#import "RFStoryboardReusing.h"

@interface RFTabBarItem : RFButton
<RFStoryboardReusing>

@property (copy, nonatomic) NSString *reuseIdentifier;

@end
