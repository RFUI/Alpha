
#import "RFSidePanel+RFUITheme.h"

@implementation RFSidePanel (RFUITheme)


- (RFUIThemeManager *)themeManager {
    return [RFUIThemeManager sharedInstance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserverForName:MSGRFUIThemeChange object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSDictionary *rule = [self.themeManager themeRuleForKey:[self RFUIThemeRuleKey]];
        [self applyThemeWithRule:rule];
    }];
    [self applyThemeWithRule:[self.themeManager themeRuleForKey:[self RFUIThemeRuleKey]]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSGRFUIThemeChange object:nil];
}

//- (void)willMoveToSuperview:(UIView *)newSuperview {
//    [super willMoveToSuperview:newSuperview];
//    
//    if (newSuperview) {
//        [[NSNotificationCenter defaultCenter] addObserverForName:MSGRFUIThemeChange object:nil queue:nil usingBlock:^(NSNotification *note) {
//            NSDictionary *rule = [self.themeManager themeRuleForKey:[self RFUIThemeRuleKey]];
//            [self applyThemeWithRule:rule];
//        }];
//        [self applyThemeWithRule:[self.themeManager themeRuleForKey:[self RFUIThemeRuleKey]]];
//    }
//    else {
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:MSGRFUIThemeChange object:nil];
//    }
//}

- (void)applyThemeWithRule:(NSDictionary *)dict {
    RFUIThemeManager *themeManager = self.themeManager;
    id rule = nil;
    
    _RFUIThemeApplayRule(@"Separator Background") {
        self.separatorBackground.image = [themeManager imageWithName:rule];
    }
    
    _RFUIThemeApplayRule(@"Separator ON") {
        [self.separatorButtonON setImage:[themeManager imageWithName:rule] forState:UIControlStateNormal];
    }
    
    _RFUIThemeApplayRule(@"Separator ON Active") {
        [self.separatorButtonON setImage:[themeManager imageWithName:rule] forState:UIControlStateHighlighted];
    }
    
    _RFUIThemeApplayRule(@"Separator OFF") {
        [self.separatorButtonOFF setImage:[themeManager imageWithName:rule] forState:UIControlStateHighlighted];
    }
    
    _RFUIThemeApplayRule(@"Separator OFF Active") {
        [self.separatorButtonOFF setImage:[themeManager imageWithName:rule] forState:UIControlStateHighlighted];
    }
    
    _RFUIThemeApplayRule(@"Container Background") {
        self.containerBackground.image = [themeManager imageWithName:rule];
    }
}

@end
