//
//  AppDelegate+XYBackgroundTask.m
//  BackgroundDownloadDemo
//
//  Created by mofeini on 17/2/19.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "AppDelegate+XYBackgroundTask.h"
#import <objc/runtime.h>

#define IS_IOS10_AFTER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10)


@interface AppDelegate () <NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSMutableDictionary *completionHandlerDict;
/// 通知的内容
@property (nonatomic, strong) NSString *notifyMessage;
/// 本地通知
@property (nonatomic, strong) UILocalNotification *localNotification;

@end

@implementation AppDelegate (XYBackgroundTask)

- (void)registerLocalNotificationWithBlock:(void (^)(UILocalNotification *))block {
    
    [self localNotification];
    
    if (block) {
        block(self.localNotification);
    }
}


#pragma mark - UIApplicationDelegate 与后台任务相关的代理方法
/*
 当加入了多个Task，程序切到后台，所有Task都完成下载调用此方法。
 
 在切到后台之后，Session的Delegate不会再收到，Task相关的消息，直到所有Task全都完成后，系统会调用ApplicationDelegate的application:handleEventsForBackgroundURLSession:completionHandler:回调，之后“汇报”下载工作，对于每一个后台下载的Task调用Session的Delegate中的URLSession:downloadTask:didFinishDownloadingToURL:（成功的话）和URLSession:task:didCompleteWithError:（成功或者失败都会调用）。
 
 之后调用Session的Delegate回调URLSessionDidFinishEventsForBackgroundURLSession:。
 */
/// 注意：在ApplicationDelegate被唤醒后，会有个参数ComplietionHandler，这个参数是个Block，这个参数要在后面Session的Delegate中didFinish的时候调用一下
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
    
    // 你必须重新建立一个后台 seesion 的参照
    // 否则 NSURLSessionDownloadDelegate 和 NSURLSessionDelegate 方法会因为
    // 没有 对 session 的 delegate 设定而不会被调用。参见上面的 backgroundURLSession
//    NSURLSession *backgroundSession = self.backgroundSession;
    
//    NSLog(@"下载任务标识符:%@, 后台会话对象:%@", identifier, backgroundSession);
    
    // 将block 保存起来  之后在Session的Delegate回调URLSessionDidFinishEventsForBackgroundURLSession:
    [self addCompletionHandler:completionHandler identifier:identifier];
}

#pragma mark - UIApplicationDelegate 与本地通知相关的代理方法

/// 此方法是本地通知会触发的方法，当点击通知横幅进入app时会调用
- (void)application:(UIApplication *)application didReceiveLocalNotification:(nonnull UILocalNotification *)notification {
    
    // 取消所有通知
    [application cancelAllLocalNotifications];
    [[[UIAlertView alloc] initWithTitle:@"下载通知" message:self.notifyMessage delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil] show];
    
    // 点击通知后，就让图标上的数字减1
    application.applicationIconBadgeNumber -= 1;
}

/// 当有电话进来或者锁屏，此时应用程会挂起，调用此方法，此方法一般做挂起前的工作，比如关闭网络，保存数据
- (void)applicationWillResignActive:(UIApplication *)application {
    // 图标上的数字减1
    application.applicationIconBadgeNumber -= 1;
}

#pragma mark - Private

/// 保存block到completionHandlerDict中
- (void)addCompletionHandler:(CompletionHandler)handler identifier:(NSString *)identifier {
    
    if ([self.completionHandlerDict objectForKey:identifier]) {
        NSLog(@"Error: identifier已存在\n");
    }
    // 将block 保存起来在completionHandlerDict字典中，key使用下载任务标识符(唯一)
    [self.completionHandlerDict setObject:handler forKey:identifier];
}

/// 取出handleEventsForBackgroundURLSession方法中保存的block，若存在就执行block
- (void)callCompletionHandlerForSession:(NSString *)identifier {
    // 取出block
    CompletionHandler handler = [self.completionHandlerDict objectForKey:identifier];
    
    if (handler) {
        // 移除
        [self.completionHandlerDict removeObjectForKey: identifier];
        NSLog(@"执行block了， 下载任务标识符: %@", identifier);
        
        handler();
    }
}

/// 发送本地通知
- (void)sendLocalNotificationWithMessage:(NSString *)m {
    self.notifyMessage = m;
    [[UIApplication sharedApplication] scheduleLocalNotification:self.localNotification];
}


#pragma mark - set\get

- (void)setCompletionHandlerDict:(NSMutableDictionary *)completionHandlerDict {
    objc_setAssociatedObject(self, @selector(completionHandlerDict), completionHandlerDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableDictionary *)completionHandlerDict {
    
    NSMutableDictionary *dict = objc_getAssociatedObject(self, @selector(completionHandlerDict));
    if (dict == nil) {
        self.completionHandlerDict = (dict = [NSMutableDictionary dictionaryWithCapacity:0]);
    }
    return dict;
}


- (void)setNotifyMessage:(NSString *)notifyMessage {
    objc_setAssociatedObject(self, @selector(notifyMessage), notifyMessage, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSString *)notifyMessage {
    
    return objc_getAssociatedObject(self, @selector(notifyMessage)) ?: @"下载完成了";
}

- (void)setLocalNotification:(UILocalNotification *)localNotification {
    objc_setAssociatedObject(self, @selector(localNotification), localNotification, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UILocalNotification *)localNotification {
    
    UILocalNotification *localNot = objc_getAssociatedObject(self, @selector(localNotification));
    
    if (localNot == nil) {
        self.localNotification = (localNot = [UILocalNotification new]);
        localNot.fireDate = [[NSDate date] dateByAddingTimeInterval:5];
        localNot.alertAction = nil;
        localNot.soundName = UILocalNotificationDefaultSoundName;
        localNot.alertBody = self.notifyMessage;
        localNot.applicationIconBadgeNumber = 1;
        localNot.repeatInterval = 0;
    }
    return localNot;
}

@end
