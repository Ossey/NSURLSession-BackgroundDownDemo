//
//  XYBackgroundSession.m
//  BackgroundDownloadDemo
//
//  Created by mofeini on 17/2/21.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "XYBackgroundSession.h"
#import "NSURLSession+CorrectedResumeData.h"
#import "AppDelegate+XYBackgroundTask.h"

#define IS_IOS10_AFTER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10)

NSString *const XYDownloadProgressNotification = @"XYDownloadProgressNotification";

@interface XYBackgroundSession () <NSURLSessionDownloadDelegate>

/// 下载任务
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
/// 包含了下载任务的一些状态，之后使用此属性可以恢复下载
@property (nonatomic, strong) NSData *resumeData;
/// 下载状态属性, 默认为未知状态
@property (nonatomic, assign) DownloadState downloadState;

@property (nonatomic, copy) SuccessBlock successBlock;
@property (nonatomic, copy) ProgressBlock progressBlock;
@property (nonatomic, copy) FailureBlock failureBlock;
@property (nonatomic, copy) DownloadStateBlock downloadStateBlock;
/// 文件下载完成后最终保存的路径，注意: 此路径不包含文件名称，文件名内部自动获取
@property (nonatomic, copy) NSString *finalDirectory;

@end

@implementation XYBackgroundSession

+ (instancetype)sharedInstance {
    
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - XYBackgroundDownloadProtocol

- (void)xy_download:(NSString *)urlStr progress:(ProgressBlock)progress success:(SuccessBlock)success failure:(FailureBlock)failure {
    
    self.successBlock = success;
    self.progressBlock = progress;
    self.failureBlock = failure;
    
    [self beginDownload:urlStr];
}

- (void)beginDownload:(NSString *)urlStr {
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 解决重复点击下载的问题
    if (self.downloadState == DownloadStateDownloading) {
        // 正在下载中就不再重复下载了
        return;
    }
    
    // 判断resumeData属性是否有值，若有值就直接接着以前的下载，不再重复下载
    if ([self xy_isValideResumeData:self.resumeData]) {
    
        [self xy_continueDownload];
        return;
    }
    
    // 下载任务
    self.downloadTask  = [self.backgroundSession downloadTaskWithRequest:request];
    [self.downloadTask resume];
    // 正在下载中
    self.downloadState = DownloadStateDownloading;
    
    
}

- (void)xy_pauseDownload {
    __weak typeof(self) weakSelf = self;
    // 暂停下载，并将resumeData保存起来，之后使用此属性恢复下载的
    [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.resumeData = resumeData;
        strongSelf.downloadState = DownloadStatePause;
    }];
    
    
    NSLog(@"%@", self.downloadTask);
}

- (void)xy_continueDownload {
    // 继续下载时，判断resumeData是否存在，若存在，说明当前有任务在暂停，可继续此任务继续下载
    if (self.resumeData) {
        if IS_IOS10_AFTER {
            // iOS10及其以后
            self.downloadTask = [self.backgroundSession xy_downloadTaskWithResumeData:self.resumeData];
        } else {
            // iOS10之前
            self.downloadTask = [self.backgroundSession downloadTaskWithResumeData:self.resumeData];
        }
        [self.downloadTask resume];
        self.resumeData = nil;
        // 正在下载中
        self.downloadState = DownloadStateResume;
    }
}

- (void)xy_downloadState:(DownloadStateBlock)state {
    self.downloadStateBlock = state;
}

- (NSURLSession *)xy_configBackgroundDownloadSessionWithFinalDirectory:(NSString *)finalDirectory {
    
    self.finalDirectory = finalDirectory;
    return self.backgroundSession;
}


- (BOOL)xy_isValideResumeData:(NSData *)resumeData
{
    if (!resumeData || resumeData.length == 0) {
        return NO;
    }
    return YES;
}

- (void)xy_release {
    
    // 注意：session对象如果设置代理会有一个强引用，它是不会被释放掉的，需要调用以下方法释放,如果不释放会出现内存泄漏问题
    [self.backgroundSession finishTasksAndInvalidate];
    
    self.successBlock = nil;
    self.progressBlock = nil;
    self.failureBlock = nil;
    self.downloadStateBlock = nil;
    self.downloadTask = nil;
}


#pragma mark - NSURLSessionDownloadDelegate

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"



