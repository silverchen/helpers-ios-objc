#import <UIKit/UIKit.h>

@interface UIButton (Extension)

- (void) setBackgroundColor:(UIColor *)color forState:(UIControlState)state;
- (UIColor *) backgroundColorForState:(UIControlState)state;

- (void) setBorderWidth:(NSNumber *)width forState:(UIControlState)state;
- (NSNumber *) borderWidthForState:(UIControlState)state;

- (void) setBorderColor:(UIColor *)color forState:(UIControlState)state;
- (UIColor *) borderColorForState:(UIControlState)state;

- (void) setTitleFont:(UIFont *)font forState:(UIControlState)state;
- (UIFont *) titleFontForState:(UIControlState)state;
@end
