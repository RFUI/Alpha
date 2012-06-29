//
//  RFTableViewCell.m
//  meiluohua
//
//  Created by BB9z on 12-5-29.
//  Copyright (c) 2012年 Chinamobo. All rights reserved.
//

#import "RFTableViewCell.h"

@implementation RFTableViewCell
@synthesize delegate;

+ (CGFloat)cellHeightWithData:(NSDictionary *)data {
    return 44.f;
}

- (void)configCellWithData:(NSDictionary *)data {
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

@end
