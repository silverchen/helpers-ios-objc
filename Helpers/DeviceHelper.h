#import <Foundation/Foundation.h>
#import "DeviceHelper.h"

//Events
extern NSString *const EVENT_MENU_TAP;
extern NSString *const EVENT_APP_SESSION;

@interface DeviceHelper : NSObject

+ (void)sendEventLog:(nonnull NSString *)event;

+ (void)sendEventLog:(nonnull NSString *)event subName:(nonnull NSString *)subName;

+ (void)trackSessionStart:(nonnull NSString *)event;

+ (void)trackSessionEnd:(nonnull NSString *)event;

+ (nonnull NSString *)getAppLongVersion;

+ (nonnull NSString *)getAppVersionInNumber;

+ (BOOL)isAppStoreVer;

+ (void)sendErrLogToPapertrail:(nonnull NSString *)error api:(nonnull NSString *)api screen:(nonnull NSString *)screen file:(nonnull NSString*)file line:(nonnull NSString*)line;

+ (void)startLocationTracking:(nonnull NSString *)deliveryId;

+ (void)stopLocationTracking;

@end
