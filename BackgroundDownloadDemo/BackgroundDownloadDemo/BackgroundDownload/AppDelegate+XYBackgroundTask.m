//
//  AppDelegate+XYBackgroundTask.m
//  BackgroundDownloadDemo
//
//  Created by mofeini on 17/2/19.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "AppDelegate+XYBackgroundTask.h"
#import <objc/runtime.h>
#import "NSURLSession+XYResumeData.h"

#define IS_IOS10_AFTER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10)

NSString *const XYDownloadProgressNotification = @"XYDownloadProgressNotification";
NSString *const XYDownloadStateNotification = @"XYDownloadStateNotification";
NSString *const XYDownloadProgress = @"XYDownloadProgress";
NSString *const XYDownloadURL = @"XYDownloadURL";

NSString *const XYDownloadResumeDataKey = @"XYDownloadResumeDataKey";
NSString *const XYDownloadStateKey = @"XYDownloadStateKey";

typedef void(^CompletionHandler)();

@interface AppDelegate () <NSURLSessionDownloadDelegate>

/// 后台会话对象
@property (nonatomic, strong) NSURLSession *backgroundSession;
/// 下载任务
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
/// 包含了下载任务的一些状态，之后使用此属性可以恢复下载
@property (nonatomic, strong) NSData *resumeData;
/// 本地通知
@property (nonatomic, strong) UILocalNotification *localNotification;
/// 通知的内容
@property (nonatomic, strong) NSString *notifyMessage;
/// 保存block的字典
@property (nonatomic, strong) NSMutableDictionary *completionHandlerDict;

/// 映射下载url对应的resumeData及下载状态, key为当前下载的url，value为字典：包含resumeData及下载状态
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSDictionary *> *downloadResumeDataDict;

@property (nonatomic, copy) NSString *currentDownloadURL;

@end

@implementation AppDelegate (XYBackgroundTask)

#pragma mark - XYBackgroundDownloadProtocol

- (void)xy_backgroundDownloadBeginWithURL:(NSString *)urlStr {
    
//    if (![self.currentDownloadURL isEqualToString:urlStr]) {
//        // 如果正在 重新创建一个下载任务
//        [self startDownload:urlStr];
//        return;
//    }
    
    // 取出当前下载状态
    DownloadState state = [self.downloadResumeDataDict[urlStr][XYDownloadStateKey] integerValue];
    
    // 解决重复点击下载的问题
    if (state == DownloadStateDownloading) {
        return;
    }
//    if (self.downloadState == DownloadStateDownloading) {
//        // 正在下载中就不再重复下载了
//        return;
//    }
    
    
//    // 取出resumeData
//    id dataObj = self.downloadResumeDataDict[urlStr][XYDownloadResumeDataKey];
//    if ([dataObj isKindOfClass:[NSData class]] && dataObj != nil) {
//        
//    }
    
    // 判断resumeData属性是否有值，若有值就直接接着以前的下载，不再重复下载
//    if ([self xy_isValideResumeData:dataObj]) {
//        
//        [self xy_backgroundDownloadContinue:urlStr];
//        return;
//    }
//    __weak typeof(self) weakSelf = self;
//    
//    // 如果当前有下载任务，取消最后的下载任务,取消后会回调给我们 resumeData
//    if (self.downloadTask) {
//        [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
//            __strong typeof(weakSelf) strongSelf = weakSelf;
//            strongSelf.resumeData = resumeData;
//        }];
//    }
    
    [self startDownload:urlStr];
}

- (void)startDownload:(NSString *)urlStr {
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    // 下载任务
    self.downloadTask  = [self.backgroundSession downloadTaskWithRequest:request];
    [self.downloadTask resume];
//     正在下载中
//    self.downloadState = DownloadStateDownloading;
    // 保存当前的下载路径
    self.currentDownloadURL = urlStr;
    
    // 将任务resumeData urlStr 关联起来, 若没有resumeData 则用-1关联
    [self addMapWithURL:urlStr downloadState:DownloadStateDownloading resumeData:nil];
}

