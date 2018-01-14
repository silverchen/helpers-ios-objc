#import <Foundation/Foundation.h>

@interface ConnectionManager : NSObject

+ (instancetype)sharedInstance;

- (BOOL)hasInternetConnection;

@end
