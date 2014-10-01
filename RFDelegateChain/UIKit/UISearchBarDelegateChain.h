/*!
    UISearchBarDelegateChain
    RFDelegateChain

    Copyright (c) 2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Alpha
 */
#import "RFDelegateChain.h"

@interface UISearchBarDelegateChain : RFDelegateChain <
    UISearchBarDelegate
>

@property (weak, nonatomic) IBOutlet id<UISearchBarDelegate> delegate;

/// If thest property set, delegate methods wont called.
#pragma mark Editing Text
@property (copy, nonatomic) void (^didChange)(UISearchBar *searchBar, NSString *searchText, id<UISearchBarDelegate> delegate);
@property (copy, nonatomic) BOOL (^shouldChangeTextInRange)(UISearchBar *searchBar, NSRange range, NSString *replacementText, id<UISearchBarDelegate> delegate);
@property (copy, nonatomic) BOOL (^shouldBeginEditing)(UISearchBar *searchBar, id<UISearchBarDelegate> delegate);
@property (copy, nonatomic) void (^didBeginEditing)(UISearchBar *searchBar, id<UISearchBarDelegate> delegate);
@property (copy, nonatomic) BOOL (^shouldEndEditing)(UISearchBar *searchBar, id<UISearchBarDelegate> delegate);
@property (copy, nonatomic) void (^didEndEditing)(UISearchBar *searchBar, id<UISearchBarDelegate> delegate);

#pragma mark Clicking Buttons
@property (copy, nonatomic) void (^bookmarkButtonClicked)(UISearchBar *searchBar, id<UISearchBarDelegate> delegate);
@property (copy, nonatomic) void (^cancelButtonClicked)(UISearchBar *searchBar, id<UISearchBarDelegate> delegate);
@property (copy, nonatomic) void (^searchButtonClicked)(UISearchBar *searchBar, id<UISearchBarDelegate> delegate);
@property (copy, nonatomic) void (^resultsListButtonClicked)(UISearchBar *searchBar, id<UISearchBarDelegate> delegate);

#pragma mark Scope Button
@property (copy, nonatomic) void (^selectedScopeButtonIndexDidChange)(UISearchBar *searchBar, NSInteger selectedScope, id<UISearchBarDelegate> delegate);

@end
