#import "NSObject+PropertyList.h"

@implementation NSObject (PropertyList)

- (BOOL) isValidPropertyListType {
	if([self isKindOfClass:[NSDictionary class]]) {
		for(NSString *key in [(NSDictionary *)self allKeys]) {
			if(! [[self valueForKey:key] isValidPropertyListType])
				return false;
		}
		return true;
	}
	else if([self isKindOfClass:[NSArray class]]) {
		for(id object in (NSArray *)self) {
			if(! [object isValidPropertyListType])
				return false;
		}

		return true;
	}
	else
		return [self isKindOfClass:[NSDate class]] || [self isKindOfClass:[NSNumber class]]
		|| [self isKindOfClass:[NSString class]] || [self isKindOfClass:[NSData class]];
}

@end
