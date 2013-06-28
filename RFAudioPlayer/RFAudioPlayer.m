
#import "RFAudioPlayer.h"

static void *const RFAudioPlayerKVOContext = (void *)&RFAudioPlayerKVOContext;

@interface RFAudioPlayer ()
@property (readwrite, strong, nonatomic) AVPlayer *player;
@property (assign, nonatomic) dispatch_queue_t dispatchQueue;
@property (copy, nonatomic) NSURL *toBeCreatPlayerURL;
@property (readwrite, copy, nonatomic) NSURL *currentPlayItemURL;
@end

@implementation RFAudioPlayer
@dynamic duration;
@dynamic playing;

+ (instancetype)sharedInstance {
	static RFAudioPlayer *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
	return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.dispatchQueue = dispatch_queue_create([@"com.github.RFUI.RFAudioPlayer" cStringUsingEncoding:NSUTF8StringEncoding], NULL);
    }
    return self;
}

- (void)dealloc {
    
}


#define _RFAudioPlayer_CreatCallBack(IsReady)\
dispatch_async(dispatch_get_main_queue(), ^{\
    if (callback) {\
        callback(IsReady);\
    }\
})

- (void)playURL:(NSURL *)url ready:(void (^)(BOOL creat))callback {
    if ([url isEqual:self.currentPlayItemURL]) {
        [self play];
        return;
    }

    // We need creat another player.
    [self pause];
    
    // Creat an AVPlayer will block current thread, we will creat it on our queue.
    self.toBeCreatPlayerURL = url;
    dispatch_async(self.dispatchQueue, ^{
        if (![url isEqual:self.toBeCreatPlayerURL]) {
            _dout(@"Skip, URL changed when task in queue.")
            _RFAudioPlayer_CreatCallBack(NO);
            return;
        }
        
        _dout(@"Creating player: %@", url);
        AVPlayer *player = [AVPlayer playerWithURL:url];
        
        if (![url isEqual:self.toBeCreatPlayerURL]) {
            _douto(@"URL changed when creating, abandon this player");
            _RFAudioPlayer_CreatCallBack(NO);
        }
        else {
            _dout(@"Player created success: %@", url);
            self.player = player;
            self.currentPlayItemURL = self.toBeCreatPlayerURL;
            self.toBeCreatPlayerURL = nil;
            
            _RFAudioPlayer_CreatCallBack(YES);
            [self play];
        }
    });
    

}

- (NSTimeInterval)currentTime {
    if (self.player) {
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
    
    dout(@"Playing: %@", self.currentPlayItemURL);
    
    AVAudioSession *s = [AVAudioSession sharedInstance];
    if ([s.category isEqualToString:AVAudioSessionCategoryRecord]) {
        NSError __autoreleasing *e = nil;
        [s setCategory:AVAudioSessionCategorySoloAmbient error:&e];
        if (e) dout_error(@"%@", e);
    }
    
    if (self.duration > 0 && self.currentTime == self.duration) {
        dout_info(@"Restart play at beginning.")
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
    if (!self.player) return NO;
    
    [self.player pause];
    self.currentTime = 0;
    return YES;
}

+ (NSTimeInterval)timeIntervalFromCMTime:(CMTime)time {
    if (time.flags == kCMTimeFlags_Valid) {
        return (float)time.value/time.timescale;
    }
    return -1;
}

+ (NSSet *)keyPathsForValuesAffectingPlaying {
    return [NSSet setWithObjects:@keypathClassInstance(RFAudioPlayer, player), @keypathClassInstance(RFAudioPlayer, player.rate), nil];
}

+ (NSSet *)keyPathsForValuesAffectingDuration {
    return [NSSet setWithObject:@keypathClassInstance(RFAudioPlayer, player.currentItem.duration)];
}

@end
