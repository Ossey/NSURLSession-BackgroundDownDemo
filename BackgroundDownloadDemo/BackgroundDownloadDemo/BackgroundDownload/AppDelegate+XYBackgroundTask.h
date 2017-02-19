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

@interface AppDelegate (XYBackgroundTask) <XYBackgroundDownloadProtocol>

/// 使用代理的问题: 一对多时，导致代理对象会被覆盖，因为AppDelegate对象始终只有一个，不管设置多少个backgroundDownloadDelegate都会被覆盖到只有一个，所以暂时先使用通知
@property (nonatomic, weak) id<XYBackgroundDownloadProtocol> backgroundDownloadDelegate;

@end
