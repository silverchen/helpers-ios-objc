#import "NSError+Extension.h"
#import "DataUtil.h"

@implementation NSError (Extension)

- (void) showAllDetails {
	NSArray* detailedErrors = [[self userInfo] objectForKey:NSDetailedErrorsKey];
	if(![DataUtil isArrayEmpty:detailedErrors]) {
		for(NSError* detailedError in detailedErrors) {
			NSLog(@" DetailedError: %@", [detailedError userInfo]);
		}
	}
	else {
		NSLog(@"  %@", [self userInfo]);
	}
}


@end
