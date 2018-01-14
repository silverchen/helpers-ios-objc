#import "UIView+Extension.h"

@implementation UIView (Extension)

- (id) findFirstSubviewOfType:(Class)type {
	for(UIView *view in self.subviews) {
		if([view isKindOfClass:type])
			return view;
		id res = [view findFirstSubviewOfType:type];
		if(res)
			return res;
	}

	return nil;
}

@end
