//
//  XYBackgroundDownloadProtocol.h
//  BackgroundDownloadDemo
//
//  Created by mofeini on 17/2/19.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XYBackgroundDownloadProtocol <NSObject>

@optional
/// 开始下载
- (void)xy_backgroundDownloadBeginWithURL:(NSString *)urlStr;

/// 暂停下载
- (void)xy_backgroundDownloadPause;

/// 继续下载
- (void)xy_backgroundDownloadContinue;

/// 会话对象：实现后，在application: didFinishLaunchingWithOptions中调用
- (NSURLSession *)xy_backgroundDownloadConfigSession;

/// 注册本地通知, 此方法需要在application: didFinishLaunchingWithOptions中掉用
- (void)xy_registerLocalNotificationWithBlock:(void (^)(UILocalNotification *localNotification))block;

/// 判断是否是有效的resumeData
- (BOOL)xy_isValideResumeData:(NSData *)resumeData;

@end
