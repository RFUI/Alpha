/*!
    RFBlockSelectorPerform
    RFUI

    Copyright (c) 2016 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    TEST
 */
#import <Foundation/Foundation.h>

/**
 
 Support pass block to target/selector methos.
 
 @code

 void (^block)(void) = ^{
     // do somethong
 };
 [(id)block performSelector:@selector(rf_performBlockSelector)];
 
 void (^barItemHandler)(id) = ^(id sender) {
     // handle tap
 };
 UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithTitle:@"title" style:UIBarButtonItemStyleDone target:barItemHandler action:@selector(rf_performBlockSelectorWithSender:)];
 @endcode
 */
@interface NSObject (RFBlockSelectorPerform)

- (void)rf_performBlockSelector;

- (void)rf_performBlockSelectorWithSender:(id)sender;

@end
