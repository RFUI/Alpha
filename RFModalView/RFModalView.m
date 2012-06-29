//
//  RFModalView.m
//  imed3
//
//  Created by BB9z on 12-3-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RFModalView.h"

@interface RFModalView ()
@end

@implementation RFModalView
@synthesize contentView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)willMoveToSuperview:(UIView *)newSuperview {
	
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
	
}

@end
