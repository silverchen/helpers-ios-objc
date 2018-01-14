#import "UIHelper.h"
#import "LoginViewController.h"
#import "UserPreferences.h"
#import "Notifications.h"
#import "BrowseDetailPopupVC.h"
#import "WebViewController.h"
#import "BidDetailsViewController.h"
#import "AwardDetailsViewController.h"
#import <CRToast/CRToast.h>
#import "CustomErrorResponse.h"
#import "UIAlertView+BlocksKit.h"
#import "ConnectionHelper.h"
#import "AccountHelper.h"
#import "DeviceHelper.h"

@implementation UIHelper

static CustomLoader *loader = nil;

+ (UIViewController*)getTopMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *vc = topController;

    while (vc.childViewControllers.count > 0) {
        vc = vc.childViewControllers.lastObject;
    }

    return vc;
}

+ (void)openLoginVC {
    NSString *storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    LoginViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    id mainController = [[UIApplication sharedApplication] delegate].window.rootViewController;

    [mainController presentViewController:vc animated:true completion:nil];
}

+ (void)dismissDialog {
    [CRToastManager dismissAllNotifications:YES];
}

+ (void)showErrorDialog:(NSError *)error api:(NSString *)api screen:(NSString *)screen file:(NSString *)file line:(NSString *)line {
    NSDictionary* errResponse = [DataHelper getResponseFromError:error];
    NSLog(@"%@",errResponse);

    NSError *err;
    CustomErrorResponse *r = [[CustomErrorResponse alloc] initWithDictionary:errResponse error:&err];

    if ([DataHelper isObjectNull:err] && ![DataHelper isObjectNull:r]) {
        NSLog(@"%@", r.error);
        [UIHelper showErrorDialogFor:r.error];
    } else {
        if (![ConnectionHelper hasInternetConnection]) {
            [UIHelper showErrorDialogFor:SERVER_ERR_NO_INTERNET];
        } else {
            [UIHelper showErrorDialogFor:SERVER_ERR_GENERIC];
            [DeviceHelper sendErrLogToPapertrail:err.userInfo?[NSString stringWithFormat:@"%@", err.userInfo]:err.localizedDescription api:api screen:screen file:file line:line];
        }
    }
}

+ (void)showErrorDialogFor:(NSString *)err {
    Configuration *config = [UserPreferences sharedInstance].config;
    NSString *title = kERR_GENERAL_TITLE;
    NSString *message = kERR_GENERAL_MSG;

    if (![DataHelper isObjectNull:config] && ![DataHelper isObjectNull:config.message[err]]) {
        title = config.message[err][@"title"];
        message = config.message[err][@"message"];
    } else {
        if (![DataHelper isStringNull:err]) {
            message = err;
        }
    }

    if ([err isEqualToString:SERVER_ERR_NO_INTERNET]) {
        if (![CRToastManager isShowingNotification]) {
            NSDictionary *options = @{
                                      kCRToastTextKey : title,
                                      kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                      kCRToastBackgroundColorKey : PRIMARY_COLOR,
                                      kCRToastAnimationInTypeKey : @(CRToastAnimationTypeLinear),
                                      kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeSpring),
                                      kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                      kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop),
                                      kCRToastTimeIntervalKey: @(DBL_MAX),
                                      kCRToastNotificationPresentationTypeKey: @(CRToastPresentationTypeCover),
                                      kCRToastNotificationTypeKey: @(CRToastTypeStatusBar),
                                      kCRToastUnderStatusBarKey: @(0)
                                      };

            dispatch_async(dispatch_get_main_queue(), ^{ // 2
                [CRToastManager showNotificationWithOptions:options
                                            completionBlock:^{
                                                NSLog(@"Completed");
                                            }];
            });
        }
    }

    [UIHelper showBasicDialogWithTitle:title body:message];
}

+ (void)showBasicDialogWithTitle:(NSString *)title body:(NSString *)body {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:body
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+ (void)updateNotificationBadge:(int)count {
    if ([AccountHelper sharedInstance].isLoggedIn) {
        [UserPreferences sharedInstance].notificationCount = count;
        [UIApplication sharedApplication].applicationIconBadgeNumber = count;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVED_NOTIFICATION object:nil];
    } else {
        [UserPreferences sharedInstance].notificationCount = 0;
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}

+ (void)openWebBrowser:(NSString *)urlString title:(NSString *)title parentVc:(UIViewController *)parentVc {
    NSString *storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    WebViewController *controller = (WebViewController *) [storyboard instantiateViewControllerWithIdentifier:@"WebVC"];
    controller.url = [NSURL URLWithString:urlString];
    controller.title = title;

    controller.hidesBottomBarWhenPushed = YES;

    parentVc.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];

    [parentVc.navigationController pushViewController:controller animated:YES];
}

