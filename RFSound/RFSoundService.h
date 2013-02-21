/*!
    RFSoundService
 
 */

#import <Foundation/Foundation.h>

@interface RFSoundService : NSObject
+ (instancetype)sharedInstance;

- (BOOL)addSoundWithURL:(NSURL *)soundFileURL identifier:(NSString *)identifier;
- (BOOL)removeSound:(NSString *)soundIdentifier;
- (BOOL)playSound:(NSString *)soundIdentifier;

@end
