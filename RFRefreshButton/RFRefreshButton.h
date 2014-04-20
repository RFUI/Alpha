/*!
    RFRefreshButton
    RFUI

    Copyright (c) 2013-2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Alpha
 */

#import "RFUI.h"

@interface RFRefreshButton : UIButton <
    RFInitializing
>

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) IBOutlet UIImageView *iconImageView;

#pragma mark - Auto update statue
// 通过 KVO 观测特定属性实现自身状态的自动转换

@property (readonly, getter = isObserving, nonatomic) BOOL observing;

@property (weak, readonly, nonatomic) id observeTarget;
@property (copy, readonly, nonatomic) NSString *observeKeypath;

/**
 @param target Must not be nil.
 @param keypath Must not be nil.
 @param ifProccessingBlock Return `YES` if the observed target is proccessing. This parameter may be nil.
 */
- (void)observeTarget:(id)target forKeyPath:(NSString *)keypath evaluateBlock:(BOOL (^)(id evaluatedVaule))ifProccessingBlock;
- (void)stopObserve;

@end
