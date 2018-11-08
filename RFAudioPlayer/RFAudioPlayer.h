/*
 RFAudioPlayer
 RFAlpha
 
 Copyright (c) 2013-2014, 2016, 2018 BB9z
 https://github.com/RFUI/Alpha
 
 The MIT License (MIT)
 http://www.opensource.org/licenses/mit-license.php
 */

#import <AVFoundation/AVFoundation.h>

/**
 AVAudioPlayer replacement which can play a remote audio file.
 
 Know iOS bug:
 
 - For m4a files, only local playback is supported.
 - Some audio files may return wrong duration.
 */
@interface RFAudioPlayer : NSObject

/**
 Play a single audiovisual resource referenced by a given URL. This method can be called many time in a short period and only the last item will be accepted.
 
 @discussion This method try to creat an AVPlayer asynchronously then play it. If you call this method many times in a short period, only the last request will be accept, as RFAudioPlayer designed can only play a single item at one time.
 
 @param url An URL that identifies an audiovisual resource. RFAudioPlayer works equally well with local and remote media files.
 
 @param callback A block called on main queue when the receiver just before play the media or this url is skiped. May be nil.
 */
- (void)playURL:(nonnull NSURL *)url ready:(nullable void (^)(BOOL creat))callback;

@property (nullable, readonly, copy) NSURL *currentPlayItemURL;

#pragma mark - Player stautes
@property (nonatomic, nullable, readonly) AVPlayer *player;

/// Not support KVO
@property (nonatomic) NSTimeInterval currentTime;

/// @bug SDK API may return a wrong duration for remote files.
@property (nonatomic, readonly) NSTimeInterval duration;
@property (getter=isPlayReachEnd) BOOL playReachEnd;

/// You can use this property to pause/play audio playback.
@property (nonatomic, getter = isPlaying) BOOL playing;

- (BOOL)play;
- (BOOL)pause;
- (BOOL)stop;

// not working
@property (nonatomic, readonly, getter=isBuffering) BOOL buffering;

@property (nonatomic, readonly, nullable) NSError *error;

@end
