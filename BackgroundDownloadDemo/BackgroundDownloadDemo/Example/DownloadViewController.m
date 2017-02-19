//
//  DownloadViewController.m
//  BackgroundDownloadDemo
//
//  Created by mofeini on 17/2/19.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "DownloadViewController.h"
#import "AppDelegate+XYBackgroundTask.h"

@interface DownloadViewController () <XYBackgroundDownloadProtocol>

@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (nonatomic, strong) AppDelegate *app;

@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 监听通知的方式 获取下载进度
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDownloadProgress:) name:XYDownloadProgressNotification object:nil];
    
    
}

#pragma mark - XYBackgroundDownloadProtocol
- (void)xy_backgroundDownload:(id)objc progress:(NSString *)progress {
    CGFloat fProgress = [progress floatValue];
    
    self.progressLabel.text = [NSString stringWithFormat:@"%.2f%%",fProgress * 100];
    self.progressView.progress = fProgress;
}

#pragma mark - notify 
//- (void)updateDownloadProgress:(NSNotification *)note {
//    CGFloat fProgress = [note.object floatValue];
//    
//    self.progressLabel.text = [NSString stringWithFormat:@"%.2f%%",fProgress * 100];
//    self.progressView.progress = fProgress;
//}

- (IBAction)download:(id)sender {
    
    
    [self.app xy_backgroundDownloadBeginWithURL:@"https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg"];
}

- (IBAction)pause:(id)sender {
    
    [self.app xy_backgroundDownloadPause];
}

- (IBAction)continue:(id)sender {
    
    [self.app xy_backgroundDownloadContinue];
}

- (AppDelegate *)app {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
