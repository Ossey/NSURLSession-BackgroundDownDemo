//
//  NSURLSession+CorrectedResumeData.h
//  BackgroundDownloadDemo
//
//  Created by mofeini on 17/2/19.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSURLSession (CorrectedResumeData)

/**
 * 根据resumeData继续下载任务
 *
 * @param   resumeData  针对iOS10以后对resumeData进行处理
 * @return  NSURLSessionDownloadTask
 */
- (NSURLSessionDownloadTask *)xy_downloadTaskWithResumeData:(NSData *)resumeData;

@end
