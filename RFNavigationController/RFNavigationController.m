
#import "RFNavigationController.h"

static RFNavigationController *RFNavigationControllerGlobalInstance;

@interface RFNavigationController ()
@end

@implementation RFNavigationController
RFUIInterfaceOrientationSupportNavigation

+ (instancetype)globalNavigationController {
    return RFNavigationControllerGlobalInstance;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!RFNavigationControllerGlobalInstance) {
        RFNavigationControllerGlobalInstance = self;
    }
}

@end
