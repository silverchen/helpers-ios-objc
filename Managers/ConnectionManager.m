#import "ConnectionManager.h"
#import "Reachability.h"

@implementation ConnectionManager

SINGLETON_MACRO

- (BOOL)hasInternetConnection {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

@end
