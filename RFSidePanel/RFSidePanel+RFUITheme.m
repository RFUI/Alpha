
#import "RFSidePanel+RFUITheme.h"

@implementation RFSidePanel (RFUITheme)

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    douts(@"Load in RFUITheme");
    RFUIThemeManager *themeManager = [RFUIThemeManager sharedInstance];

    [[NSNotificationCenter defaultCenter] addObserverForName:MSGRFUIThemeChange object:nil queue:nil usingBlock:^(NSNotification *note) {
        douto([themeManager.currentBundle infoDictionary])
        NSDictionary *rule = [themeManager themeRuleForKey:[self RFUIThemeRuleKey]];
        [self applyThemeWithRule:rule];
    }];
    [self applyThemeWithRule:[themeManager themeRuleForKey:[self RFUIThemeRuleKey]]];
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
    RFUIThemeManager *themeManager = [RFUIThemeManager sharedInstance];
    id rule = nil;
    
    #define _RFSidePanelRule(key) rule = dict[key]; if (rule)
    
    _RFSidePanelRule(@"Separator Background") {
        self.separatorBackground.image = [themeManager imageWithName:rule];
    }
    
    _RFSidePanelRule(@"Separator ON") {
        [self.separatorButtonON setImage:[themeManager imageWithName:rule] forState:UIControlStateNormal];
    }
    
    _RFSidePanelRule(@"Separator ON Active") {
        [self.separatorButtonON setImage:[themeManager imageWithName:rule] forState:UIControlStateHighlighted];
    }
    
    _RFSidePanelRule(@"Separator OFF") {
        [self.separatorButtonOFF setImage:[themeManager imageWithName:rule] forState:UIControlStateHighlighted];
    }
    
    _RFSidePanelRule(@"Separator OFF Active") {
        [self.separatorButtonOFF setImage:[themeManager imageWithName:rule] forState:UIControlStateHighlighted];
    }
    
    _RFSidePanelRule(@"Container Background") {
        douto(rule)
        douto([themeManager imageWithName:rule])
        self.containerBackground.image = [themeManager imageWithName:rule];
    }
        
    #undef _RFSidePanelRule
}

@end
