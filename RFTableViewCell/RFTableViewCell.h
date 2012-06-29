//
//  RFTableViewCell.h
//  meiluohua
//
//  Created by BB9z on 12-5-29.
//  Copyright (c) 2012年 Chinamobo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RFTableViewCellDelegate;

@interface RFTableViewCell : UITableViewCell

@property (RF_WEAK, nonatomic) id<RFTableViewCellDelegate> delegate;

+ (CGFloat)cellHeightWithData:(NSDictionary *)data;
@end

@protocol RFTableViewCellDelegate <NSObject>
    

@end
