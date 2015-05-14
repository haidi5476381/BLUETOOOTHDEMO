//
//  AppDelegate.m
//  BLE
//
//  Created by JohnsonLee on 12-11-15.
//  Copyright (c) 2012年 ven. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "BLEDemoViewController.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //安全距离距离
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Distance"] == nil) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:100.0] forKey:@"Distance"];
    }
    
    //蓝牙电池电量
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"BatteryLevel"] == nil) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:100] forKey:@"BatteryLevel"];
    }
        
    //警告铃声
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"AlarmLevel"] == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"AlarmLevel"];
    }
    
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    application.statusBarStyle = UIStatusBarStyleBlackOpaque;
    
    
    
//    MainViewController *root = [[MainViewController alloc] init];
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:root];
    
    
    BLEDemoViewController *ble=[[BLEDemoViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ble];
    
    
    nav.navigationBarHidden = YES;
    [self.window addSubview:nav.view];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
     NSLog(@"applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
//    UIApplication* app = [UIApplication sharedApplication];
//    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
//        [app endBackgroundTask:bgTask];
//        bgTask = UIBackgroundTaskInvalid;
//    }];
//    // Start the long-running task and return immediately.
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
//                                             0), ^{
//        //在这里写你要在后运行行的代码
//        timer = [[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(getCoordinates) userInfo:nil repeats:YES] retain];
//        [timer fire];
////        [app endBackgroundTask:bgTask];
////        bgTask = UIBackgroundTaskInvalid;  
//    });
//    
}

- (void)getCoordinates{
    NSLog(@"123333333");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)pplicationWillTerminatea:(UIApplication *)application
{
    NSLog(@"applicationWillTerminatea");
}

@end
