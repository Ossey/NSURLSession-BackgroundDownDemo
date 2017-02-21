//
//  XYBackgroundDownloadProtocol.h
//  BackgroundDownloadDemo
//
//  Created by mofeini on 17/2/19.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 定义下载状态
typedef NS_ENUM(NSInteger, DownloadState) {
    DownloadStateDownloading = 1,  // 正在下载中
    DownloadStatePause,            // 已暂停
    DownloadStateFinish,           // 下载完成
    DownloadStateFailure,          // 下载失败
    DownloadStateUnknown,          // 未知
    DownloadStateResume,           // 恢复下载
};

/// filePath文件最终存放的路径
typedef void(^SuccessBlock)(NSURLSessionDownloadTask *task, NSString *filePath);

typedef void(^FailureBlock)(NSError *error);

/// totalBytesWritten已经下载并写入的文件大小，
/// 文件的总大写totalBytesExpectedToWrite
/// downProgress 下载进度0.00~1.00
typedef void(^ProgressBlock)(CGFloat totalBytesWritten, CGFloat totalBytesExpectedToWrite, NSString *downProgress);
typedef void(^DownloadStateBlock)(DownloadState state);

@protocol XYBackgroundDownloadProtocol <NSObject>

@optional

/**
 * 下载 可在后台下载
 *
 * @param   urlStr  下载url
 * @param   progress  下载进度回调
 * @param   success  下载成功并且成功从tmp中移动到指定的路径成功后回调
 * @param  failure   下载失败或文件下载成功但从tmp移动到其他指定路径失败后回调
 */
- (void)xy_download:(NSString *)urlStr
             progress:(ProgressBlock)progress
              success:(SuccessBlock)success
              failure:(FailureBlock)failure;


/// 暂停下载
- (void)xy_pauseDownload;

/// 继续下载
- (void)xy_continueDownload;

///
/**
 * 会话对象：配置后台会话对象，然后在application: didFinishLaunchingWithOptions中调用
 *
 * @param   fileDirectory  下载后的文件保存的路径, 默认是存储在沙盒caches中的com_sey_background目录下
 * @return  NSURLSession background
 */
- (NSURLSession *)xy_configBackgroundDownloadSessionWithFinalDirectory:(NSString *)fileDirectory;

/// 判断是否是有效的resumeData
- (BOOL)xy_isValideResumeData:(NSData *)resumeData;

/// 下载状态改变时回调
- (void)xy_downloadState:(DownloadStateBlock)state;

/// 释放资源
- (void)xy_release;
@end
