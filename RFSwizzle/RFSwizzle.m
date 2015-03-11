
#import "RFSwizzle.h"
#import <objc/runtime.h>
#import "dout.h"

//! REF: http://nshipster.com/method-swizzling/
//! REF: https://github.com/rentzsch/jrswizzle
bool RFSwizzleInstanceMethod(Class cls, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    if (!originalMethod) {
        dout_error(@"RFSwizzle fail: Original method %@ not found for class %@.", NSStringFromSelector(originalSelector), cls);
        return false;
    }

    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
    if (!swizzledMethod) {
        dout_error(@"RFSwizzle fail: Swizzled method %@ not found for class %@.", NSStringFromSelector(originalSelector), cls);
        return false;
    }

    BOOL didAddMethod = class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(cls, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }

    return true;
}

bool RFSwizzleClassMethod(Class cls, SEL originalSelector, SEL swizzledSelector) {
    Class metaClass = object_getClass((id)cls);
    if (!metaClass) {
        dout_error(@"RFSwizzle fail: Could not get meta class for %@.", cls);
        return false;
    }
    return RFSwizzleInstanceMethod(metaClass, originalSelector, swizzledSelector);
}
