
#import "RFBackgroundImageView.h"

@interface RFBackgroundImageView ()
@property (assign, nonatomic, getter = isImageResized) BOOL imageResized;
@property (assign, nonatomic, getter = isHighlightedImageResized) BOOL highlightedImageResized;
@end

@implementation RFBackgroundImageView

+ (NSSet *)keyPathsForValuesAffectingImageResized {
    RFBackgroundImageView *this;
    return [NSSet setWithObjects:@keypath(this, image), @keypath(this, imageResizeCapInsets), nil];
}

+ (NSSet *)keyPathsForValuesAffectingHighlightedImageResized {
    RFBackgroundImageView *this;
    return [NSSet setWithObjects:@keypath(this, highlightedImage), @keypath(this, highlightedImageResizeCapInsets), nil];
}

#pragma mark - init

- (id)init {
    self = [super init];
    if (self) {
        [self onInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self onInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self onInit];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    if (self) {
        [self onInit];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    self = [super initWithImage:image highlightedImage:highlightedImage];
    if (self) {
        [self onInit];
    }
    return self;
}

- (void)onInit {
    [self addObserver:self forKeyPath:@keypath(self, imageResized) options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@keypath(self, highlightedImageResized) options:NSKeyValueObservingOptionNew context:NULL];
    
    [self applyImageChanges];
    [self applyHighlightedImageChanges];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@keypath(self, imageResized)];
    [self removeObserver:self forKeyPath:@keypath(self, highlightedImageResized)];
}

#pragma mark - 

- (void)applyImageChanges {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeObserver:self forKeyPath:@keypath(self, imageResized) context:NULL];
        if (self.image && !UIEdgeInsetsEqualToEdgeInsets(self.imageResizeCapInsets, UIEdgeInsetsZero)) {
            self.image = [self.image resizableImageWithCapInsets:self.imageResizeCapInsets];
            _imageResized = YES;
        }
        else {
            _imageResized = NO;
        }
        [self addObserver:self forKeyPath:@keypath(self, imageResized) options:NSKeyValueObservingOptionNew context:NULL];
    });
}

- (void)applyHighlightedImageChanges {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeObserver:self forKeyPath:@keypath(self, highlightedImageResized) context:NULL];
        if (self.highlightedImage && !UIEdgeInsetsEqualToEdgeInsets(self.highlightedImageResizeCapInsets, UIEdgeInsetsZero)) {
            self.highlightedImage = [self.image resizableImageWithCapInsets:self.highlightedImageResizeCapInsets];
            _highlightedImageResized = YES;
        }
        else {
            _highlightedImageResized = NO;
        }
        [self addObserver:self forKeyPath:@keypath(self, highlightedImageResized) options:NSKeyValueObservingOptionNew context:NULL];
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {    
    if (object == self) {
        if ([keyPath isEqualToString:@keypath(self, imageResized)]) {
            [self applyImageChanges];
            return;
        }
        if ([keyPath isEqualToString:@keypath(self, highlightedImageResized)]) {
            [self applyHighlightedImageChanges];
            return;
        }
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
