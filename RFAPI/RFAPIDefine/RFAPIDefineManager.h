
#import "RFAPIDefine.h"
#import "RFInitializing.h"

@class RFAPI;

@interface RFAPIDefineManager : NSObject <RFInitializing>
@property (weak, nonatomic) RFAPI *master;

/**
 This property could only set by `mergeWithRules:` with a `DEFAULT` rule. If you change it’s property, you must call `setNeedsUpdateDefaultDefine` to make these changes take effect.
 */
@property (readonly, nonatomic) RFAPIDefine *defaultDefine;
- (void)setNeedsUpdateDefaultDefine;

- (void)mergeWithRules:(NSDictionary *)rules;
- (RFAPIDefine *)defineForName:(NSString *)defineName;

#pragma mark - RFAPI Support

- (NSURL *)requestURLForDefine:(RFAPIDefine *)define error:(NSError *__autoreleasing *)error;

- (id)requestSerializerForDefine:(RFAPIDefine *)define;
- (id)responseSerializerForDefine:(RFAPIDefine *)define;

@end

@interface RFAPIDefine (RFConfigFile)
- (id)initWithRule:(NSDictionary *)rule name:(NSString *)name;

@end
