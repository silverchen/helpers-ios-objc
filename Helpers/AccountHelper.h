#import <Foundation/Foundation.h>

@interface AccountHelper : NSObject

+ (instancetype)sharedInstance;

- (BOOL)isLoggedIn;

- (void)logout:(void (^)(BOOL success))completion;

- (BOOL)isSpecial;

- (void)clearCache;

@end
