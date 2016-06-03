/*!
    RFAPIDefineManager
    RFAPI

    Copyright (c) 2014-2016 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    Alpha
 */
#import "RFAPIDefine.h"
#import "RFInitializing.h"

@class RFAPI;
@protocol AFURLRequestSerialization;
@protocol AFURLResponseSerialization;

@interface RFAPIDefineManager : NSObject <RFInitializing>
@property (weak, nonatomic) RFAPI *master;

/**
 You cannot get default rule with RFAPIDefineDefaultKey.
 */
@property (readonly, nonatomic) NSMutableDictionary *defaultRule;

/**
 If you make any change in the default rule, you should call this method to make these changes take effect.
 */
- (void)setNeedsUpdateDefaultRule;

- (void)setDefinesWithRulesInfo:(NSDictionary *)rulesDictionary;

/**
 Returns the define object with the specified name.
 
 You cannot get default rule with this method.

 @return A define object with it’s name.
 */
- (RFAPIDefine *)defineForName:(NSString *)defineName;

#pragma mark - Access raw rule values
// You cannot modify default rule with these methods.

- (id)valueForRule:(NSString *)key defineName:(NSString *)defineName;

- (void)setValue:(id)value forRule:(NSString *)key defineName:(NSString *)defineName;
- (void)removeRule:(NSString *)key withDefineName:(NSString *)defineName;

#pragma mark - Authorization values

@property (readonly, nonatomic) NSMutableDictionary *authorizationHeader;
@property (readonly, nonatomic) NSMutableDictionary *authorizationParameters;


#pragma mark - RFAPI Support

@property (strong, nonatomic) id<AFURLRequestSerialization> defaultRequestSerializer;

@property (strong, nonatomic) id<AFURLResponseSerialization> defaultResponseSerializer;

- (NSURL *)requestURLForDefine:(RFAPIDefine *)define parameters:(NSMutableDictionary *)parameters error:(NSError *__autoreleasing *)error;

- (id)requestSerializerForDefine:(RFAPIDefine *)define;
- (id)responseSerializerForDefine:(RFAPIDefine *)define;

@end

@interface RFAPIDefine (RFConfigFile)
- (instancetype)initWithRule:(NSDictionary *)rule name:(NSString *)name;

@end