/**
 * 下载完成时调用
 * @TODO: 在此方法方法中，location只是一个磁盘下载文件临时的URL，只是一个临时文件，需要自己使用NSFileManager将文件写到应用的目录下（一般来说这种可以重复获得的内容应该放到cache目录下），因为当你从这个委托方法返回时，该文件将从临时存储中删除。
 * @param   location  磁盘上的文件文件路径
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location {
    
    // 获取文件临时存放的路径
    NSString *locationPath = [location path];
    // 设置最终存放的路径在Doucument中
    NSString *finalPath = [self.finalDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", downloadTask.response.suggestedFilename]];
    
    // 将文件从临时文件夹移动到最终文件中
    NSError *error;
    [[NSFileManager defaultManager] moveItemAtPath:locationPath toPath:finalPath error:&error];
    if (error) {
        NSLog(@"文件移动失败,%@", error.localizedDescription);
        if (self.failureBlock) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.failureBlock(error);
            }];
        }
        
    } else {
        NSLog(@"文件移动成功");
        // 下载完成，执行block
        if (self.successBlock) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.successBlock(downloadTask, finalPath);
            }];
        }
    }
    
    // 发送下载完成的本地通知
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] sendLocalNotification];
    
    [self xy_release];
}

/**
 * 下载恢复时调用
 * @TODO: 在使用downloadTaskWithResumeData:方法获取到对应NSURLSessionDownloadTask，并该task调用resume的时候调用
 *
 * @param   fileOffset  从fileOffset位移处恢复下载任务
 * @param   expectedTotalBytes  预期的总字节数
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
    NSLog(@"恢复下载的位置:%lld 预期的总字节数:%lld",fileOffset,expectedTotalBytes);
}


/**
 * 下载时调用，一般用于监听下载进度，更新下载进度条的
 *
 * @param   session  会话对的
 * @param   downloadTask  下载任务对象
 * @param   bytesWritten  单次下载的大小
 * @param   totalBytesWritten  当前已经下载了多些
 * @param   totalBytesExpectedToWrite  文件总大小
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    // 获取下载进度
    NSString *downProgress = [NSString stringWithFormat:@"%.2f",(CGFloat)totalBytesWritten / totalBytesExpectedToWrite];
    
    // 执行下载进度的block
    if (self.progressBlock) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.progressBlock((CGFloat)totalBytesWritten,(CGFloat)totalBytesExpectedToWrite, downProgress);
        }];
    
    }
}


/**
 * 应用在后台，而且后台所有下载任务完成后调用
 * 在所有其他NSURLSession和NSURLSessionDownloadTask委托方法执行完后回调
 * 可以在该方法中做下载数据管理和UI刷新
 *
 */
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    NSLog(@"后台会话对象:%@ 所有的任务下载完毕\n", session);
    
    if (session.configuration.identifier) {
        // 调用在 -application:handleEventsForBackgroundURLSession: 中保存的 block
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] callCompletionHandlerForSession:session.configuration.identifier];
    }
    
}

/**
 * 该方法下载成功和失败都会回调，只是失败的是error是有值的
 * 在下载失败时，error的userinfo属性可以通过NSURLSessionDownloadTaskResumeData
 * 这个key来取到resumeData(和上面的resumeData是一样的)，再通过resumeData恢复下载
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if (error) {
        
        // 执行下载失败的block
        if (self.failureBlock) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.failureBlock(error);
            }];
        }
        
        if ([error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData]) {
            NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
            //通过之前保存的resumeData，获取断点的NSURLSessionTask，调用resume恢复下载
            self.resumeData = resumeData;
        }
        // 下载失败
        self.downloadState = DownloadStateFailure;
        
    }
}

#pragma clang diagnostic pop

- (NSURLSession *)backgroundSession {
    
    /// 创建一个后台下载对象 用dispatch_once创建一个用于后台下载对象，目的是为了保证identifier的唯一
    /// 文档不建议对于相同的标识符 (identifier) 创建多个会话对象。
    /// 这里创建并配置了NSURLSession，将通过backgroundSessionConfiguration其指定为后台session并设定delegate。
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *identifier = @"com.sey.backgroundSession";
        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
        self.backgroundSession = (session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                                          delegate:self
                                                                     delegateQueue:[NSOperationQueue new]]);
    });
    return session;
}

#pragma mark - set \ get

- (void)setDownloadState:(DownloadState)downloadState {
    
    if (_downloadState != downloadState) {
        if (self.downloadStateBlock) {
            self.downloadStateBlock(downloadState);
        }
    }
    
    _downloadState = downloadState;
}

- (NSString *)finalDirectory {
    NSString *fileDirectory = _finalDirectory ?: [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"com_sey_background"];
    // 文件夹创建
    NSFileManager *fileManage = [NSFileManager defaultManager];
    //先判断这个文件夹是否存在，如果不存在则创建，否则不创建
    if (![fileManage fileExistsAtPath:fileDirectory]) {
        NSError *error;
        [fileManage createDirectoryAtPath:fileDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            @throw [NSException exceptionWithName:@"文件创建失败" reason:@"您设置的文件夹路径存在问题，请重新设置" userInfo:nil];
        }
    };
    
    _finalDirectory = fileDirectory;
    
    return _finalDirectory;

}


@end
