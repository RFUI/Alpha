
#import "RFAPIDefine.h"
#import "RFInitializing.h"
#import "AFURLRequestSerialization.h"
#import "AFURLResponseSerialization.h"

@class RFAPI;

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

#pragma mark - RFAPI Support

@property (strong, nonatomic) id<AFURLRequestSerialization> defaultRequestSerializer;

@property (strong, nonatomic) id<AFURLResponseSerialization> defaultResponseSerializer;

- (NSURL *)requestURLForDefine:(RFAPIDefine *)define error:(NSError *__autoreleasing *)error;

- (id)requestSerializerForDefine:(RFAPIDefine *)define;
- (id)responseSerializerForDefine:(RFAPIDefine *)define;

@end

@interface RFAPIDefine (RFConfigFile)
- (id)initWithRule:(NSDictionary *)rule name:(NSString *)name;

@end
