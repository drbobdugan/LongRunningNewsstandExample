//
//  AppDelegate.m
//  Newsstand
//
//  http://www.viggiosoft.com/blog/blog/2011/10/17/ios-newsstand-tutorial/
//
//  Created by Carlo Vigiani on 17/Oct/11.
//  Modified and simplified by Bob Dugan on 01/Dec/15
//  Copyright (c) 2011 viggiosoft. All rights reserved.
//

#import "AppDelegate.h"
#import "StoreViewController.h"
#import <NewsstandKit/NewsstandKit.h>

@implementation AppDelegate

@synthesize window = _window;
@synthesize store;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

// Let the device know we want to receive push notifications for Newsstand notification
// APNS standard registration to be added inside application:didFinishLaunchingWithOptions:
-(void)setupPushWithOptions:(NSDictionary *)launchOptions {
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge
                                                                                          |UIUserNotificationTypeSound
                                                                                          |UIUserNotificationTypeAlert) categories:nil];

    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

// Schedule a magazine issue for downloading in background
- (void)doBackgroundDownload
{
    NSLog(@"%s: %@", __PRETTY_FUNCTION__,BackgroundTimeRemainingUtility.backgroundTimeRemainingString);
    
    // in this tutorial we hard-code background download of magazine-2, but normally the magazine to be downloaded
    // has to be provided in the push notification custom payload
    NKIssue *issue = [[NKLibrary sharedLibrary] issueWithName:@"Magazine-2"];

    if ([issue downloadingAssets].count == 0)
    {
        NSURL *downloadURL = [NSURL URLWithString:@"http://www.viggiosoft.com/media/data/blog/newsstand/magazine-2.pdf"];
        NSURLRequest *req = [NSURLRequest requestWithURL:downloadURL];
        NKAssetDownload *assetDownload = [issue addAssetWithRequest:req];
        [assetDownload downloadWithDelegate:store];
    }
    else
    {
        NSLog(@"%s: %@ is already being downloaded.",__PRETTY_FUNCTION__,issue);
        
    }
}

// Launch can happen two ways:
// - foreground launch when user taps on the magazine in the Newsstand
// - background launch when an Apple Push Notification is received
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // debugging
    NSLog(@"%s: %@, LAUNCH OPTIONS = %@", __PRETTY_FUNCTION__,BackgroundTimeRemainingUtility.backgroundTimeRemainingString, launchOptions);
    
    // allows more than one new content notification per day (development)
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NKDontThrottleNewsstandContentNotifications"];
    
    // setup push notifications
    [self setupPushWithOptions:launchOptions];
    
    // initialize the Store view controller - required for all Newsstand functionality
    self.store = [[[StoreViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    nav = [[UINavigationController alloc] initWithRootViewController:store];
 
    // check if the application will run in background after being called by a push notification
    NSDictionary *payload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
   
    // setup the GUI window
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window addSubview:nav.view];
    [self.window makeKeyAndVisible];

    // Restore pending downloading assets so that any abandoned downloadings will be NOT be cancelled
    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    for(NKAssetDownload *asset in [nkLib downloadingAssets]) {
        NSLog(@"Asset to downlaod: %@",asset);
        [asset downloadWithDelegate:store];
    }
    return YES;
}

//
// Delegate for UIApplicationDelegate
//
- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"%s: %@", __PRETTY_FUNCTION__,BackgroundTimeRemainingUtility.backgroundTimeRemainingString);
}

//
// Delegate for UIApplicationDelegate
//
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"%s: %@", __PRETTY_FUNCTION__,BackgroundTimeRemainingUtility.backgroundTimeRemainingString);
}

//
// Delegate for UIApplicationDelegate
//
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"%s: %@", __PRETTY_FUNCTION__,BackgroundTimeRemainingUtility.backgroundTimeRemainingString);
}

//
// Delegate for UIApplicationDelegate
//
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"%s: %@", __PRETTY_FUNCTION__,BackgroundTimeRemainingUtility.backgroundTimeRemainingString);
}

//
// Delegate for UIApplicationDelegate
//
- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"%s: %@", __PRETTY_FUNCTION__,BackgroundTimeRemainingUtility.backgroundTimeRemainingString);
}


//
// Delegate for UIApplicationDelegate
//
// Invoked if register for remote notifications is successful.  Make sure you copy/paste this token to notify.py
//
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *deviceTokenString = [[[[deviceToken description]
                                     stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                    stringByReplacingOccurrencesOfString: @">" withString: @""]
                                   stringByReplacingOccurrencesOfString: @" " withString: @""];    
    NSLog(@"%s: %@, registered with device token: %@",__PRETTY_FUNCTION__, BackgroundTimeRemainingUtility.backgroundTimeRemainingString, deviceTokenString);
   
}

//
// Delegate for UIApplicationDelegate
//
// Invoked if register for remote notifications is not successful
//
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"%s: %@, failing in APNS registration: %@", __PRETTY_FUNCTION__, BackgroundTimeRemainingUtility.backgroundTimeRemainingString, error);
}

//
// Delegate for UIApplicationDelegate
//
// http://stackoverflow.com/questions/22085234/didreceiveremotenotification-fetchcompletionhandler-open-from-icon-vs-push-not
//
// Invoked when a remote notification is received whether the application is: in foreground, in background, not running.  Will
// cause the application to download new issue IN THE BACKGROUND.  If the application is in the foreground, you will see some
// GUI progress bar as the download progresses.  If the application is in the background you will see download updates in the
// console window.  If the application is not running, then the application will be loaded and executed in the background and
// you will see download updates in the console window.
//
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSLog(@"%s: %@, %@",__PRETTY_FUNCTION__, BackgroundTimeRemainingUtility.backgroundTimeRemainingString,userInfo);
    
    [self doBackgroundDownload];
    completionHandler(UIBackgroundFetchResultNoData);
}

//
// Delegate for UIApplicationDelegate
//
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)()) completionHandler
{
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, BackgroundTimeRemainingUtility.backgroundTimeRemainingString);
}

@end
