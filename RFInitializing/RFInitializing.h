/*!
    RFInitializing
    Stop writing init methods again and again.

    Copyright (c) 2013 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    TEST
 */

#import <Foundation/Foundation.h>

/**
 
 You should only call `onInit` and `afterInit` in root object which conforms to this protocol.
 Here is a example:
 
 @code
 
- (id)init {
    self = [super init];
    if (self) {
        [self onInit];
        [self performSelector:@selector(afterInit) withObject:self afterDelay:0];
    }
    return self;
}
 
 @endcode
 
 
 In subclass, you must not call these method in init method. You may implemente onInit or afterInit for customize. And you should call super at some point in your implementation if you override onInit or afterInit. eg:
 
 @code

- (id)init {
    self = [super init];
    if (self) {
        // Don't call onInit or afterInit.
    }
    return self;
}
 
- (void)onInit {
    [super onInit];
    // Something
}
 
- (void)afterInit {
    [super afterInit];
    // Something
}

 @endcode
 
 */

@protocol RFInitializing <NSObject>
@required
- (void)onInit;

- (void)afterInit;
@end
