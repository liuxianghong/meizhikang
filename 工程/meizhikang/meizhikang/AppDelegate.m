//
//  AppDelegate.m
//  meizhikang
//
//  Created by 刘向宏 on 15/11/27.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

#import "AppDelegate.h"
#import "NSString+scisky.h"
#import "IMRequst.h"
#import <MagicalRecord/MagicalRecord.h>
#import "BLEConnect.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
{
    NSString *token;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [UINavigationBar appearance].barTintColor = [UIColor colorWithRed:87/255.0 green:219/255.0 blue:177/255.0 alpha:1.0f];
    
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"meizhikang.sqlite"];
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelOff];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil]];
    
    //判断是否由远程消息通知触发应用程序启动
    if (launchOptions) {
        //获取应用程序消息通知标记数（即小红圈中的数字）
        NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
        if (badge>0) {
            //如果应用程序消息通知标记数（即小红圈中的数字）大于0，清除标记。
            badge--;
            //清除标记。清除小红圈中数字，小红圈中数字为0，小红圈才会消除。
            [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
            NSDictionary *pushInfo = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
            
            //获取推送详情
            NSString *pushString = [NSString stringWithFormat:@"%@",[pushInfo  objectForKey:@"aps"]];
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"" message:pushString delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil];
            [alert show];
        }
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    if (token) {
//        [IMRequst BGNotifyByDeviceToken:token completion:^(id info) {
//            NSLog(@"BGNotifyByDeviceToken : %@",info);
//        } failure:^(NSError *error) {
//            NSLog(@"%@",error);
//        }];
    }
    [[BLEConnect Instance] doHeartCommand];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[BLEConnect Instance] doHeartCommand];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [MagicalRecord cleanUp];
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    token = [deviceToken.description formatData];
    NSLog(@"My token is:%@", token);
    //这里应将device token发送到服务器端
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSString *error_str = [NSString stringWithFormat: @"%@", error];
    NSLog(@"Failed to get token, error:%@", error_str);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
    for (id key in userInfo) {
        NSLog(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
    }
    /* eg.
     key: aps, value: {
     alert = "\U8fd9\U662f\U4e00\U6761\U6d4b\U8bd5\U4fe1\U606f";
     badge = 1;
     sound = default;
     }
     */
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"remote notification" message:userInfo[@"aps"][@"alert"] delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil];
    [alert show];
}

@end
