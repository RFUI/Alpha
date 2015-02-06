/*!
    RFSliderView

    Copyright (c) 2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    TEST
 */
#import "RFUI.h"

@interface RFSliderView : UICollectionView <
    RFInitializing
>

#pragma mark - Page

@property (nonatomic) IBInspectable NSInteger currentPage;
- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated;

@property (readonly, nonatomic) NSInteger totalPage;

#pragma mark - Auto Scroll

/**
 Default `NO`
 */
@property (assign, nonatomic) IBInspectable BOOL autoScrollEnable;
@property (assign, nonatomic) NSTimeInterval autoScrollTimeInterval;

/**
 If `YES`, will scroll to first page if the reciver reach end. Otherwise stop auto scroll.
 */
@property (assign, nonatomic) IBInspectable BOOL autoScrollAllowReverse;
@end

@interface RFSliderViewSimpleImageCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end