+ (void)openPopup:(NSString *)urlString parentVc:(UIViewController *)parentVc {
    NSString *urlScheme = [urlString componentsSeparatedByString:@"://"][0];

    if ([[urlScheme lowercaseString] isEqualToString:@"http"] || [[urlScheme lowercaseString] isEqualToString:@"https"]) {
        NSString *domain = [[NSURL URLWithString:urlString] host];

#warning quick fix
        if ([domain isEqualToString:@"facebook.com"] || [domain isEqualToString:@"www.facebook.com"]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        } else if ([domain isEqualToString:@"twitter.com"] || [domain isEqualToString:@"www.twitter.com"]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        } else {
            BrowseDetailPopupVC *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"BrowseDetailPopupVC"];
            vc.url = urlString;
            [parentVc presentViewController:vc animated:YES completion:nil];
        }
    } else {
        if ([self schemeAvailable:[NSString stringWithFormat:@"%@://", urlScheme]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App Not Found"
                                                            message:@"The specific app used to share the listing is not installed on your phone."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

+ (BOOL)schemeAvailable:(NSString *)scheme {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:scheme];
    return [application canOpenURL:URL];
}

+ (CGFloat)adjustFontSizeForSmallDevice:(CGFloat)originalFontSize {
    return originalFontSize - 2.0;
}

+ (NSString *)getLabelFromConfig:(NSString *)key childKey:(NSString *)childKey defaultValue:(NSString *)defaultValue {
    Configuration *config = [UserPreferences sharedInstance].config;

    if (![DataHelper isObjectNull:config] && ![DataHelper isObjectNull:config.screenDisplay[key]] && ![DataHelper isObjectNull:config.screenDisplay[key][childKey]]) {
        NSError *error;
        UIProp *prop = [[UIProp alloc] initWithDictionary:config.screenDisplay[key][childKey] error:&error];

        if ([DataHelper isObjectNull:error] && ![DataHelper isObjectNull:prop]) {
            return prop.label;
        }
    }

    return [NSString stringWithFormat:@"%@#", defaultValue];
}

+ (UIProp *)getUIPropFromConfig:(NSString *)key childKey:(NSString *)childKey defaultLabel:(NSString *)defaultLabel defaultPlaceholder:(NSString *)defaultPlaceholder defaultVisibility:(BOOL)defaultVisibility defaultRequired:(BOOL)defaultRequired {
    Configuration *config = [UserPreferences sharedInstance].config;

    if (![DataHelper isObjectNull:config] && ![DataHelper isObjectNull:config.screenDisplay[key]] && ![DataHelper isObjectNull:config.screenDisplay[key][childKey]]) {
        NSError *error;
        UIProp *prop = [[UIProp alloc] initWithDictionary:config.screenDisplay[key][childKey] error:&error];

        if ([DataHelper isObjectNull:error] && ![DataHelper isObjectNull:prop]) {
            return prop;
        }
    }

    UIProp *defaultProp = [[UIProp alloc] init];
    defaultProp.label = [NSString stringWithFormat:@"%@#", defaultLabel];
    defaultProp.placeholder = [NSString stringWithFormat:@"%@#", defaultPlaceholder];
    defaultProp.visibility = defaultVisibility;
    defaultProp.required = defaultRequired;

    return defaultProp;
}

+ (CustomLoader *)getCustomLoader {
    if ([DataHelper isObjectNull:loader]) {
        loader = [[CustomLoader alloc] init];
    }

    return loader;
}

//+ (NSArray<NSDictionary *> *)getMenus {
+ (NSArray<SideMenu *> *)getMenus {
    Configuration *config = [UserPreferences sharedInstance].config;
    NSMutableArray *a = [[NSMutableArray alloc] init];

    //[a addObject:@{@"title":@"Home", @"icon":@"ic_home_sidebar", @"type":[NSNumber numberWithInt:Home]}];
    [a addObject:[[SideMenu alloc] initWithTitle:@"Home" icon:@"ic_home_sidebar" menuType:Home]];

    if (![DataHelper isObjectNull:config] && ![DataHelper isObjectNull:config.menus] && ![DataHelper isArrayEmpty:config.menus]) {
        for (NSDictionary *d in config.menus) {
            if (![DataHelper isObjectNull:d]) {
                NSError *error;
                SideMenu *menu = [[SideMenu alloc] initWithDictionary:d error:&error];

                if (![DataHelper isStringNull:menu.type] && [menu.type.lowercaseString isEqualToString:@"appswitch"]) {
//                    if (menu.visibility) {
//                        //[a addObject:@{@"title":d[@"title"], @"icon":@"", @"type":[NSNumber numberWithInt:Others], @"url":@""}];
//                        menu.icon = nil;
//                        menu.menuType = Home;
//                        [a addObject:menu];
//                    }
                } else {
                    menu.icon = @"ic_about_sidebar";
                    menu.menuType = Others;
                    [a addObject:menu];
                }
            }
        }
    }

    [a addObject:[[SideMenu alloc] initWithTitle:@"Log out" icon:@"ic_login_sidebar" menuType:Logout]];

    return a;
}

+ (NSArray<SideMenu *> *)getSwitcherMenus {
    Configuration *config = [UserPreferences sharedInstance].config;
    NSArray *a;

    if (![DataHelper isObjectNull:config] && ![DataHelper isObjectNull:config.switcherMenus] && ![DataHelper isArrayEmpty:config.switcherMenus]) {
        a = [NSArray arrayWithArray:[self getSwitcherMenusFromMenu:config.switcherMenus]];
    }

    if (![DataHelper isArrayEmpty:a]) {
        [UserPreferences sharedInstance].switcherMenus = config.switcherMenus;
    } else {
        if (![DataHelper isArrayEmpty:[UserPreferences sharedInstance].switcherMenus]) {
            return [NSArray arrayWithArray:[self getSwitcherMenusFromMenu:[UserPreferences sharedInstance].switcherMenus]];
        }
    }

    return a;
}

+ (NSArray<SideMenu *> *)getSwitcherMenusFromMenu:(NSArray *)menus {
    NSMutableArray *a = [[NSMutableArray alloc] init];

    for (NSDictionary *d in menus) {
        if (![DataHelper isObjectNull:d]) {
            NSError *error;
            SideMenu *menu = [[SideMenu alloc] initWithDictionary:d error:&error];

            if (![DataHelper isStringNull:menu.type] && [menu.type.lowercaseString isEqualToString:@"appswitch"]) {
#warning temporary
                //if (menu.visibility) {
                menu.icon = @"AppIcon40x40";
                [a addObject:menu];
                //}
            }
        }
    }

    return a;
}

+ (void)openDetailsVcFromNotification:(NSString *)auctionId screenType:(ScreenType)screenType {
    NSString *storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    UIViewController *topVc = [UIHelper getTopMostController];

    switch (screenType) {
        case ListingDetailScreen: {
            BidDetailsViewController *vc = (BidDetailsViewController *) [storyboard instantiateViewControllerWithIdentifier:@"BidDetailsViewController"];
            Auction *a = [[Auction alloc] init];
            a.auctionId = [auctionId intValue];
            vc.theAuction = a;

            if (![UserPreferences sharedInstance].firstLaunch) {
                [UserPreferences sharedInstance].openAuctionId = nil;
                vc.isFromNotification = YES;
                UINavigationController *navController = (UINavigationController *)topVc.navigationController;
                [navController pushViewController:vc animated:YES];
            } else {
                [UserPreferences sharedInstance].openAuctionId = auctionId;
            }
            break;
        }
        case AwardDetailScreen: {
            AwardDetailsViewController *vc = (AwardDetailsViewController *) [storyboard instantiateViewControllerWithIdentifier:@"AwardDetailsViewController"];
            Auction *a = [[Auction alloc] init];
            a.auctionId = [auctionId intValue];
            vc.theAuction = a;

            if (![UserPreferences sharedInstance].firstLaunch) {
                [UserPreferences sharedInstance].openAuctionId = nil;
                UINavigationController *navController = (UINavigationController *)topVc.navigationController;
                [navController pushViewController:vc animated:YES];
            } else {
                [UserPreferences sharedInstance].openAuctionId = auctionId;
            }
            break;
        }
        default:
            break;
    }
}

+ (void)launchAppStore {
    NSString *iTunesString = [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@", ITUNES_APP_ID];
    NSURL *iTunesURL = [NSURL URLWithString:iTunesString];

    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] openURL:iTunesURL];
    });
}

@end
