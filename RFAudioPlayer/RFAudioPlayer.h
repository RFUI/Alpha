/*!
    RFAudioPlayer
    RFUI

    Copyright (c) 2013-2014, 2016 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    TEST
 */

#import <AVFoundation/AVFoundation.h>

/**
 Work best with KVO
 */
@interface RFAudioPlayer : NSObject

+ (instancetype _Nonnull)sharedInstance;

/**
 Play a single audiovisual resource referenced by a given URL. This method can be called many time in a short period and only the last item will be accepted.
 
 @discussion This method try to creat an AVPlayer asynchronously then play it. If you call this method many times in a short period, only the last request will be accept, as RFAudioPlayer designed can only play a single item at one time.
 
 @param url An URL that identifies an audiovisual resource. RFAudioPlayer works equally well with local and remote media files.
 
 @param callback A block called on main queue when the receiver just before play the media or this url is skiped. May be nil.
 */
- (void)playURL:(NSURL *_Nonnull)url ready:(void (^_Nullable)(BOOL creat))callback;

#pragma mark - Player stautes
@property (nonatomic, nullable, readonly) AVPlayer *player;
@property (nonatomic, nullable, readonly, copy) NSURL *currentPlayItemURL;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic) NSTimeInterval currentTime; // KVO not supported

// You can use this property to pause/play audio playback.
@property (nonatomic, getter = isPlaying) BOOL playing;

- (BOOL)play;
- (BOOL)pause;
- (BOOL)stop;

@end
