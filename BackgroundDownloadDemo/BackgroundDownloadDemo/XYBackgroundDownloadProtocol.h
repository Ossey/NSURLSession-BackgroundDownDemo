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
    DownloadStateUnknown           // 未知
};

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

/// 当正在下载时调用此方法，可让代理对象实现
- (void)xy_backgroundDownload:(id)objc progress:(NSString *)progress;

/// 下载状态属性, 默认为未知状态
@property (nonatomic, assign) DownloadState downloadState;
/// 下载进度属性
@property (nonatomic, copy) NSString *progress;

@end
