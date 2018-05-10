/*!
 RFCallbackControl
 RFAlpha
 
 Copyright © 2018 RFUI. All rights reserved.
 https://github.com/RFUI/Alpha
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */
#import <RFKit/RFRuntime.h>

@class RFCallback;

/**
 
 */
@interface RFCallbackControl<__covariant ObjectType>: NSObject

@property (readonly) BOOL hasCallback;
@property (nonnull) Class objectClass;

- (nullable ObjectType)addCallbackWithTarget:(nonnull id)target selector:(nonnull SEL)selector refrenceObject:(nonnull id)object;

- (nullable ObjectType)addCallback:(nonnull id)callback refrenceObject:(nonnull id)object;

- (void)removeCallback:(nullable ObjectType)callbackRefrence;
- (void)removeCallbackOfRefrenceObject:(nullable id)object;
- (void)removeAllCallbacks;

- (void)performWithSource:(nullable id)source filter:(NS_NOESCAPE BOOL (^__nullable)(ObjectType __nonnull obj, NSUInteger idx, BOOL *__nonnull stop))predicate;

@end

/**
 
 */
@interface RFCallback: NSObject

/**
 一个弱引用的对象，当这个对象被释放后，callback 对象视为无效
 */
@property (nullable, weak) id refrenceObject;

@property (nullable, weak) id target;

/**
 非空时，向 target 发送 selector 消息，会带一个可为空的 source 参数
 */
@property (nullable) SEL selector;

/**
 可变的 block 参数，当 target 或 selector 为空时调用
 */
@property (nullable) id block;

/**
 可选调用多少次后失效被移除。默认 0，不会失效
 */
@property int liveCounter;

/**
 子类重写
 
 因为回调 block 参数是可变的，如何传参只能看具体业务，默认无参数
 */
- (void)perfromBlock:(nonnull id)block source:(nullable id)source;

@end
