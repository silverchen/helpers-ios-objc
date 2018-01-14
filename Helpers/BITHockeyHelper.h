#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HockeySDKEnums.h"

@interface BITHockeyHelper : NSObject

@end

BOOL bit_isAppStoreReceiptSandbox(void);
BOOL bit_hasEmbeddedMobileProvision(void);
BITEnvironment bit_currentAppEnvironment(void);
