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

@property(nonatomic) NSInteger currentPage;
@end

@interface RFSliderViewSimpleImageCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end
