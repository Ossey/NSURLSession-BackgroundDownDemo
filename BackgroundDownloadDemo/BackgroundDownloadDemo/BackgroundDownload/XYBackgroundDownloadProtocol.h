//
//  XYBackgroundDownloadProtocol.h
//  BackgroundDownloadDemo
//
//  Created by mofeini on 17/2/19.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 定义下载状态
typedef NS_ENUM(NSInteger, DownloadState) {
    DownloadStateDownloading = 1,  // 正在下载中
    DownloadStatePause,            // 已暂停
    DownloadStateFinish,           // 下载完成
    DownloadStateFailure,          // 下载失败
    DownloadStateUnknown,          // 未知
//    DownloadStateBackground        // 后台下载
};

@protocol XYBackgroundDownloadProtocol <NSObject>

@optional
/**
 * 开始下载
 *
 * @param   urlStr  下载文件的url路径
 */
- (void)xy_backgroundDownloadBeginWithURL:(NSString *)urlStr;

/// 暂停下载
- (void)xy_backgroundDownloadPause __attribute__((deprecated("已过期, 请使用:- xy_backgroundDownloadPause:")));

/// 继续下载
- (void)xy_backgroundDownloadContinue __attribute__((deprecated("已过期,请使用:- xy_backgroundDownloadContinue:")));

/// 暂停下载，当有多个文件同时下载时，根据urlStr暂停下载
- (void)xy_backgroundDownloadPause:(NSString *)urlStr;

/// 继续下载，当有多个文件同时下载时，根据urlStr继续下载
- (void)xy_backgroundDownloadContinue:(NSString *)urlStr;

/// 会话对象：实现后，在application: didFinishLaunchingWithOptions中调用
- (NSURLSession *)xy_backgroundDownloadConfigSession;

/**
 * 注册本地通知, 此方法需要在application: didFinishLaunchingWithOptions中掉用
 *
 * @param   block  通过block回调一个已经注册过本地通知的localNotification对象
 */
- (void)xy_registerLocalNotificationWithBlock:(void (^)(UILocalNotification *localNotification))block;

/// 判断是否是有效的resumeData
- (BOOL)xy_isValideResumeData:(NSData *)resumeData;

/// 清除所有下载任务及缓存的resumeData
- (void)xy_releaseAll;

/// 清除url对应的下载任务及缓存的resumeData
- (void)xy_releaseByURL:(NSString *)url;

@end
