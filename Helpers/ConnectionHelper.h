#import <Foundation/Foundation.h>

@interface ConnectionHelper : NSObject

+ (instancetype)sharedInstance;

+ (void)initConnectionChecker;

+ (BOOL)hasInternetConnection;

@end
