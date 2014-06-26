
#import "RFAsynchronousSegue.h"
#import "RFPerformance.h"

@interface RFAsynchronousSegue ()
@property (strong, nonatomic) void (^selfRetain)(void);
@end

@implementation RFAsynchronousSegue
_RFAlloctionLog

- (void)perform {
    _doutwork()
    self.selfRetain = ^(void){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        __strong __unused id obj = self;
#pragma clang diagnostic pop
    };

    if (![self shouldPerform]) {
        dout_debug(@"Should not perform")
        [self cancel];
    }
}

- (void)RFPerform {
    RFAssert(false, @"You should subclass RFAsynchronousSegue and override RFPerform.");
}

- (void)fire {
    _doutwork()
    if (self.performBlcok) {
        dout_debug(@"Perform Segue Blcok")
        self.performBlcok(self);
    }
    else {
        [self RFPerform];
    }

    self.selfRetain = nil;
}

- (void)cancel {
    _doutwork()
    self.performBlcok = nil;
    self.selfRetain = nil;
}

@end
