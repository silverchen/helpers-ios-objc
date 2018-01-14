#import "AccountHelper.h"
#import "UserPreferences.h"
#import <AccountKit/AccountKit.h>
@import Firebase;
#import "APIHelper.h"
#import "UIHelper.h"

@implementation AccountHelper

SINGLETON_MACRO

- (BOOL)isLoggedIn {
    return ![DataHelper isObjectNull:[UserPreferences sharedInstance].user];
}

- (void)logout:(void (^)(BOOL success))completion {
    [self logoutFromServer:^(BOOL success) {
        if(completion)
            completion(success);
    }];
}

- (BOOL)isSpecial {
    BOOL isNumSpecial = NO;

    for (NSString *num in [UserPreferences sharedInstance].config.specialNumbers) {
        if ([[DataHelper purifyString:num] isEqualToString:[DataHelper purifyString:[UserPreferences sharedInstance].user.phoneNumber]]) {
            isNumSpecial = YES;
            break;
        }
    }

    return isNumSpecial;
}

- (void)clearCache {
    [UserPreferences sharedInstance].userToken = nil;
    [UserPreferences sharedInstance].user = nil;
    //[UserPreferences sharedInstance].firebaseToken = nil;
    [UserPreferences sharedInstance].selectedSideMenu = nil;
    [UserPreferences sharedInstance].switcherMenus = nil;
    [UserPreferences sharedInstance].fbAccountKitToken = nil;
    [UserPreferences sharedInstance].selectedApiUrl = nil;
    [UserPreferences sharedInstance].selectedSwitcherMenuIndex = nil;

    AKFAccountKit *accountKit = [[AKFAccountKit alloc] initWithResponseType:AKFResponseTypeAuthorizationCode];
    [accountKit logOut];

    [[FIRMessaging messaging] disconnect];
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];

    [UIHelper updateNotificationBadge:0];
}

#pragma mark - API
- (void)logoutFromServer:(void (^)(BOOL success))completion {
    [[APIHelper sharedInstance] sendRequestForURL:[APIHelper getLogoutUrl] parameters:nil method:METHOD_POST success:^(NSHTTPURLResponse *response, id responseObject) {
        NSLog(@"%@", responseObject);

        if(completion)
            completion(YES);
    } failure:^(NSError *error) {
        NSLog(@"%@", error.userInfo);

        [UIHelper showErrorDialog:error api:[APIHelper getLogoutUrl] screen:@"Log out" file:[NSString stringWithFormat:@"%s", (strrchr(__FILE__, '/') ?: __FILE__ - 1) + 1] line:[NSString stringWithFormat:@"%d", __LINE__]];

        if(completion)
            completion(NO);
    }];
}

@end
