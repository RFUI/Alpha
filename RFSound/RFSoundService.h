/*
 RFSoundService
 RFAlpha
 
 Copyright (c) 2012-2013, 2020 BB9z
 https://github.com/RFUI/Alpha

 The MIT License (MIT)
 http://www.opensource.org/licenses/mit-license.php
 */

#import <RFKit/RFRuntime.h>

/**
 使用 Audio Services 播放音效
 */
@interface RFSoundService : NSObject

/// 添加文件注册声音
/// @return 是否成功
- (BOOL)addSoundWithURL:(nonnull NSURL *)soundFileURL identifier:(nonnull NSString *)identifier;

/// 移除声音注册
/// @return 指定声音不存在返回 NO
- (BOOL)removeSound:(nonnull NSString *)soundIdentifier;

/// 播放声音
/// @return 指定声音不存在返回 NO
- (BOOL)playSound:(nonnull NSString *)soundIdentifier;

/// 振动设备
/// 在模拟器及不支持震动的设备上无效果
- (void)vibrate;
@end
