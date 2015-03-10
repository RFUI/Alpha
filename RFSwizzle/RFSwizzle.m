
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

    class_addMethod(cls, originalSelector, class_getMethodImplementation(cls, originalSelector), method_getTypeEncoding(originalMethod));
    class_addMethod(cls, swizzledSelector, class_getMethodImplementation(cls, swizzledSelector), method_getTypeEncoding(swizzledMethod));
    method_exchangeImplementations(class_getInstanceMethod(cls, originalSelector), class_getInstanceMethod(cls, swizzledSelector));

    bool impMatch = (method_getImplementation(originalMethod) == method_getImplementation(class_getInstanceMethod(cls, swizzledSelector)));
    if (!impMatch) {
        dout_error(@"RFSwizzle fail: Method implementation not match after swizzling.");
        return false;
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
