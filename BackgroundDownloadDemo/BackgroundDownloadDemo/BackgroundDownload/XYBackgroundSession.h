//
//  XYBackgroundSession.h
//  BackgroundDownloadDemo
//
//  Created by mofeini on 17/2/21.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XYBackgroundDownloadProtocol.h"

extern NSString *const XYDownloadProgressNotification;

@interface XYBackgroundSession : NSObject <XYBackgroundDownloadProtocol>

/// 后台会话对象
@property (nonatomic, strong) NSURLSession *backgroundSession;

+ (instancetype)sharedInstance;

@end
