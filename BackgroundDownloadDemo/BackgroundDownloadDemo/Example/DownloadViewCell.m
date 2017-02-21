//
//  DownloadViewCell.m
//  BackgroundDownloadDemo
//
//  Created by mofeini on 17/2/19.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "DownloadViewCell.h"
#import "DownButton.h"
#import "XYBackgroundSession.h"
#import "AppDelegate.h"

@interface DownloadViewCell () <XYBackgroundDownloadProtocol>

@property (weak, nonatomic) IBOutlet DownButton *downBtn;
@property (weak, nonatomic) IBOutlet UILabel *fileName;
@property (weak, nonatomic) IBOutlet UILabel *fileSize;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (nonatomic, assign) BOOL isFirst;

@end

@implementation DownloadViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.downBtn addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
    self.isFirst = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.downBtn.tintColor = [UIColor clearColor];
    
    __weak typeof(self) weakSelf = self;
    [[XYBackgroundSession sharedInstance] xy_downloadState:^(DownloadState state) {
        [weakSelf downloadStateDidChange:state];
    }];
}

- (void)download:(UIButton *)btn {
    
    if (!btn.selected) {
        
        // 只要第一次才开始下载，其他都是继续下载
        if (self.isFirst == YES) {
            // 开始下载
            __weak typeof(self) weakSelf = self;
            NSString *url = @"http://106.2.184.232:9999/sw.bos.baidu.com/sw-search-sp/software/f4ec363a68914/bdbrowserSetup-8.7.100.4208-4580_11000003.exe";
            [[XYBackgroundSession sharedInstance] xy_download:url progress:^(CGFloat totalBytesWritten, CGFloat totalBytesExpectedToWrite, NSString *downProgress) {
                
                [weakSelf downloadProgress:downProgress];
                
            } success:^(NSURLSessionDownloadTask *task, NSString *filePath) {
                NSLog(@"%@", filePath);
                
            } failure:^(NSError *error) {
                NSLog(@"%@", error);
            }];
            
        } else {
            // 继续下载
            [[XYBackgroundSession sharedInstance] xy_continueDownload];
        }
        
    } else {
        // 暂停
        [[XYBackgroundSession sharedInstance] xy_pauseDownload];
    }
    
    self.isFirst = NO;
    btn.selected = !btn.isSelected;
}


- (void)downloadProgress:(NSString *)progress {
    
    CGFloat fProgress = [progress floatValue];
    self.progressLabel.text = [NSString stringWithFormat:@"%.2f%%",fProgress * 100];
    self.progressView.progress = fProgress;
}

- (void)downloadStateDidChange:(DownloadState)state {
    
    switch (state) {
        case DownloadStatePause:
            [self.downBtn setTitle:@"继续" forState:UIControlStateNormal];
            break;
        case DownloadStateDownloading:
            [self.downBtn setTitle:@"暂停" forState:UIControlStateSelected];
            break;
        case DownloadStateFinish:
            self.selected = NO;
            [self.downBtn setTitle:@"下载完成" forState:UIControlStateNormal];
            
            break;
        case DownloadStateFailure:
            [self.downBtn setTitle:@"再试一次" forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

- (void)dealloc {
    
    [[XYBackgroundSession sharedInstance] xy_release];
    
    NSLog(@"%s", __func__);
}

@end
