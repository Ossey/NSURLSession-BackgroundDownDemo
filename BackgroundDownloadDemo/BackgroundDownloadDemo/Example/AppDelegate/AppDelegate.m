//
//  AppDelegate.m
//  BackgroundDownloadDemo
//
//  Created by mofeini on 17/2/19.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+XYBackgroundTask.h"
#import "XYBackgroundSession.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [self.window makeKeyAndVisible];
    
//    NSString *filePath = @"/Users/mofeini/Desktop/tomcat/sey";
    
    /// 配置后台下载任务的会话对象
    [[XYBackgroundSession sharedInstance] xy_configBackgroundDownloadSessionWithFinalDirectory:nil];
    
    /// 注册本地通知
    [self registerLocalNotificationWithBlock:^(UILocalNotification *localNotification) {
        /// 注册完成后回调
        
        NSLog(@"%@", localNotification);
        
        // ios8后，需要添加这个注册，才能得到授权
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                     categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            // 通知重复提示的单位，可以是天、周、月
            localNotification.repeatInterval = 0;
        } else {
            // 通知重复提示的单位，可以是天、周、月
            localNotification.repeatInterval = 0;
        }
        
    }];
    
    UILocalNotification *localNotification = [launchOptions valueForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        // 当程序启动时，就有本地通知需要推送，就手动调用一次didReceiveLocalNotification
        [self application:application didReceiveLocalNotification:localNotification];
    }
    
    
    return YES;
}





@end
