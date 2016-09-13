
#import "RFAudioPlayer.h"
#import "dout.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcast-qual"
static void *const RFAudioPlayerKVOContext = (void *)&RFAudioPlayerKVOContext;
#pragma clang diagnostic pop

@interface RFAudioPlayer ()
@property (nonatomic, nullable, readwrite) AVPlayer *player;
@property (strong, nonatomic) dispatch_queue_t dispatchQueue;
@property (copy, nonatomic) NSURL *toBeCreatPlayerURL;
@property (nonatomic, nullable, readwrite, copy) NSURL *currentPlayItemURL;
@end

@implementation RFAudioPlayer
@dynamic duration;
@dynamic playing;

- (id)init {
    self = [super init];
    if (self) {
        self.dispatchQueue = dispatch_queue_create([@"com.github.RFUI.RFAudioPlayer" cStringUsingEncoding:NSUTF8StringEncoding], NULL);
    }
    return self;
}

- (void)playURL:(NSURL *_Nonnull)url ready:(void (^_Nullable)(BOOL creat))callback {
    if ([url isEqual:self.currentPlayItemURL]) {
        [self play];
        return;
    }

    // We need creat another player.
    [self pause];
    
    // Creat an AVPlayer will block current thread, we will creat it on our queue.
    self.toBeCreatPlayerURL = url;
    dispatch_async(self.dispatchQueue, ^{
        void (^safeCallback)(BOOL) = ^(BOOL ct){
            if (!callback) return;
            dispatch_async_on_main(^{
                callback(ct);
            });
        };

        if (![url isEqual:self.toBeCreatPlayerURL]) {
            _dout(@"Skip, URL changed when task in queue.")
            safeCallback(NO);
            return;
        }
        
        _dout(@"Creating player: %@", url);
        AVPlayer *player = [AVPlayer playerWithURL:url];
        
        if (![url isEqual:self.toBeCreatPlayerURL]) {
            _douto(@"URL changed when creating, abandon this player");
            safeCallback(NO);
        }
        else {
            _dout(@"Player created success: %@", url);
            self.player = player;
            self.currentPlayItemURL = self.toBeCreatPlayerURL;
            self.toBeCreatPlayerURL = nil;
            
            safeCallback(YES);
            [self play];
        }
    });
}

- (NSTimeInterval)currentTime {
    if (self.player) {
        // This value may be negative. CMTimeGetSeconds() is the same.
        return [RFAudioPlayer timeIntervalFromCMTime:self.player.currentTime];
    }
    else {
        return -1;
    }
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    CMTime time = self.player.currentTime;
    CMTime makeTime = time;
    makeTime.value = currentTime*time.timescale;
    [self.player seekToTime:makeTime];
}

- (NSTimeInterval)duration {
    if (self.player.currentItem) {
        CMTime time = self.player.currentItem.duration;
        return [RFAudioPlayer timeIntervalFromCMTime:time];
    }
    return -1;
}

#pragma mark -
- (BOOL)isPlaying {
    return [self playing];
}
- (BOOL)playing {
    if (self.player) {
        return (self.player.rate != 0.0);
    }
    return NO;
}
- (void)setPlaying:(BOOL)playing {
    if (playing) {
        [self play];
    }
    else {
        [self pause];
    }
}

- (BOOL)play {
    if (!self.player) {
        return NO;
    }
    if (self.playing) return YES;
    
    _dout(@"Playing: %@", self.currentPlayItemURL);
    
    AVAudioSession *s = [AVAudioSession sharedInstance];
    if ([s.category isEqualToString:AVAudioSessionCategoryRecord]) {
        NSError __autoreleasing *e = nil;
        [s setCategory:AVAudioSessionCategorySoloAmbient error:&e];
        if (e) dout_error(@"%@", e);
    }
    
    if (self.duration > 0 && self.currentTime == self.duration) {
        _dout_info(@"Restart play at beginning.")
        self.currentTime = 0;
    }
    
    [self.player play];
    return YES;
}

- (BOOL)pause {
    if (!self.player) return NO;

    [self.player pause];
    return YES;
}

- (BOOL)stop {
    [self pause];
    self.currentTime = 0;
    self.currentPlayItemURL = nil;
    return YES;
}

// Implement these method so we don´t have to import CoreMedia framework to use CMTimeMakeWithSeconds() and CMTimeGetSeconds().
+ (NSTimeInterval)timeIntervalFromCMTime:(CMTime)time {
    if (time.flags == kCMTimeFlags_Valid) {
        return (float)time.value/time.timescale;
    }
    return -1;
}

+ (CMTime)CMTimeFromTimeInterval:(NSTimeInterval)timeInterval timeScale:(CMTimeScale)timeScale {
    return (CMTime){timeInterval*timeScale, timeScale, kCMTimeFlags_Valid, 0};
}

+ (NSSet *)keyPathsForValuesAffectingPlaying {
    return [NSSet setWithObjects:@keypathClassInstance(RFAudioPlayer, player), @keypathClassInstance(RFAudioPlayer, player.rate), nil];
}

+ (NSSet *)keyPathsForValuesAffectingDuration {
    return [NSSet setWithObject:@keypathClassInstance(RFAudioPlayer, player.currentItem.duration)];
}

@end
