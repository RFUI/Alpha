/*!
    UITextFiledDelegateChain
    RFDelegateChain

    Copyright (c) 2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Alpha
 */
#import "RFDelegateChain.h"

@interface UITextFiledDelegateChain : RFDelegateChain <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet id<UITextFieldDelegate> delegate;

/// If thest property set, delegate methods wont called.
#pragma mark Managing Editing
@property (copy, nonatomic) BOOL (^shouldBeginEditing)(UITextField *textField, id<UITextFieldDelegate> delegate);
@property (copy, nonatomic) void (^didBeginEditing)(UITextField *textField, id<UITextFieldDelegate> delegate);
@property (copy, nonatomic) BOOL (^shouldEndEditing)(UITextField *textField, id<UITextFieldDelegate> delegate);
@property (copy, nonatomic) void (^didEndEditing)(UITextField *textField, id<UITextFieldDelegate> delegate);

#pragma mark Editing the Text Field’s Text
@property (copy, nonatomic) BOOL (^shouldChangeCharacters)(UITextField *textField, NSRange inRange, NSString *replacementString, id<UITextFieldDelegate> delegate);
@property (copy, nonatomic) BOOL (^shouldClear)(UITextField *textField, id<UITextFieldDelegate> delegate);
@property (copy, nonatomic) BOOL (^shouldReturn)(UITextField *textField, id<UITextFieldDelegate> delegate);

@end
