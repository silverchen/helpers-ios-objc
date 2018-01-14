#import "ConnectionHelper.h"
#import "NetworkChecker.h"
#import "UIHelper.h"

@implementation ConnectionHelper

static BOOL hasInternet;

SINGLETON_MACRO

+ (BOOL)hasInternetConnection {
    return hasInternet;
}

+ (void)initConnectionChecker {
    static dispatch_once_t once;

    hasInternet = YES;

    dispatch_once(&once, ^{
        // Allocate a reachability object
        NetworkChecker* reach = [NetworkChecker reachabilityWithHostname:@"www.google.com"];

        // Set the blocks
        reach.reachableBlock = ^(NetworkChecker *reach) {
            // keep in mind this is called on a background thread
            // and if you are updating the UI it needs to happen
            // on the main thread, like this:

            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"REACHABLE!");
                hasInternet = YES;
                [UIHelper dismissDialog];
            });
        };

        reach.unreachableBlock = ^(NetworkChecker *reach) {
            NSLog(@"UNREACHABLE!");
            hasInternet = NO;
            //[UIHelper showErrorDialogFor:SERVER_ERR_NO_INTERNET];
        };

        // Start the notifier, which will cause the reachability object to retain itself!
        [reach startNotifier];
    });
}

@end
