/*!
    RFGridView
    RFUI

    Copyright (c) 2012-2013, 2016, 2019 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php
 */
#import <RFInitializing/RFInitializing.h>
#import <RFKit/RFKit.h>

@class RFGridViewCellContainer;

@interface RFGridView : UIScrollView <
    RFInitializing
>

- (void)awakeFromNib;

/// Views added to this view will layout as grid cell.
/// It will be auto resize.
@property (nonatomic, strong) IBOutlet RFGridViewCellContainer *container;

/// ScrollView`s scroll direction
@property (nonatomic) UILayoutConstraintAxis layoutOrientation;
@property (nonatomic) IBInspectable BOOL layoutAnimated;

/// Default {20, 20}
@property (nonatomic) IBInspectable CGSize cellSize;
@property (nonatomic) UIEdgeInsets cellMargin;
@property (nonatomic) UIEdgeInsets containerPadding;

/**
 ScrollView padding

 If you load RFGridView from a nib, it will set according to container`s frame when awakeFromNib called.
 */
@property (nonatomic) UIEdgeInsets padding;

/// Leave for future use.
/// Current is center.
@property (nonatomic) RFAlignmentAnchor cellLayoutAlignment __unavailable;

/**
 Call this after you modify cell's property.
 You don`t need call this manully when grid view size changed.
 */
- (void)setNeedsLayout;

@end

@interface RFGridViewCellContainer : UIView
@property (nonatomic, weak) IBOutlet RFGridView *master;
@end
