//
//  AppDelegate.h
//  BLE
//
//  Created by JohnsonLee on 12-11-15.
//  Copyright (c) 2012年 ven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    UIBackgroundTaskIdentifier bgTask;
    NSTimer *timer;
}

@property (strong, nonatomic) UIWindow *window;

@end
