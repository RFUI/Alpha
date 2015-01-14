/*!
    RFScrollViewPageControl
    RFUI

    Copyright (c) 2013-2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Alpha
 */

#import "RFUI.h"
#import "RFInitializing.h"

/**
 Usage: Just set scrollView property, no more step.
 */
@interface RFScrollViewPageControl : UIPageControl <
    RFInitializing
>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (assign, nonatomic) IBInspectable BOOL supportHalfPage;

/**
 A Boolean value that determines whether the receiver is hidden when there are less than two page.
 */
@property (assign, nonatomic) IBInspectable BOOL hidesWhenOnePage;

/**
 Call this method force update pageControl status.
 
 Generally, you don’t needs call this method manually.
 */
- (void)setNeedsUpdatePage;
@end
