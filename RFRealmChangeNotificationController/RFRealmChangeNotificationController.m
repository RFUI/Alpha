
#import "RFRealmChangeNotificationController.h"
#import <RFKit/RFRuntime.h>

@interface RFRealmChangeNotificationController ()
@property (strong) RLMNotificationToken *notificationToken;
@property BOOL hasNotificationBlocked;
@property int lockCounter;
@property BOOL lock;
@end

@implementation RFRealmChangeNotificationController

- (void)setCollection:(id<RLMCollection>)collection {
    @synchronized(self) {
        if (_collection != collection) {
            if (_collection) {
                if (self.notificationToken) {
                    [self.notificationToken invalidate];
                    self.notificationToken = nil;
                }
            }
            _collection = collection;
            if (collection) {
                @weakify(self);
                self.notificationToken = [collection addNotificationBlock:^(id<RLMCollection>  _Nullable cl, RLMCollectionChange * _Nullable change, NSError * _Nullable error) {
                    @strongify(self);
                    if (self.changeSkipSignal) return;
                    [self performChangeHandler];
                }];
            }
        }
    }
}

- (void)performChangeHandler {
    if (self.lock) {
        self.lockCounter++;
        _dout_debug(@"%@: Skip perfrom change @%d", self.name?: @(self.hash), self.lockCounter);
        return;
    }
    self.lock = YES;

    void (^handler)(id) = self.changeProcessHandler;
    if (!handler) return;

    dispatch_async(self.changeHandlerQueue?: dispatch_get_main_queue(), ^{
        _dout_debug(@"%@: perfrom handler", self.name?: @(self.hash));
        handler(self);
    });
}

- (void)markChangeProcessFinished {
    dispatch_after_seconds(0.01, ^{
        _dout_debug(@"%@: reset lock", self.name?: @(self.hash));
        self.lock = NO;
        if (self.lockCounter > 1) {
            [self performChangeHandler];
        }
        self.lockCounter = 0;
    });
}

@end
