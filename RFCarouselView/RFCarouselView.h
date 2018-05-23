/*!
 RFCarouselView
 RFUI
 
 Copyright (c) 2018 BB9z
 https://github.com/RFUI/Alpha
 
 The MIT License (MIT)
 http://www.opensource.org/licenses/mit-license.php
 */
#import <RFKit/RFRuntime.h>
#import <RFInitializing/RFInitializing.h>

@interface RFCarouselView : UIView <
    RFInitializing
>

@property (weak, nullable) IBOutlet UIView *contentView;

@property IBInspectable NSUInteger count;
@property (nonatomic) NSInteger index;

/// 默认 3s
#if TARGET_INTERFACE_BUILDER
@property (nonatomic) IBInspectable double duration;
#else
@property (nonatomic) NSTimeInterval duration;
#endif

@property (getter=isAnimating, nonatomic) IBInspectable BOOL animating;

@property (nullable) void (^setupContentViewAtIndex)(NSInteger index, id __nonnull contentView);

@end
