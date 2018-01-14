#import <Foundation/Foundation.h>
#import "CustomLoader.h"
#import "UIProp.h"
#import "SideMenu.h"

@interface UIHelper : NSObject

typedef NS_ENUM(int, ScreenType) {
    ListingDetailScreen = 0,
    AwardDetailScreen
};

+ (UIViewController*)getTopMostController;

+ (void)openLoginVC;

+ (void)showErrorDialog:(NSError *)error api:(NSString *)api screen:(NSString *)screen file:(NSString *)file line:(NSString *)line;

+ (void)showErrorDialogFor:(NSString *)err;

+ (void)showBasicDialogWithTitle:(NSString *)title body:(NSString *)body;

+ (void)updateNotificationBadge:(int)count;

+ (void)openWebBrowser:(NSString *)urlString title:(NSString *)title parentVc:(UIViewController *)parentVc;

+ (void)openPopup:(NSString *)urlString parentVc:(UIViewController *)parentVc;

+ (CGFloat)adjustFontSizeForSmallDevice:(CGFloat)originalFontSize;

+ (CustomLoader *)getCustomLoader;

+ (NSString *)getLabelFromConfig:(NSString *)key childKey:(NSString *)childKey defaultValue:(NSString *)defaultValue;

+ (UIProp *)getUIPropFromConfig:(NSString *)key childKey:(NSString *)childKey defaultLabel:(NSString *)defaultLabel defaultPlaceholder:(NSString *)defaultPlaceholder defaultVisibility:(BOOL)defaultVisibility defaultRequired:(BOOL)defaultRequired;

+ (NSArray<SideMenu *> *)getMenus;

+ (NSArray<SideMenu *> *)getSwitcherMenus;

+ (void)openDetailsVcFromNotification:(NSString *)auctionId screenType:(ScreenType)screenType;

+ (void)dismissDialog;

+ (void)launchAppStore;

@end
