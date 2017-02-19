//
//  DownloadViewCell.m
//  BackgroundDownloadDemo
//
//  Created by mofeini on 17/2/19.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "DownloadViewCell.h"
#import "DownButton.h"
#import "AppDelegate+XYBackgroundTask.h"

@interface DownloadViewCell () <XYBackgroundDownloadProtocol>

@property (weak, nonatomic) IBOutlet DownButton *downBtn;
@property (weak, nonatomic) IBOutlet UILabel *fileName;
@property (weak, nonatomic) IBOutlet UILabel *fileSize;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic, weak) AppDelegate *app;

@property (nonatomic, assign) BOOL isFirst;

@end

@implementation DownloadViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.downBtn addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
    self.app.backgroundDownloadDelegate = self;
    self.isFirst = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)download:(UIButton *)btn {
    
    if (!btn.selected) {
        
        // 只要第一次才开始下载，其他都是继续下载
        if (self.isFirst == YES) {
            // 开始下载
            [self.app xy_backgroundDownloadBeginWithURL:@"https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg"];
            
        } else {
            // 继续下载
            [self.app xy_backgroundDownloadContinue];
        }
        
    } else {
        // 暂停
        [self.app xy_backgroundDownloadPause];
    }
    
    self.isFirst = NO;
    btn.selected = !btn.isSelected;
}

- (AppDelegate *)app {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - XYBackgroundDownloadProtocol
- (void)xy_backgroundDownload:(id)objc downloadprogressDidChange:(NSString *)progress {
    
    
    CGFloat fProgress = [progress floatValue];
    self.progressLabel.text = [NSString stringWithFormat:@"%.2f%%",fProgress * 100];
    self.progressView.progress = fProgress;
}

- (void)xy_backgroundDownload:(id)objc downloadStateDidChange:(DownloadState)state {
    
    switch (state) {
        case DownloadStatePause:
            [self.downBtn setTitle:@"继续" forState:UIControlStateNormal];
            break;
        case DownloadStateDownloading:
            [self.downBtn setTitle:@"暂停" forState:UIControlStateNormal];
            break;
        case DownloadStateFinish:
            [self.downBtn setTitle:@"完成" forState:UIControlStateNormal];
            break;
        case DownloadStateFailure:
            [self.downBtn setTitle:@"再试一次" forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

- (void)dealloc {
    
    [self.app xy_clear];
}

@end
