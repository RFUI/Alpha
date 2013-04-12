/*!
	RFUI
	RFGridView
	
	ver 0.3.0
 */
#import "RFUI.h"

@class RFGridViewCellContainer;

@interface RFGridView : UIScrollView
- (id)initWithFrame:(CGRect)aRect;
- (void)awakeFromNib;

/// Called in initWithFrame: and awakeFromNib
- (void)applyDefaultSettings;

/// Views added to this view will layout as grid cell.
/// It will be auto resize.
@property (strong, nonatomic) IBOutlet RFGridViewCellContainer *container;

/// ScrollView`s scroll direction
@property (nonatomic) RFUIOrientation layoutOrientation;
@property (nonatomic) BOOL layoutAnimated;

@property (nonatomic) CGSize cellSize;
@property (nonatomic) RFMargin cellMargin;
@property (nonatomic) RFPadding containerPadding;

/** ScrollView padding
    If you load RFGridView from a nib, it will set according to container`s frame when awakeFromNib called.
 */
@property (nonatomic) RFPadding padding;

/// Leave for future use.
/// Current is center.
@property (nonatomic) RFAlignmentAnchor cellLayoutAlignment;

/**
    Call this after you modify cell's property.
    You don`t need call this manully when grid view size changed.
 */
- (void)setNeedsLayout;

@end

@interface RFGridViewCellContainer : UIView
@property (RF_WEAK, nonatomic) RFGridView *master;
@end

extern CGSize DEFAULT_RFGridViewCellSize;
