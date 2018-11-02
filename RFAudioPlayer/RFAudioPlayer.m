
#import "RFAudioPlayer.h"
#import <RFKit/dout.h>

static NSTimeInterval NSTimeIntervalFromCMTime(CMTime time) {
    if (time.flags != kCMTimeFlags_Valid) return NAN;
    return (double)time.value / time.timescale;
}

@interface RFAudioPlayer ()
@property (nonatomic, nullable, readwrite) AVPlayer *player;
@property (copy, nonatomic) NSURL *toBeCreatPlayerURL;
@property (nonatomic, nullable, readwrite, copy) NSURL *currentPlayItemURL;
@end

@implementation RFAudioPlayer

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    self.player = nil;
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
    dispatch_async_on_background(^{
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
        AVPlayer *player = [AVPlayer.alloc initWithURL:url];
        player.allowsExternalPlayback = NO;
        
        if (![url isEqual:self.toBeCreatPlayerURL]) {
            _douto(@"URL changed when creating, abandon this player");
            safeCallback(NO);
        }
        else {
            _dout(@"Player created success: %@", url);
            self.player = player;

            self.currentPlayItemURL = self.toBeCreatPlayerURL;
            self.toBeCreatPlayerURL = nil;
            self.playReachEnd = NO;
            
            safeCallback(YES);
            [self play];
        }
    });
}

#pragma mark -

@dynamic playing;
- (BOOL)isPlaying {
    return [self playing];
}
- (BOOL)playing {
    if (!self.player) return NO;
    return (self.player.rate != 0.0);
}
- (void)setPlaying:(BOOL)playing {
    if (playing) {
        [self play];
    }
    else {
        [self pause];
    }
}

+ (NSSet *)keyPathsForValuesAffectingPlaying {
    return [NSSet setWithObjects:@keypathClassInstance(RFAudioPlayer, player.rate), nil];
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
    
    if (self.playReachEnd
        || (self.duration > 0 && ABS(self.duration - self.currentTime) < 1)) {
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

- (void)setPlayer:(AVPlayer *)player {
    if (_player == player) return;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    if (_player) {
        [nc removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
    }
    [self willChangeValueForKey:@"playing"];
    [self willChangeValueForKey:@"currentTime"];
    [self willChangeValueForKey:@"duration"];
    _player = player;
    [self didChangeValueForKey:@"playing"];
    [self didChangeValueForKey:@"currentTime"];
    [self didChangeValueForKey:@"duration"];
    if (player) {
        [nc addObserver:self selector:@selector(RFAudioPlayer_handelPlayerItemDidPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem];
    }
}

- (void)RFAudioPlayer_handelPlayerItemDidPlayToEndTimeNotification:(NSNotification *)notice {
    self.playReachEnd = YES;
}

#pragma mark -

- (NSTimeInterval)currentTime {
    AVPlayerItem *pi = self.player.currentItem;
    if (!pi || pi.status != AVPlayerItemStatusReadyToPlay) return -1;
    CMTime time = pi.currentTime;
    NSTimeInterval t = NSTimeIntervalFromCMTime(time);
    return t;
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    CMTime time = self.player.currentTime;
    CMTime makeTime = time;
    makeTime.value = currentTime*time.timescale;
    self.playReachEnd = NO;
    [self.player seekToTime:makeTime];
}

+ (NSSet *)keyPathsForValuesAffectingCurrentTime {
    return [NSSet setWithObject:@keypathClassInstance(RFAudioPlayer, player.currentItem.currentTime)];
}

@dynamic duration;
- (NSTimeInterval)duration {
    AVPlayerItem *pi = self.player.currentItem;
    if (!pi || pi.status != AVPlayerItemStatusReadyToPlay) return -1;
    CMTime time = pi.asset.duration;
    NSTimeInterval du = NSTimeIntervalFromCMTime(time);
    return isfinite(du) ? du : -1;
}

+ (NSSet *)keyPathsForValuesAffectingDuration {
    return [NSSet setWithObject:@keypathClassInstance(RFAudioPlayer, player.currentItem.duration)];
}

@end
