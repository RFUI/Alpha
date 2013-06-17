// Alpha

#import "RFButton.h"
#import "RFReusing.h"

@interface RFTabBarItem : RFButton
<RFStoryboardReusing>

@property (copy, nonatomic) NSString *reuseIdentifier;

@end
