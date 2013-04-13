/*!
    RFPlugin

    Copyright (c) 2013 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Theory Test
 */

#import "RFRuntime.h"
#import <objc/runtime.h>

@protocol RFPluginSupported;

@interface RFPlugin : NSObject
@property (RF_WEAK, nonatomic) IBOutlet id<RFPluginSupported> master;

- (void)setup;
@end

@protocol RFPluginSupported <NSObject>



@end
