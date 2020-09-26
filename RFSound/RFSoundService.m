
#import "RFSoundService.h"

@interface RFSoundService ()
@property NSMutableDictionary<NSString *, NSNumber *> *soundStack;
@property float lastNotZeroVolumn;
@property (nonatomic) MPMusicPlayerController *applicationMusicPlayer;
@end

@implementation RFSoundService

+ (instancetype)sharedInstance {
	static RFSoundService *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = self.new;
    });
	return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.soundStack = [NSMutableDictionary dictionary];
        self.lastNotZeroVolumn = (self.volume != 0)? self.volume : 0.1;
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
    NSNumber *soundRef = self.soundStack[soundIdentifier];
    
    if (!soundRef) {
        return NO;
    }
    
    SystemSoundID sound = [soundRef intValue];
    AudioServicesPlaySystemSound(sound);
    return YES;
}

- (void)vibrate {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)dealloc {
    for (NSNumber *soundRefObj in self.soundStack) {
        AudioServicesDisposeSystemSoundID(soundRefObj.intValue);
    }
}

- (MPMusicPlayerController *)applicationMusicPlayer {
    if (!_applicationMusicPlayer) {
        _applicationMusicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    }
    return _applicationMusicPlayer;
}

#pragma mark - Volume

+ (NSSet *)keyPathsForValuesAffectingVolume {
    RFSoundService *this;
    return [NSSet setWithObject:@keypath(this, applicationMusicPlayer.volume)];
}

+ (NSSet *)keyPathsForValuesAffectingMute {
    RFSoundService *this;
    return [NSSet setWithObject:@keypath(this, applicationMusicPlayer.volume)];
}

- (float)volume {
    return self.applicationMusicPlayer.volume;
}

- (void)setVolume:(float)volume {
    self.applicationMusicPlayer.volume = volume;
    if (volume > 0.f) {
        self.lastNotZeroVolumn = volume;
    }
}

- (BOOL)isMute {
    return (self.applicationMusicPlayer.volume == 0);
}

- (void)setMute:(BOOL)mute {
    self.applicationMusicPlayer.volume = (mute)? 0 : self.lastNotZeroVolumn;
}

@end
