/*!
    RFAsynchronousSegue

    Copyright (c) 2014, 2016 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php
 */
#import "RFSegue.h"

@interface RFAsynchronousSegue : RFSegue

/**
 What to do when segue performs.
 
 Set this property or overwrite RFPerform.
 */
@property (nullable) void (^performBlcok)(__kindof RFAsynchronousSegue *__nonnull segue);

/**
 Performs the reciver.
 
 @return NO if segue is canceled or has performed.
 */
- (BOOL)fire;

/**
 Mark the reciver wont perform and then release it.
 
 @return NO if segue is canceled or has performed.
 */
- (BOOL)cancel;
@end
