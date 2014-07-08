/*!
    RFDelegateChain

    Copyright (c) 2014 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    BETA
 */
#import "RFUI.h"

@interface RFDelegateChain : NSObject <
    RFInitializing
>
@property (weak, nonatomic) IBOutlet id delegate;
@end

#define RFDelegateChainForwordMethods(FROM, TO) \
- (BOOL)respondsToSelector:(SEL)aSelector {\
    if ([super respondsToSelector:aSelector]) {\
        return YES;\
    }\
\
    if ([self.delegate respondsToSelector:aSelector]) {\
        return YES;\
    }\
\
    return NO;\
}\
\
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {\
    NSMethodSignature* signature = [super methodSignatureForSelector:aSelector];\
\
    if (!signature) {\
        __strong id delegate = self.delegate;\
        if ([delegate respondsToSelector:aSelector]) {\
            return [delegate methodSignatureForSelector:aSelector];\
        }\
    }\
\
    return signature;\
}\
\
- (void)forwardInvocation:(NSInvocation *)anInvocation {\
    __strong id delegate = self.delegate;\
    if ([delegate respondsToSelector:anInvocation.selector]) {\
        [anInvocation invokeWithTarget:delegate];\
    }\
}\
\
- (id)forwardingTargetForSelector:(SEL)aSelector {\
    __strong id delegate = self.delegate;\
    id target = [super forwardingTargetForSelector:aSelector];\
    if (target != delegate) {\
        return [delegate forwardingTargetForSelector:aSelector];\
    }\
    return target;\
}

