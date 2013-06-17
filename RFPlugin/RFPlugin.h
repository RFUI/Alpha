/*!
    RFPlugin

    Copyright (c) 2013 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    TEST
 */

#import "RFRuntime.h"
#import "RFInitializing.h"

@protocol RFPluginSupported;

@interface RFPlugin : NSObject
<RFInitializing>
@property (RF_WEAK, nonatomic) IBOutlet id<RFPluginSupported> master;

- (id)initWithMaster:(id<RFPluginSupported>)master;

@end

@protocol RFPluginSupported <NSObject>
// Nothing
@end
