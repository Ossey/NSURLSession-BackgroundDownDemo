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
    
    self.title = @"下载";
    
    // 监听通知的方式 获取下载进度
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDownloadProgress:) name:XYDownloadProgressNotification object:nil];
    
    
}

#pragma mark - XYBackgroundDownloadProtocol
// 代理方式 获取下载进度
- (void)xy_backgroundDownload:(id)objc downloadprogressDidChange:(NSString *)progress {
    CGFloat fProgress = [progress floatValue];
    
    self.progressLabel.text = [NSString stringWithFormat:@"%.2f%%",fProgress * 100];
    self.progressView.progress = fProgress;
    
//    NSLog(@"%@", [NSThread currentThread]);
}

#pragma mark - notify 
//- (void)updateDownloadProgress:(NSNotification *)note {
//    CGFloat fProgress = [note.object floatValue];
//    
//    self.progressLabel.text = [NSString stringWithFormat:@"%.2f%%",fProgress * 100];
//    self.progressView.progress = fProgress;
//}


#pragma mark - 下载操作
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
