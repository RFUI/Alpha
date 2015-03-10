/*!
    RFSwizzle

    Copyright (c) 2015 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    TEST
 */
#import <Foundation/Foundation.h>

/**
 @return true if operation succeeded.
 */
FOUNDATION_EXPORT bool RFSwizzleInstanceMethod(Class cls, SEL originalSelector, SEL swizzledSelector);

/**
 @return true if operation succeeded.
 */
FOUNDATION_EXPORT bool RFSwizzleClassMethod(Class cls, SEL originalSelector, SEL swizzledSelector);
