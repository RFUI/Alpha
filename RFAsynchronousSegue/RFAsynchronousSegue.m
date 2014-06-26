
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
    _doutwork()
    if (self.performBlcok) {
        dout_debug(@"Perform Segue Blcok")
        self.performBlcok(self);
    }
}

- (void)fire {
    _doutwork()
    if ([self.sourceViewController respondsToSelector:@selector(RFSegueWillPerform:)]) {
        [self.sourceViewController RFSegueWillPerform:self];
    }
    if ([self.destinationViewController respondsToSelector:@selector(RFSegueWillAppear:)]) {
        [self.destinationViewController RFSegueWillAppear:self];
    }

    [self RFPerform];

    if ([self.sourceViewController respondsToSelector:@selector(RFSegueDidPerform:)]) {
        [self.sourceViewController RFSegueDidPerform:self];
    }
    if ([self.destinationViewController respondsToSelector:@selector(RFSegueDidAppear:)]) {
        [self.destinationViewController RFSegueDidAppear:self];
    }

    self.selfRetain = nil;
}

- (void)cancel {
    _doutwork()
    self.performBlcok = nil;
    self.selfRetain = nil;
}

@end
