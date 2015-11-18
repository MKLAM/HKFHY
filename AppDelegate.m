//
//  AppDelegate.m
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年8月17日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"
#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation AppDelegate

NSString* const NSURLIsExcludedFromBackupKey = @"NSURLIsExcludedFromBackupKey";

- (void)dealloc
{
    [_mapManager release];
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [GMSServices provideAPIKey:@"AIzaSyC3jCm5oIm0le9riEr5IkcFI7IwsKlHHVM"];
    _mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [_mapManager start:@"BFd3c118ca647c98b0e0adb32d450f9f" generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil] autorelease];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    //self.window.rootViewController = self.viewController;
    navigationController.navigationBar.hidden = YES;
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    [navigationController release];
    
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        
        [application setStatusBarStyle:UIStatusBarStyleLightContent];
        
        self.window.clipsToBounds =YES;
        
        self.window.frame =  CGRectMake(0,20,self.window.frame.size.width,self.window.frame.size.height-20);
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"receive deviceToken: %@", deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Remote notification error:%@", [error localizedDescription]);
}

@end
