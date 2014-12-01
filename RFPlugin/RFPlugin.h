/*!
    RFPlugin

    Copyright (c) 2013-2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    TEST
 */

#import "RFRuntime.h"
#import "RFInitializing.h"

@protocol RFPluginSupported;

/**
 @warning RFPlugin may be deprecated in future.
 */
@interface RFPlugin : NSObject <
    RFInitializing
>
@property (RF_WEAK, nonatomic) IBOutlet id<RFPluginSupported> master;

- (instancetype)initWithMaster:(id<RFPluginSupported>)master NS_DESIGNATED_INITIALIZER;

@end

@protocol RFPluginSupported <NSObject>
// Nothing
@end
