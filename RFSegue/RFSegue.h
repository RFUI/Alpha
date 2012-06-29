/*!
    RFSegue
    RFUI
 
    ver -.-.-
 */

#import <UIKit/UIKit.h>

@protocol RFSegueSourceDelegate;
@protocol RFSegueDestinationDelegate;

@interface RFSegue : UIStoryboardSegue

@property (RF_STRONG, nonatomic) NSDictionary *userInfo;

- (id)initWithIdentifier:(NSString *)identifier source:(UIViewController<RFSegueSourceDelegate> *)source destination:(UIViewController<RFSegueDestinationDelegate> *)destination;

/// Should not be overrided, see RFPerform
- (void)perform;

/**
    Subclasses should always override this method instead of [RFSegue perform] and use it to perform the animations from the views in sourceViewController to the views in destinationViewController.
 */
- (void)RFPerform;
@end

#pragma mark -
@protocol RFSegueSourceDelegate <NSObject>
@optional
- (BOOL)RFSegueShouldPerform:(RFSegue *)segue;
- (void)RFSegueWillPerform:(RFSegue *)segue;
- (void)RFSegueDidPerformed:(RFSegue *)segue;
@end

#pragma mark -
@protocol RFSegueDestinationDelegate <NSObject>
@optional
- (void)RFSegueDidPerformed:(RFSegue *)segue userInfo:(NSDictionary *)userInfo;

@end
