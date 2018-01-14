#import "UISearchBar+Extension.h"
#import "UIView+Extension.h"

@implementation UISearchBar (Extension)

- (UITextField *) textField {
	return [self findFirstSubviewOfType:[UITextField class]];
}

@end
