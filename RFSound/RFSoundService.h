/*!
    RFSoundService
    RFUI/Alpha
 
    Copyright (c) 2012-2013 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php
 
    Beta
 */

#import <RFKit/RFRuntime.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>

@interface RFSoundService : NSObject
+ (instancetype)sharedInstance;

- (BOOL)addSoundWithURL:(NSURL *)soundFileURL identifier:(NSString *)identifier;
- (BOOL)removeSound:(NSString *)soundIdentifier;
- (BOOL)playSound:(NSString *)soundIdentifier;

/// The current volume of application media, in the range of 0.0 to 1.0.
@property (assign, nonatomic) float volume;

@property (assign, nonatomic, getter = isMute) BOOL mute;

/// In the Simulator and on devices with no vibration element, this method does nothing.
- (void)vibrate;
@end
