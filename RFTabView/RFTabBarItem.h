// Alpha

#import "RFButton.h"
#import "RFReusing.h"

@interface RFTabBarItem : RFButton <
    RFReusing
>
@property (copy, nonatomic) NSString *reuseIdentifier;

@end
