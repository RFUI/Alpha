/*!
    RFSliderView

    Copyright (c) 2014, 2016-2017 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php
 */
#import "RFUI.h"

@interface RFSliderView : UICollectionView <
    RFInitializing
>

#pragma mark - Page

/**
 Will be -1 when view width is zero.
 */
@property (nonatomic) IBInspectable NSInteger currentPage;

- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated;

/**
 Will be -1 when view width is zero.
 */
@property (nonatomic, readonly) NSInteger totalPage;

#pragma mark - Auto Scroll

/**
 Default `NO`. If autoScrollAllowReverse is NO, this property will become NO after page reach end.
 */
@property (nonatomic) IBInspectable BOOL autoScrollEnable;
@property (nonatomic) NSTimeInterval autoScrollTimeInterval;

/**
 If `YES`, will scroll to first page if the reciver reach end. Otherwise stop auto scroll.
 */
@property IBInspectable BOOL autoScrollAllowReverse;
@end

@interface RFSliderViewSimpleImageCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@end
