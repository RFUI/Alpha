/*!
    UITextViewDelegateChain
    RFDelegateChain

    Copyright (c) 2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Alpha
 */
#import "RFDelegateChain.h"

@interface UITextViewDelegateChain : RFDelegateChain <
    UITextViewDelegate
>

@property (weak, nonatomic) IBOutlet id<UITextViewDelegate> delegate;

/// If thest property set, delegate methods wont called.
#pragma mark Responding to Editing Notifications
@property (copy, nonatomic) BOOL (^shouldBeginEditing)(UITextView *textView, id<UITextViewDelegate> delegate);
@property (copy, nonatomic) void (^didBeginEditing)(UITextView *textView, id<UITextViewDelegate> delegate);
@property (copy, nonatomic) BOOL (^shouldEndEditing)(UITextView *textView, id<UITextViewDelegate> delegate);
@property (copy, nonatomic) void (^didEndEditing)(UITextView *textView, id<UITextViewDelegate> delegate);

#pragma mark Responding to Text Changes
@property (copy, nonatomic) BOOL (^shouldChangeTextInRange)(UITextView *textView, NSRange range, NSString *replacementText, id<UITextViewDelegate> delegate);
@property (copy, nonatomic) void (^didChange)(UITextView *textView, id<UITextViewDelegate> delegate);

#pragma mark Responding to Selection Changes
@property (copy, nonatomic) void (^didChangeSelection)(UITextView *textView, id<UITextViewDelegate> delegate);

#pragma mark Interacting with Text Data
@property (copy, nonatomic) BOOL (^shouldInteractWithURL)(UITextView *textView, NSURL *URL, NSRange characterRange, id<UITextViewDelegate> delegate) NS_AVAILABLE_IOS(7_0);
@property (copy, nonatomic) BOOL (^shouldInteractWithTextAttachment)(UITextView *textView, NSTextAttachment *textAttachment, NSRange characterRange, id<UITextViewDelegate> delegate) NS_AVAILABLE_IOS(7_0);

@end
