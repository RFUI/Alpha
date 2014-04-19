
#import "RFAPIDefine.h"
#import "RFInitializing.h"

@class RFAPI;

@interface RFAPIDefineManager : NSObject <RFInitializing>
@property (weak, nonatomic) RFAPI *master;

/**
 */
@property (readonly, nonatomic) NSMutableDictionary *defaultRule;

/**
 If you make any change in the default rule, you should call this method to make these changes take effect.
 */
- (void)setNeedsUpdateDefaultRule;

- (void)mergeWithRules:(NSDictionary *)rules;

/**
 Returns the define object  with the specified name.
 
 @return A define object with it’s name.
 */
- (RFAPIDefine *)defineForName:(NSString *)defineName;

#pragma mark - RFAPI Support

- (NSURL *)requestURLForDefine:(RFAPIDefine *)define error:(NSError *__autoreleasing *)error;

- (id)requestSerializerForDefine:(RFAPIDefine *)define;
- (id)responseSerializerForDefine:(RFAPIDefine *)define;

@end

@interface RFAPIDefine (RFConfigFile)
- (id)initWithRule:(NSDictionary *)rule name:(NSString *)name;

@end
