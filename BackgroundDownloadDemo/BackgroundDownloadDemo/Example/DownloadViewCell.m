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

@interface DownloadViewCell ()

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
    self.isFirst = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.downBtn.tintColor = [UIColor clearColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDownloadProgress:) name:XYDownloadProgressNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDownloadSate:) name:XYDownloadStateNotification object:nil];
}

- (void)download:(UIButton *)btn {
    
    NSString *url = @"https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg";
    
    if (!btn.selected) {
        
        // 只要第一次才开始下载，其他都是继续下载
        if (self.isFirst == YES) {
            // 开始下载
            [self.app xy_backgroundDownloadBeginWithURL:url];
            
        } else {
            // 继续下载
            [self.app xy_backgroundDownloadContinue:url];
        }
        
    } else {
        // 暂停
        [self.app xy_backgroundDownloadPause:url];
    }
    
    self.isFirst = NO;
    btn.selected = !btn.isSelected;
}

- (AppDelegate *)app {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)updateDownloadProgress:(NSNotification *)note {
    NSString *url = @"https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg";
    if ([note.object isKindOfClass:[NSString class]]) {
        NSString *obj = note.object;
        if ([obj isEqualToString:url]) {
            
            NSString *progress = note.userInfo[XYDownloadProgress];
            
            CGFloat fProgress = [progress floatValue];
            self.progressLabel.text = [NSString stringWithFormat:@"%.2f%%",fProgress * 100];
            self.progressView.progress = fProgress;
        }
    }
    
    
}

- (void)updateDownloadSate:(NSNotification *)note {
    
    NSString *url = @"https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg";
    if ([note.object isKindOfClass:[NSString class]]) {
        NSString *obj = note.object;
        if ([obj isEqualToString:url]) {
            
            // 获取下载状态
            DownloadState state = [note.userInfo[XYDownloadStateKey] integerValue];
            switch (state) {
                case DownloadStatePause:
                    [self.downBtn setTitle:@"继续" forState:UIControlStateNormal];
                    break;
                case DownloadStateDownloading:
                    [self.downBtn setTitle:@"暂停" forState:UIControlStateSelected];
                    
                    break;
                case DownloadStateFinish:
                    [self.downBtn setTitle:@"下载完成" forState:UIControlStateSelected];
                    self.downBtn.selected = YES;
                    self.downBtn.enabled = NO;
                    break;
                case DownloadStateFailure:
                    [self.downBtn setTitle:@"再试一次" forState:UIControlStateNormal];
                    break;
                    
                default:
                    break;
            }

        }
    
    }
}

- (void)dealloc {
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
