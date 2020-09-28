
#import "RFSoundService.h"
@import AudioToolbox;

@interface RFSoundService ()
@property NSMutableDictionary<NSString *, NSNumber *> *soundStack;
@end

@implementation RFSoundService

- (instancetype)init {
    self = [super init];
    if (self) {
        self.soundStack = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BOOL)addSoundWithURL:(NSURL *)soundFileURL identifier:(NSString *)identifier {
    SystemSoundID sound;
    OSStatus result = AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundFileURL, &sound);
    if (result != kAudioServicesNoError) {
        dout_error(@"添加声音失败 %d", (int)result)
        return NO;
    }
    [self.soundStack setObject:@(sound) forKey:identifier];
    return YES;
}

- (BOOL)removeSound:(NSString *)soundIdentifier {
    NSNumber *soundRef = self.soundStack[soundIdentifier];
    if (!soundRef) return NO;

    SystemSoundID sound = soundRef.intValue;
    AudioServicesDisposeSystemSoundID(sound);
    [self.soundStack removeObjectForKey:soundIdentifier];
    return YES;
}

- (BOOL)playSound:(NSString *)soundIdentifier {
    NSNumber *soundRef = self.soundStack[soundIdentifier];
    if (!soundRef) return NO;
    
    SystemSoundID sound = [soundRef intValue];
    AudioServicesPlaySystemSound(sound);
    return YES;
}

- (void)dealloc {
    for (NSNumber *soundRefObj in self.soundStack) {
        AudioServicesDisposeSystemSoundID(soundRefObj.intValue);
    }
}

- (void)vibrate {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

@end
