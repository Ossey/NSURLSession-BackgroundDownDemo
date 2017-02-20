//
//  AppDelegate+XYBackgroundTask.h
//  BackgroundDownloadDemo
//
//  Created by mofeini on 17/2/19.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "AppDelegate.h"
#import "XYBackgroundDownloadProtocol.h"

extern NSString *const XYDownloadProgressNotification;
extern NSString *const XYDownloadStateNotification;
extern NSString *const XYDownloadProgress;
extern NSString *const XYDownloadURL;
extern NSString *const XYDownloadStateKey;

@interface AppDelegate (XYBackgroundTask) <XYBackgroundDownloadProtocol>

/// 使用代理的问题: 一个代理多次赋值代理对象时(同一个属性进行多次赋值，那必须是最后一次赋值生效)，AppDelegate对象始终只有一个，不管设置多少个backgroundDownloadDelegate都会被覆盖到只有一个，所以暂时先使用通知

@end
