/**
 *  HockeySDK App environment
 */
typedef NS_ENUM(NSInteger, BITEnvironment) {
  /**
   *  App has been downloaded from the AppStore
   */
  BITEnvironmentAppStore = 0,
  /**
   *  App has been downloaded from TestFlight
   */
  BITEnvironmentTestFlight = 1,
  /**
   *  App has been installed by some other mechanism.
   *  This could be Ad-Hoc, Enterprise, etc.
   */
  BITEnvironmentOther = 99
};