- (void)addMapWithURL:(NSString *)urlStr downloadState:(DownloadState)state resumeData:(NSData *)resumeData {
    
    id data = nil;
    if (resumeData == nil) {
        data = @(-1);
    } else {
        data = resumeData;
    }
    
    // 将任务resumeData urlStr 关联起来, 若没有resumeData 则用-1关联
    [self.downloadResumeDataDict setObject:@{XYDownloadResumeDataKey: data, XYDownloadStateKey: @(DownloadStateDownloading)} forKey:urlStr];
}

- (void)removeMapFromURL:(NSString *)urlStr {
    if (urlStr && urlStr.length) {
        [self.downloadResumeDataDict removeObjectForKey:urlStr];
    }
}

- (void)xy_backgroundDownloadPause:(NSString *)urlStr {
    
    self.currentDownloadURL = urlStr;

    __weak typeof(self) weakSelf = self;
    // 暂停下载，并将resumeData保存起来，之后使用此属性恢复下载的
    [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
//        strongSelf.resumeData = resumeData;
//        strongSelf.downloadState = DownloadStatePause;
        
        [strongSelf addMapWithURL:urlStr downloadState:DownloadStatePause resumeData:resumeData];
        
    }];
    
}

- (void)xy_backgroundDownloadPause {

    [self xy_backgroundDownloadPause:nil];
    
}

- (void)xy_backgroundDownloadContinue:(NSString *)urlStr {
    
    self.currentDownloadURL = urlStr;
    
    // 取出resumeData
    id dataObj = self.downloadResumeDataDict[urlStr][XYDownloadResumeDataKey];
    if ([dataObj isKindOfClass:[NSData class]] && dataObj != nil) {
        // 继续下载时，判断resumeData是否存在，若存在，说明当前有任务在暂停，可继续此任务继续下载
        if IS_IOS10_AFTER {
            // iOS10及其以后
            self.downloadTask = [self.backgroundSession xy_downloadTaskWithResumeData:dataObj];
        } else {
            // iOS10之前
            self.downloadTask = [self.backgroundSession downloadTaskWithResumeData:dataObj];
        }
        [self.downloadTask resume];
        
        [self addMapWithURL:urlStr downloadState:DownloadStateDownloading resumeData:nil];

    }
    
    // 继续下载时，判断resumeData是否存在，若存在，说明当前有任务在暂停，可继续此任务继续下载
//    if (self.resumeData) {
//        if IS_IOS10_AFTER {
//            // iOS10及其以后
//            self.downloadTask = [self.backgroundSession xy_downloadTaskWithResumeData:self.resumeData];
//        } else {
//            // iOS10之前
//            self.downloadTask = [self.backgroundSession downloadTaskWithResumeData:self.resumeData];
//        }
//        [self.downloadTask resume];
////        self.resumeData = nil;
//        // 正在下载中
////        self.downloadState = DownloadStateDownloading;
//        [self addMapWithURL:urlStr downloadState:DownloadStateDownloading resumeData:nil];
//    }
}

- (void)xy_backgroundDownloadContinue {
    
    [self xy_backgroundDownloadContinue:nil];
    
}


- (NSURLSession *)xy_backgroundDownloadConfigSession {
    
    return self.backgroundSession;
}

- (void)xy_registerLocalNotificationWithBlock:(void (^)(UILocalNotification *))block {
     [self localNotification];
    if (block) {
        block(self.localNotification);
    }
}


- (BOOL)xy_isValideResumeData:(NSData *)resumeData
{
    if (!resumeData || resumeData.length == 0) {
        return NO;
    }
    return YES;
}

- (void)xy_clear {
    // 主要目的是清除代理，防止奔溃
    if (self.backgroundDownloadDelegate) {
        self.backgroundDownloadDelegate = nil;
    }
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
 
    NSLog(@"下载任务的标识符：%lu", (unsigned long)downloadTask.taskIdentifier);
    NSLog(@"文件下载完临时存放的路径：%@", location);
    
    // 获取文件临时存放的路径
    NSString *locationPath = [location path];
    // 设置最终存放的路径在Doucument中
    NSString *finalPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%lufile", downloadTask.taskIdentifier]];
    
    // 将文件从临时文件夹移动到最终文件中
    NSError *error;
    [[NSFileManager defaultManager] moveItemAtPath:locationPath toPath:finalPath error:&error];
    if (error) {
        NSLog(@"文件移动失败,%@", error.localizedDescription);
    } else {
        NSLog(@"文件移动成功");
    }
    
    // 用 NSFileManager 将文件复制到应用的存储中
    
    // 通知 UI 刷新
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
    
//    NSLog(@"下载任务的标识符:%lu 下载进度百分比percent:%.2f%%",(unsigned long)downloadTask.taskIdentifier,(CGFloat)totalBytesWritten / totalBytesExpectedToWrite * 100);
    // 获取下载进度
    NSString *downProgress = [NSString stringWithFormat:@"%.2f",(CGFloat)totalBytesWritten / totalBytesExpectedToWrite];
    
    // 赋值下载进度
//    self.downProgress = downProgress;
    
    // 通知view更新下载进度
    [self postDownloadProgressNotificationWithProgress:downProgress];
    
//     NSLog(@"标识符:%lu task:%@",(unsigned long)downloadTask.taskIdentifier,downloadTask);
}


