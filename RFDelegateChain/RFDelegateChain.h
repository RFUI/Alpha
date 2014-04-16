/*!
    RFDelegateChain

    Copyright (c) 2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Alpha
 */

#import "RFUI.h"

@interface RFDelegateChain : NSObject <
    RFInitializing
>
@property (weak, nonatomic) IBOutlet id delegate;
@end
