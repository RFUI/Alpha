// TEST
// Section will not supported.

#import <Foundation/Foundation.h>
#import "RFReusing.h"
#import "RFInitializing.h"

@interface RFReusingPool : NSObject
<RFInitializing>

/// Thread safe
/// `willReused` called in this method, `didResued` should be called manually.
- (id<RFReusing>)dequeueReusableObjectWithIdentifier:(NSString *)identifier;

/// Thread safe
/// `didRecycled` called in this method, `willRecycled` should be called manually.
- (void)recycleObject:(id<RFReusing>)object;

- (void)cleanPool;
@end
