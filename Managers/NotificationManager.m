#import "NotificationManager.h"
#import "APIManager.h"
#import "MyPreferences.h"
#import "FilterManager.h"
#import "BrowseSettings.h"
#import "UIAlertView+BlocksKit.h"

NSString * const kBaseViewLoaded = @"BaseViewLoaded";

@interface NotificationManager ()

@property (nonatomic, strong) NSDictionary *userInfo;

@property BOOL shouldRedirect;
@property BOOL shouldShowNotificationWhenBaseViewIsLoaded;
@property BOOL isBaseViewLoaded;

@end

@implementation NotificationManager

SINGLETON_MACRO


- (id)init {
    self = [super init];

    if (self) {
        [self unRegisterNotification]; // remove first to make sure no duplicate is subscriped
        [self registerNotification];
    }
    return self;
}

- (void)parseNotification:(NSDictionary*)userInfo shouldRedirect:(BOOL)redirect {
    self.userInfo = userInfo;
    self.shouldRedirect = redirect;

    int pushType = [userInfo[@"push_type"] intValue];
    switch (pushType) {
        case 1:
            [self showFreeText:userInfo];
            break;
        case 2:
            [self showListing:userInfo shouldRedirect:redirect];
            break;
        case 3:
            [self showAds:userInfo];
            break;
        default:
            break;
    }
}

- (void)showFreeText:(NSDictionary*)userInfo {
    [[AppDelegate sharedDelegate] showAlertView:userInfo[@"message_title"] withMessage:userInfo[@"aps"][@"alert"]];
}

- (void)showListing:(NSDictionary*)userInfo shouldRedirect:(BOOL)redirect{

    if(!self.isBaseViewLoaded){
        self.shouldShowNotificationWhenBaseViewIsLoaded = true;
        return;
    }

    if(!redirect){
    [UIAlertView bk_showAlertViewWithTitle:userInfo[@"message_title"]
                                   message:userInfo[@"aps"][@"alert"]
                         cancelButtonTitle:@"Dismiss"
                         otherButtonTitles:@[@"View"]
                                   handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                       if(buttonIndex == 1){
                                           [[FilterManager sharedInstance] setFilterValue:userInfo[@"category_id"] withOriginalKey:kVehicleType];
                                           [[AppDelegate sharedDelegate] openBrowseView];
                                       }
                                   }];
    }else{
        [[FilterManager sharedInstance] setFilterValue:userInfo[@"category_id"] withOriginalKey:kVehicleType];
        [[AppDelegate sharedDelegate] openBrowseView];
    }
}

- (void)showAds:(NSDictionary*)userInfo {

    if(!self.isBaseViewLoaded){
        self.shouldShowNotificationWhenBaseViewIsLoaded = true;
        return;
    }

    [[AppDelegate sharedDelegate] openAdsView:userInfo];
}

- (void)submitPushToken {

    NSDictionary *dic = @{@"push_token":[MyPreferences sharedInstance].pushToken,
                          @"platform":@"ios"
                        };
    [[APIManager sharedInstance] sendRequestForURL:API_REG_PUSH_TOKEN parameters:dic method:METHOD_POST success:^(NSHTTPURLResponse *response, id responseObject) {

        NSLog(@"%@",responseObject);


    } failure:^(NSError *error) {

        NSLog(@"%@",error.userInfo);

    }];
}

- (void)baseViewIsLoaded:(NSNotification*)noti {
    self.isBaseViewLoaded = true;

    if(self.shouldShowNotificationWhenBaseViewIsLoaded){
        [self parseNotification:self.userInfo shouldRedirect:self.shouldRedirect];
        [self clearPush];
    }
}

- (void)clearPush {
    self.userInfo = nil;
    self.shouldRedirect = nil;
    self.shouldShowNotificationWhenBaseViewIsLoaded = nil;
    [self unRegisterNotification];
    //[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)registerNotification{

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(baseViewIsLoaded:)
                                                 name:kBaseViewLoaded
                                               object:nil];

}

- (void)unRegisterNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kBaseViewLoaded object:nil];
}

@end
