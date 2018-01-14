#import "DeviceHelper.h"
#import "Mixpanel/Mixpanel.h"
#import "BITHockeyHelper.h"
#import "UserPreferences.h"
#import "SDVersion.h"
#import <CoreLocation/CoreLocation.h>
#import "AGDispatcherHeaders.h"
#import "UIHelper.h"
#import "APIHelper.h"

#define CLCOORDINATE_EPSILON 0.005f

NSString *const EVENT_MENU_TAP = @"Tap on menu";
NSString *const EVENT_APP_SESSION = @"App session";

@implementation DeviceHelper

static AGLocationDispatcher *locationDispatcher;
static NSTimer *timer;

SINGLETON_MACRO

+ (void)startLocationTracking:(NSString *)deliveryId {
    // Fix AGLocationDispatcher bug where interval is not working
    if (!timer) {
        [self sendGPSCoordinateToServer:deliveryId];
        timer = [NSTimer scheduledTimerWithTimeInterval:5.f * 60.f target:[DeviceHelper class] selector:@selector(startLocation:) userInfo:deliveryId repeats:YES];
    }
}

+ (void)startLocation:(NSTimer *)timer {
    NSString *deliveryId;

    if (timer && timer.userInfo) {
        deliveryId = timer.userInfo;
    } else {
        return;
    }

    [self sendGPSCoordinateToServer:deliveryId];
}

+ (void)stopLocationTracking {
    if (!locationDispatcher) {
        [locationDispatcher stopUpdatingLocation];
    }

    [timer invalidate];
    timer = nil;
}

+ (void)sendGPSCoordinateToServer:(NSString *)deliveryId {
    if (!locationDispatcher) {
        // Setup
        locationDispatcher = [[AGLocationDispatcher alloc] initWithUpdatingInterval:5.f * 60.f andDesiredAccuracy:kAGHorizontalAccuracyNeighborhood]; // 5 min interval
        [locationDispatcher setLocationUpdateBackgroundMode:AGLocationBackgroundModeSignificantLocationChanges];
        //[[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    } else {
        [locationDispatcher stopUpdatingLocation];
    }

    if ([AGLocationDispatcher locationServicesEnabled]){
        [locationDispatcher currentLocationWithBlock:^(CLLocationManager *manager, AGLocation *newLocation, AGLocation *oldLocation) {
            [locationDispatcher stopUpdatingLocation];
            if (newLocation) {
                if (oldLocation) {
                    if (fabs(newLocation.coordinate.latitude - oldLocation.coordinate.latitude) <= CLCOORDINATE_EPSILON && fabs(newLocation.coordinate.longitude - oldLocation.coordinate.longitude) <= CLCOORDINATE_EPSILON) {
                        // no change
                        return;
                    }
                }

                NSDictionary *param = @{@"location":[NSString stringWithFormat:@"lat:%f,long:%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude]};

                [[APIHelper sharedInstance] sendRequestForURL:[APIHelper getDeliveryCheckinUrlById:deliveryId] parameters:param method:METHOD_PUT success:^(NSHTTPURLResponse *response, id responseObject) {
                    NSLog(@"%@", responseObject);
                } failure:^(NSError *error) {
                    NSLog(@"%@", error.userInfo);
                    [UIHelper showErrorDialog:error api:[APIHelper getDeliveryCheckinUrlById:deliveryId] screen:@"Background process - location tracking" file:[NSString stringWithFormat:@"%s", (strrchr(__FILE__, '/') ?: __FILE__ - 1) + 1] line:[NSString stringWithFormat:@"%d", __LINE__]];
                }];
            }
        } errorBlock:^(CLLocationManager *manager, NSError *error) {
            [UIHelper showErrorDialog:error api:@"No api" screen:@"Background process - location tracking" file:[NSString stringWithFormat:@"%s", (strrchr(__FILE__, '/') ?: __FILE__ - 1) + 1] line:[NSString stringWithFormat:@"%d", __LINE__]];
        }];
    } else {
        // Request for permission

        [locationDispatcher requestUserLocationAlwaysWithBlock:^(CLLocationManager *manager, CLAuthorizationStatus status) {
            if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
                [DeviceHelper startLocationTracking:deliveryId];
            } else {
#warning not completed
                // prevent user from starting delivery job?
            }
        }];
    }
}

+ (void)sendEventLog:(NSString *)event {
    [[Mixpanel sharedInstance] track:event
         properties:nil];
}

+ (void)sendEventLog:(NSString *)event subName:(NSString *)subName {
    [[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"%@-%@", event, subName]
                          properties:nil];
}

+ (void)sendErrLogToPapertrail:(NSString *)error api:(NSString *)api screen:(NSString *)screen file:(NSString*)file line:(NSString*)line {
    User *u = [UserPreferences sharedInstance].user;

    if (![DataHelper isObjectNull:u]) {
        DDLogError(@"Client--->iOS   App--->%@_%@   Device--->%@   File--->%@   Line--->%@   Api--->%@   User--->%@.%@   Error--->%@", [[NSBundle mainBundle] bundleIdentifier], [DeviceHelper getAppLongVersion], [SDVersion deviceNameString], file, line, api, u.name, u.phoneNumber, error);
    } else {
        DDLogError(@"Client--->iOS   App--->%@_%@   Device--->%@   File--->%@   Line--->%@   Api--->%@   User--->not_login   Error--->%@", [[NSBundle mainBundle] bundleIdentifier], [DeviceHelper getAppLongVersion], [SDVersion deviceNameString], file, line, api, error);
    }
}

+ (void)trackSessionStart:(NSString *)event {
    [[Mixpanel sharedInstance] timeEvent:event];
}

+ (void)trackSessionEnd:(NSString *)event {
    [[Mixpanel sharedInstance] track:event];
}

+ (NSString *)getAppLongVersion {
    return [NSString stringWithFormat:@"v%@ (build %@)", [self getAppVersion], [self getAppBuildNumber]];
}

+ (NSString *)getAppVersionInNumber {
    return [NSString stringWithFormat:@"%@.%@", [self getAppVersion], [self getAppBuildNumber]];
}

+ (NSString *)getAppVersion {
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    return version;
}

+ (NSString *)getAppBuildNumber {
    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *) kCFBundleVersionKey];
    return build;
}

+ (BOOL)isAppStoreVer {
    BITEnvironment a = bit_currentAppEnvironment();

    return a == BITEnvironmentAppStore;
}

@end
