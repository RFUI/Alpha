
#import "UIView+RFReusingCopy.h"
#import "RFStoryboardReusing.h"

@implementation UIView (RFReusingCopy)

//- (id)reusingCopy {
//    UIView *copyed = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
//
//    copyed.backgroundColor = self.backgroundColor;
//    copyed.hidden = self.hidden;
//    copyed.alpha = self.alpha;
//    copyed.opaque = self.opaque;
//    copyed.clipsToBounds = self.clipsToBounds;
//    copyed.clearsContextBeforeDrawing = self.clearsContextBeforeDrawing;
//    
//    copyed.userInteractionEnabled = self.userInteractionEnabled;
//    copyed.multipleTouchEnabled = self.multipleTouchEnabled;
//    copyed.exclusiveTouch = self.exclusiveTouch;
//    
//    copyed.bounds = self.bounds;
//    copyed.frame = self.frame;
//    copyed.transform = self.transform;
//    
//    copyed.autoresizingMask = self.autoresizingMask;
//    copyed.autoresizesSubviews = self.autoresizesSubviews;
//    copyed.contentMode = self.contentMode;
//    
//    // gestureRecognizers ?
//    
//    copyed.contentScaleFactor = self.contentScaleFactor;
//    
//    if ([copyed respondsToSelector:@selector(setRestorationIdentifier:)]) {
//        copyed.restorationIdentifier = self.restorationIdentifier;
//    }
//    
//    copyed.tag = self.tag;
//    
//    for (UIView *subView in self.subviews) {
//        [self addSubview:[subView reusingCopy]];
//    }
//    
//    return copyed;
//}

@end

@implementation UILabel (RFReusingCopy)

//- (id)reusingCopy {
//    UILabel *copyed = [super reusingCopy];
//    if (copyed) {
//        copyed.text = self.text;
//        if ([copyed respondsToSelector:@selector(setAttributedText:)]) {
//            copyed.attributedText = self.attributedText;
//        }
//        copyed.font = self.font;
//        copyed.textColor = self.textColor;
//        copyed.textAlignment = self.textAlignment;
//        copyed.lineBreakMode = self.lineBreakMode;
//        copyed.enabled = self.enabled;
//        
//        copyed.adjustsFontSizeToFitWidth = self.adjustsFontSizeToFitWidth;
//        if ([copyed respondsToSelector:@selector(setAdjustsLetterSpacingToFitWidth:)]) {
//            copyed.adjustsLetterSpacingToFitWidth = self.adjustsLetterSpacingToFitWidth;
//        }
//        copyed.baselineAdjustment = self.baselineAdjustment;
//        if ([copyed respondsToSelector:@selector(minimumScaleFactor)]) {
//            copyed.minimumScaleFactor = self.minimumScaleFactor;
//        }
//        copyed.numberOfLines = self.numberOfLines;
//        
//        copyed.highlightedTextColor = self.highlightedTextColor;
//        copyed.highlighted = self.highlighted;
//        
//        copyed.shadowColor = self.shadowColor;
//        copyed.shadowOffset = self.shadowOffset;
//    }
//    return copyed;
//}

@end
