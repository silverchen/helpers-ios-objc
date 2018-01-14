#import <Foundation/Foundation.h>

extern NSString * const kBaseViewLoaded;

@interface NotificationManager : NSObject

+ (instancetype)sharedInstance;

- (void)parseNotification:(NSDictionary*)userInfo shouldRedirect:(BOOL)redirect;
- (void)submitPushToken;

@end
