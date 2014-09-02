// TEST

#import "RFUI.h"

typedef NS_ENUM(short, RFRefreshControlStatus) {
    RFRefreshControlStatusWaiting = 0,
    RFRefreshControlStatusPossible,
    RFRefreshControlStatusReady,
    RFRefreshControlStatusFetching,
    RFRefreshControlStatusStopping,
    RFRefreshControlStatusEmpty,
    RFRefreshControlStatusEnd
};

@interface RFRefreshControl : UIControl

@end
