// TEST

#import "AFHTTPRequestOperationManager.h"

@class RFMessageManager;

@interface RFAPI : AFHTTPRequestOperationManager

@property (strong, nonatomic) RFMessageManager *networkActivityIndicatorManager;

/** 显示错误的统一方法

 @param error 显示错误信息的对象
 @param title 提示标题，可选
 */
- (void)alertError:(NSError *)error title:(NSString *)title;

@end
