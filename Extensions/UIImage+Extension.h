#import <UIKit/UIKit.h>

@interface UIImage (Extension)

// http://stackoverflow.com/questions/633722/how-to-make-one-color-transparent-on-a-uiimage
- (UIImage*) replaceColor:(UIColor*)color withTolerance:(float)tolerance;

@end
