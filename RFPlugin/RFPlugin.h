/*!
    RFPlugin

    Copyright (c) 2013 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Pre TEST
 */

#import "RFRuntime.h"

@protocol RFPluginSupported;

@interface RFPlugin : NSObject
@property (RF_WEAK, nonatomic) IBOutlet id<RFPluginSupported> master;

- (void)setup;

@end

@protocol RFPluginSupported <NSObject>



@end
