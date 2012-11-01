
#import "RFUI.h"

@class RFImageGallery, RFImageGalleryScrollContainer, RFImageGalleryCell;


/// 
@protocol RFImageGalleryDataSource <NSObject>

@required
- (UIImage *)imageGallery:(RFImageGallery *)gallery imageAtIndex:(NSUInteger)index;
- (NSUInteger)numberOfImageInGallery:(RFImageGallery *)gallery;
@end


/// 
@interface RFImageGallery : UIScrollView
<UIScrollViewDelegate>

@property (RF_WEAK, nonatomic) IBOutlet id<RFImageGalleryDataSource> dataSource;
- (void)reloadData;

@property (assign, nonatomic) NSUInteger index;

/// 动画还不支持
- (void)scrollToIndex:(NSUInteger)toIndex animated:(BOOL)animated;

@property (RF_STRONG, nonatomic) IBOutlet RFImageGalleryScrollContainer *scrollContainer;
@end


/// 
@interface RFImageGalleryScrollContainer : UIView
@property (RF_WEAK, nonatomic) IBOutlet RFImageGallery *master;
- (id)initWithMaster:(RFImageGallery *)master;

@property (RF_STRONG, nonatomic) IBOutlet RFImageGalleryCell *lCell;  // Left
@property (RF_STRONG, nonatomic) IBOutlet RFImageGalleryCell *mCell;  // Middle
@property (RF_STRONG, nonatomic) IBOutlet RFImageGalleryCell *rCell;  // Right
@end


/// 
@interface RFImageGalleryCell : UIScrollView
<UIScrollViewDelegate>
@property (RF_STRONG, nonatomic) IBOutlet UIImageView *imageView;
@property (assign, nonatomic) NSUInteger index;

- (void)setImage:(UIImage *)image;
@end