/*
 当加入了多个Task，程序切到后台，所有Task都完成下载。
 
 在切到后台之后，Session的Delegate不会再收到，Task相关的消息，直到所有Task全都完成后，系统会调用ApplicationDelegate的application:handleEventsForBackgroundURLSession:completionHandler:回调，之后“汇报”下载工作，对于每一个后台下载的Task调用Session的Delegate中的URLSession:downloadTask:didFinishDownloadingToURL:（成功的话）和URLSession:task:didCompleteWithError:（成功或者失败都会调用）。
 
 之后调用Session的Delegate回调URLSessionDidFinishEventsForBackgroundURLSession:。
 */
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
        [self callCompletionHandlerForSession:session.configuration.identifier];
    }
    
}

/**
 * 该方法下载成功和失败都会回调，只是失败的是error是有值的
 * 在下载失败时，error的userinfo属性可以通过NSURLSessionDownloadTaskResumeData
 * 这个key来取到resumeData(和上面的resumeData是一样的)，再通过resumeData恢复下载
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if (error) {
        // check if resume data are available
        if ([error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData]) {
            NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
            //通过之前保存的resumeData，获取断点的NSURLSessionTask，调用resume恢复下载
//            self.resumeData = resumeData;
            [self addMapWithURL:self.currentDownloadURL downloadState:DownloadStateFailure resumeData:resumeData];
            return;
        }
        // 下载失败
//        self.downloadState = DownloadStateFailure;
        [self addMapWithURL:self.currentDownloadURL downloadState:DownloadStateFailure resumeData:nil];
        
    } else {
        
        // 下载完成
//        self.downloadState = DownloadStateFinish;
        [self addMapWithURL:self.currentDownloadURL downloadState:DownloadStateFinish resumeData:nil];
        
        // 发送本地通知
        [self sendLocalNotification];
        // 下载完成后发布通知为1，即百分之百
        [self postDownloadProgressNotificationWithProgress:@"1"];
    }

}

#pragma clang diagnostic pop

/*
 任务下载完成时调用的方法：
 第一种情况:当任务在后台下载时完成时:
 先调用UIApplicationDelegate的 - URLSessionDidFinishEventsForBackgroundURLSession
 再调用UIApplicationDelegate的 - application: handleEventsForBackgroundURLSession: completionHandler:
 然后在调用NSURLSessionDownloadDelegate的- URLSession: task: didCompleteWithError:
 第二种情况:当任务在前台下载完成时：
 之调用UIApplicationDelegate的 - application: handleEventsForBackgroundURLSession: completionHandler:
 */

#pragma mark - UIApplicationDelegate 与后台任务相关的代理方法

/**
 * 这个主要就是用来处理大数据量的下载的，其保证应用即使在后台也不影响数据的上传和下载。用法：
 * 1.创建NSURLSession的backgroundSession，并对其进行配置
 * 2.使用该Session启动一个数据传输任务。
 * 3.在AppDelegate中实现方法告诉应用
 */
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
    
    // 你必须重新建立一个后台 seesion 的参照
    // 否则 NSURLSessionDownloadDelegate 和 NSURLSessionDelegate 方法会因为
    // 没有 对 session 的 delegate 设定而不会被调用。参见上面的 backgroundURLSession
    NSURLSession *backgroundSession = self.backgroundSession;
    
    NSLog(@"下载任务标识符:%@, 后台会话对象:%@", identifier, backgroundSession);
    
    // 将block 保存起来在 以后再处理 session 事件后更新 UI
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

