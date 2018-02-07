//
//  AppDelegate.m
//  QBRTCChatSample
//
//  Created by Andrey Ivanov on 04.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "QBCore.h"
#import "Settings.h"

const CGFloat kQBRingThickness = 1.f;
const NSTimeInterval kQBAnswerTimeInterval = 60.f;
const NSTimeInterval kQBDialingTimeInterval = 5.f;

const NSUInteger kApplicationID = 67043;//39854
NSString *const kAuthKey        = @"tJq9BqRPyNTeKy9";//@"JtensAa9y4AM5Yk"
NSString *const kAuthSecret     = @"yhgCMPAfpCNXJcz";//@"AsDFwwwxpr3LN5w"
NSString *const kAccountKey     = @"suHzUtFPa1RhcBeFtnwU";//@"7yvNe17TnjNUqDoPwfqp"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window.backgroundColor = [UIColor whiteColor];
    
    [QBSettings setAccountKey:kAccountKey];
    [QBSettings setApplicationID:kApplicationID];
    [QBSettings setAuthKey:kAuthKey];
    [QBSettings setAuthSecret:kAuthSecret];
    
    [QBSettings setLogLevel:QBLogLevelDebug];
    [QBSettings enableXMPPLogging];
    
    [QBRTCConfig setAnswerTimeInterval:kQBAnswerTimeInterval];
    [QBRTCConfig setDialingTimeInterval:kQBDialingTimeInterval];
    [QBRTCConfig setStatsReportTimeInterval:1.f];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setMinimumDismissTimeInterval:0.5];
    
    [QBRTCClient initializeRTC];
    
    // loading settings
    [Settings instance];
    
    return YES;
}

// MARK: - Application states

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if (![QBChat instance].isConnected
        && [QBCore instance].isAuthorized) {
        [[QBCore instance] loginWithCurrentUser];
    }
}

// MARK: - Remote Notifictions

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        
        NSLog(@"Did register user notificaiton settings");
        [application registerForRemoteNotifications];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSLog(@"Did register for remote notifications with device token");
    [Core registerForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSLog(@"Did receive remote notification %@", userInfo);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"Did fail to register for remote notification with error %@", error.localizedDescription);
}

@end
