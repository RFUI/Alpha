/*!
    UITableView + RFTableViewCellHeight
    RFTableViewCellHeightDelegate

    Copyright (c) 2015 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Alpha
 */

#import <UIKit/UIKit.h>

@interface UITableView (RFTableViewCellHeight)

/**
 Guarantees a cell is returned and resized properly.
 */
- (id)rf_dequeueReusableCellWithIdentifier:(NSString *)identifier;

@end
