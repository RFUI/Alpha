
#import "RFSoundService.h"
#include <AudioToolbox/AudioToolbox.h>

@interface RFSoundService ()
@property (RF_STRONG, nonatomic) NSMutableDictionary *soundStack;
@end

@implementation RFSoundService
+ (instancetype)sharedInstance {
	static RFSoundService *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
	return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.soundStack = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BOOL)addSoundWithURL:(NSURL *)soundFileURL identifier:(NSString *)identifier {
    SystemSoundID sound;
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundFileURL, &sound);
    [self.soundStack setObject:@(sound) forKey:identifier];
    return YES;
}

- (BOOL)removeSound:(NSString *)soundIdentifier {
    SystemSoundID sound = [self.soundStack[soundIdentifier] intValue];
    AudioServicesDisposeSystemSoundID(sound);
    [self.soundStack removeObjectForKey:soundIdentifier];
    return YES;
}

- (BOOL)playSound:(NSString *)soundIdentifier {
    id soundRef = self.soundStack[soundIdentifier];
    
    if (!soundRef) {
        return NO;
    }
    
    SystemSoundID sound = [soundRef intValue];
    AudioServicesPlayAlertSound(sound);
    return YES;
}

- (void)vibrate {
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}

- (void)dealloc {
    for (id soundRefObj in self.soundStack) {
        AudioServicesDisposeSystemSoundID([soundRefObj intValue]);
    }
    
    RF_RELEASE_OBJ(super)
}

@end
