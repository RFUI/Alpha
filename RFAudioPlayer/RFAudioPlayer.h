// Pre TEST
// Work best with KVO

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/***/
@interface RFAudioPlayer : NSObject

+ (instancetype)sharedInstance;

/**
 Play a single audiovisual resource referenced by a given URL. This method can be called many time in a short period and only the last item will be accepted.
 
 @discussion This method try to creat an AVPlayer asynchronously then play it. If you call this method many times in a short period, only the last request will be accept, as RFAudioPlayer designed can only play a single item at one time.
 
 @param url An URL that identifies an audiovisual resource. RFAudioPlayer works equally well with local and remote media files.
 
 @param callback A block called when the receiver just before play the media. This block may never be executed. May be nil.

 */
- (void)playURL:(NSURL *)url ready:(void (^)(RFAudioPlayer *player, NSTimeInterval duration))callback;


#pragma mark - Player stautes
@property (readonly, nonatomic) AVPlayer *player;
@property (readonly, copy, nonatomic) NSURL *currentPlayItemURL;
@property (readonly, nonatomic) NSTimeInterval duration;
@property (nonatomic) NSTimeInterval currentTime; // KVO not supported

// You can use this property to pause/play audio playback.
@property (getter = isPlaying, nonatomic) BOOL playing;

- (BOOL)play;
- (BOOL)pause;
- (BOOL)stop;

@end
