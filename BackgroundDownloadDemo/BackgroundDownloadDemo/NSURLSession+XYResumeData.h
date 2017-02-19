//
//  NSURLSession+XYResumeData.h
//  BackgroundDownloadDemo
//
//  Created by mofeini on 17/2/19.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSURLSession (XYResumeData)

/// 根据resumeData继续下载任务
/// 针对iOS对resumeData进行处理
- (NSURLSessionDownloadTask *)xy_downloadTaskWithResumeData:(NSData *)resumeData;

@end
