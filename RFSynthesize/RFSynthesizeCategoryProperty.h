/*!
    RFSynthesizeCategoryProperty
    RFUI

    Copyright (c) 2016 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    BETA
 */
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define RFSynthesizeCategoryBoolProperty(GETTER, SETTER) \
    RFSynthesizeCategoryScalarValueProperty(GETTER, SETTER, BOOL,boolValue)

#define RFSynthesizeCategoryIntegerProperty(GETTER, SETTER) \
    RFSynthesizeCategoryScalarValueProperty(GETTER, SETTER, NSInteger,integerValue)

#define RFSynthesizeCategoryScalarValueProperty(GETTER, SETTER, TYPE, NUMBER_METHOD) \
    static char _rf_category_##GETTER;\
    - (TYPE)GETTER {\
        return [(NSNumber *)objc_getAssociatedObject(self, &_rf_category_##GETTER) NUMBER_METHOD];\
    }\
    - (void)SETTER:(TYPE)GETTER {\
        objc_setAssociatedObject(self, &_rf_category_##GETTER, @(GETTER), OBJC_ASSOCIATION_ASSIGN);\
    }

#define RFSynthesizeCategoryObjectProperty(GETTER, SETTER, TYPE, POLICY) \
    static char _rf_category_##GETTER;\
    - (TYPE)GETTER {\
        return objc_getAssociatedObject(self, &_rf_category_##GETTER);\
    }\
    - (void)SETTER:(TYPE)GETTER {\
        objc_setAssociatedObject(self, &_rf_category_##GETTER, GETTER, POLICY);\
    }