#pragma mark - notify
- (void)postDownloadProgressNotificationWithProgress:(NSString *)progress {
//    NSLog(@"%@", [NSThread currentThread]);
    // 发布通知 回到主线程
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        if (self.backgroundDownloadDelegate && [self.backgroundDownloadDelegate respondsToSelector:@selector(xy_backgroundDownload:downloadprogressDidChange:)]) {
            [self.backgroundDownloadDelegate xy_backgroundDownload:self downloadprogressDidChange:progress];
        }
        
        
        NSDictionary *info = @{XYDownloadProgress: progress, XYDownloadURL: self.currentDownloadURL};
        
        [[NSNotificationCenter defaultCenter] postNotificationName:XYDownloadProgressNotification object:self.currentDownloadURL userInfo:info];
        
    }];
}

/// 发送本地通知
- (void)sendLocalNotification {
    [[UIApplication sharedApplication] scheduleLocalNotification:self.localNotification];
}


#pragma mark - set\get

- (void)setBackgroundSession:(NSURLSession *)backgroundSession {
    objc_setAssociatedObject(self, @selector(backgroundSession), backgroundSession, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


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
//    NSLog(@"%@", session);
    return session;
}


- (void)setDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    objc_setAssociatedObject(self, @selector(downloadTask), downloadTask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSURLSessionDownloadTask *)downloadTask {
    return objc_getAssociatedObject(self, @selector(downloadTask));
}

- (void)setResumeData:(NSData *)resumeData {
    objc_setAssociatedObject(self, @selector(resumeData), resumeData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSData *)resumeData {
    return objc_getAssociatedObject(self, @selector(resumeData));
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

- (void)setNotifyMessage:(NSString *)notifyMessage {
    objc_setAssociatedObject(self, @selector(notifyMessage), notifyMessage, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSString *)notifyMessage {
    return objc_getAssociatedObject(self, @selector(notifyMessage)) ?: @"下载完成了";
}


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

- (void)setBackgroundDownloadDelegate:(id<XYBackgroundDownloadProtocol>)backgroundDownloadDelegate {
    objc_setAssociatedObject(self, @selector(backgroundDownloadDelegate), backgroundDownloadDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<XYBackgroundDownloadProtocol>)backgroundDownloadDelegate {
    return objc_getAssociatedObject(self, @selector(backgroundDownloadDelegate));
}

- (void)setDownloadState:(DownloadState)downloadState {
    objc_setAssociatedObject(self, @selector(downloadState), @(downloadState), OBJC_ASSOCIATION_ASSIGN);
    
    if (self.backgroundDownloadDelegate && [self.backgroundDownloadDelegate respondsToSelector:@selector(xy_backgroundDownload:downloadStateDidChange:)]) {
        [self.backgroundDownloadDelegate xy_backgroundDownload:self downloadStateDidChange:downloadState];
    }
    
    // 发布状态发生改变的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:XYDownloadStateNotification object:self.currentDownloadURL userInfo:@{XYDownloadStateKey: @(downloadState)}];
    
}
- (DownloadState)downloadState {
    return [objc_getAssociatedObject(self, @selector(downloadState)) integerValue] ?: DownloadStateUnknown;
}

- (void)setDownProgress:(NSString *)downProgress {
    objc_setAssociatedObject(self, @selector(downProgress), downProgress, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)downProgress {
    return objc_getAssociatedObject(self, @selector(downProgress));
}


- (void)setDownloadResumeDataDict:(NSMutableDictionary *)downloadResumeDataDict {
    objc_setAssociatedObject(self, @selector(downloadResumeDataDict), downloadResumeDataDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableDictionary *)downloadResumeDataDict {
    id obj = objc_getAssociatedObject(self, @selector(downloadResumeDataDict));
    if (obj == nil) {
        self.downloadResumeDataDict = (obj = [NSMutableDictionary dictionaryWithCapacity:0]);
    }
    return obj;
}

- (void)setCurrentDownloadURL:(NSString *)currentDownloadURL {
    objc_setAssociatedObject(self, @selector(currentDownloadURL), currentDownloadURL, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSString *)currentDownloadURL {
    return objc_getAssociatedObject(self, @selector(currentDownloadURL));
}


@end
