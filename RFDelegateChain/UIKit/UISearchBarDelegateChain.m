
#import "UISearchBarDelegateChain.h"

@interface UISearchBarDelegateChain ()
@end

@implementation UISearchBarDelegateChain
@dynamic delegate;

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (self.didChange) {
        self.didChange(searchBar, searchText, self.delegate);
        return;
    }

    if ([self.delegate respondsToSelector:@selector(searchBar:textDidChange:)]) {
        [self.delegate searchBar:searchBar textDidChange:searchText];
    }
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (self.shouldChangeTextInRange) {
        return self.shouldChangeTextInRange(searchBar, range, text, self.delegate);
    }

    if ([self.delegate respondsToSelector:@selector(searchBar:shouldChangeTextInRange:replacementText:)]) {
        return [self.delegate searchBar:searchBar shouldChangeTextInRange:range replacementText:text];
    }
    return YES;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (self.shouldBeginEditing) {
        return self.shouldBeginEditing(searchBar, self.delegate);
    }

    if ([self.delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)]) {
        return [self.delegate searchBarShouldBeginEditing:searchBar];
    }
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if (self.didBeginEditing) {
        self.didBeginEditing(searchBar, self.delegate);
        return;
    }

    if ([self.delegate respondsToSelector:@selector(searchBarTextDidBeginEditing:)]) {
        [self.delegate searchBarTextDidBeginEditing:searchBar];
    }
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    if (self.shouldEndEditing) {
        return self.shouldEndEditing(searchBar, self.delegate);
    }

    if ([self.delegate respondsToSelector:@selector(searchBarShouldEndEditing:)]) {
        return [self.delegate searchBarShouldEndEditing:searchBar];
    }
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if (self.didEndEditing) {
        self.didEndEditing(searchBar, self.delegate);
        return;
    }

    if ([self.delegate respondsToSelector:@selector(searchBarTextDidEndEditing:)]) {
        [self.delegate searchBarTextDidEndEditing:searchBar];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (self.searchButtonClicked) {
        self.searchButtonClicked(searchBar, self.delegate);
        return;
    }

    if ([self.delegate respondsToSelector:@selector(searchBarSearchButtonClicked:)]) {
        [self.delegate searchBarSearchButtonClicked:searchBar];
    }
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    if (self.bookmarkButtonClicked) {
        self.bookmarkButtonClicked(searchBar, self.delegate);
        return;
    }

    if ([self.delegate respondsToSelector:@selector(searchBarBookmarkButtonClicked:)]) {
        [self.delegate searchBarBookmarkButtonClicked:searchBar];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if (self.cancelButtonClicked) {
        self.cancelButtonClicked(searchBar, self.delegate);
        return;
    }

    if ([self.delegate respondsToSelector:@selector(searchBarCancelButtonClicked:)]) {
        [self.delegate searchBarCancelButtonClicked:searchBar];
    }
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar {
    if (self.resultsListButtonClicked) {
        self.resultsListButtonClicked(searchBar, self.delegate);
        return;
    }

    if ([self.delegate respondsToSelector:@selector(searchBarResultsListButtonClicked:)]) {
        [self.delegate searchBarResultsListButtonClicked:searchBar];
    }
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    if (self.selectedScopeButtonIndexDidChange) {
        self.selectedScopeButtonIndexDidChange(searchBar, selectedScope, self.delegate);
        return;
    }

    if ([self.delegate respondsToSelector:@selector(searchBar:selectedScopeButtonIndexDidChange:)]) {
        [self.delegate searchBar:searchBar selectedScopeButtonIndexDidChange:selectedScope];
    }
}

@end
