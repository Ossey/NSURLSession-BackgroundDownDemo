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


@end
