/*!
    RFDelegateChain

    Copyright (c) 2014-2016 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    BETA
 */
#import <RFInitializing/RFInitializing.h>
#import <RFKit/RFRuntime.h>

@interface RFDelegateChain : NSObject <
    RFInitializing
>
@property (weak, nonatomic) IBOutlet id delegate;

@end

#define RFDelegateChainForwardMethods(FROM, TO) \
- (BOOL)respondsToSelector:(SEL)aSelector {\
    if ([FROM respondsToSelector:aSelector]) {\
        return YES;\
    }\
\
    if ([TO respondsToSelector:aSelector]) {\
        return YES;\
    }\
\
    return NO;\
}\
\
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {\
    NSMethodSignature* signature = [FROM methodSignatureForSelector:aSelector];\
\
    if (!signature) {\
        __strong id next = TO;\
        if ([next respondsToSelector:aSelector]) {\
            return [next methodSignatureForSelector:aSelector];\
        }\
    }\
\
    return signature;\
}\
\
- (void)forwardInvocation:(NSInvocation *)anInvocation {\
    __strong id next = TO;\
    if ([next respondsToSelector:anInvocation.selector]) {\
        [anInvocation invokeWithTarget:next];\
    }\
}\
\
- (id)forwardingTargetForSelector:(SEL)aSelector {\
    __strong id next = TO;\
    id target = [FROM forwardingTargetForSelector:aSelector];\
    if (target != next) {\
        return [next forwardingTargetForSelector:aSelector];\
    }\
    return target;\
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreserved-id-macro"
/**
 This should be private.
 */
#define _RFDelegateChainHasBlockPropertyRespondsToSelector(PROPERTY, SELECTOR) \
    if (@selector(SELECTOR) == aSelector) {\
        return (self.PROPERTY) || [self.delegate respondsToSelector:aSelector];\
    }

#pragma clang diagnostic pop
