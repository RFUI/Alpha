/*!
    RFSoundService
 
 */

#import <Foundation/Foundation.h>

@interface RFSoundService : NSObject
+ (instancetype)sharedInstance;

- (BOOL)addSoundWithURL:(NSURL *)soundFileURL identifier:(NSString *)identifier;
- (BOOL)removeSound:(NSString *)soundIdentifier;
- (BOOL)playSound:(NSString *)soundIdentifier;

/// In the Simulator and on devices with no vibration element, this method does nothing.
- (void)vibrate;
@end
