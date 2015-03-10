
#import "RFSwizzle.h"

@import ObjectiveC.runtime;

bool RFSwizzleInstanceMethod(Class cls, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    if (!originalMethod) {
        dout_error(@"RFSwizzle fail: Original method %@ not found for class %@.", NSStringFromSelector(originalSelector), cls);
        return false;
    }

    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);

    BOOL didAddMethod = class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));

    if (didAddMethod) {
        class_replaceMethod(cls, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }

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
