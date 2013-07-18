/*!
    RFNoticeView
    RFUI

    Copyright (c) 2013 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Theory Test
 */

#import "RFUI.h"

@interface RFNoticeView : UIView
@property (RF_WEAK, nonatomic) IBOutlet UILabel *textLabel;

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)noticeWithMessage:(NSString *)message displayTimeInterval:(NSTimeInterval)timeInterval;

@end

extern NSTimeInterval const RFNoticeViewMinimumDisplayTimeInterval;
extern NSTimeInterval const RFNoticeViewDefaultDisplayTimeInterval;
