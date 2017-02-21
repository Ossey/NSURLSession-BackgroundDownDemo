//
//  AppDelegate+XYBackgroundTask.h
//  BackgroundDownloadDemo
//
//  Created by mofeini on 17/2/19.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "AppDelegate.h"
#import "XYBackgroundDownloadProtocol.h"

typedef void(^CompletionHandler)();

@interface AppDelegate (XYBackgroundTask)

/// 取出handleEventsForBackgroundURLSession方法中保存的block，若存在就执行block
- (void)callCompletionHandlerForSession:(NSString *)identifier;

/// 保存block到completionHandlerDict中
- (void)addCompletionHandler:(CompletionHandler)handler identifier:(NSString *)identifier;

/**
 * 注册本地通知, 此方法需要在application: didFinishLaunchingWithOptions中掉用
 *
 * @param   block  通过block回调一个已经注册过本地通知的localNotification对象
 */
- (void)registerLocalNotificationWithBlock:(void (^)(UILocalNotification *))block;

/// 发送本地通知
- (void)sendLocalNotification;

@end
