//
//  RFPushSegue.m
//  meiluohua
//
//  Created by BB9z on 12-5-25.
//  Copyright (c) 2012年 Chinamobo. All rights reserved.
//

#import "RFNavigationPushSegue.h"

@implementation RFNavigationPushSegue

- (void)RFPerform {
    [[(UIViewController *)self.sourceViewController navigationController] pushViewController:self.destinationViewController animated:YES];
}

@end
