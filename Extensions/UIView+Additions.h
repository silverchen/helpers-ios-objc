#import <UIKit/UIKit.h>

@interface UIView (Additions)

@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGSize size;
@property (nonatomic, readonly) CGPoint contentCenter;

- (UIImage *)capture;

- (void)fadeInWithDuration:(CGFloat)duration;
- (void)fadeOutWithDuration:(CGFloat)duration;
- (void)fadeInWithDuration:(CGFloat)duration delay:(CGFloat)delay;
- (void)fadeOutWithDuration:(CGFloat)duration delay:(CGFloat)delay;
- (void)fadeToAlpha:(CGFloat)alpha withDuration:(CGFloat)duration;

- (void)addMotionEffectsRelativeValue:(CGFloat)value;

- (UIView *)findAndResignFirstResponder;

@end
