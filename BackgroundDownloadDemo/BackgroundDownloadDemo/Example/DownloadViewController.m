//
//  DownloadViewController.m
//  BackgroundDownloadDemo
//
//  Created by mofeini on 17/2/19.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "DownloadViewController.h"
#import "AppDelegate+XYBackgroundTask.h"
#import "Download2ViewController.h"

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDownloadProgress:) name:XYDownloadProgressNotification object:nil];
    
}

- (IBAction)jumpTo2Vc:(id)sender {
    
    [self.navigationController pushViewController:[Download2ViewController new] animated:YES];
}

#pragma mark - XYBackgroundDownloadProtocol
// 代理方式 获取下载进度
//- (void)xy_backgroundDownload:(id)objc downloadprogressDidChange:(NSString *)progress {
//    
//    CGFloat fProgress = [progress floatValue];
//    
//    self.progressLabel.text = [NSString stringWithFormat:@"%.2f%%",fProgress * 100];
//    self.progressView.progress = fProgress;
//    
////    NSLog(@"%@", [NSThread currentThread]);
//}

#pragma mark - notify 
- (void)updateDownloadProgress:(NSNotification *)note {
    NSString *url = @"http://106.2.184.232:9999/sw.bos.baidu.com/sw-search-sp/software/89179b0b248b1/QQ_8.9.20026.0_setup.exe";
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


#pragma mark - 下载操作
- (IBAction)download:(id)sender {
    
    
    [self.app xy_backgroundDownloadBeginWithURL:@"http://106.2.184.232:9999/sw.bos.baidu.com/sw-search-sp/software/89179b0b248b1/QQ_8.9.20026.0_setup.exe"];
}

- (IBAction)pause:(id)sender {
    
    [self.app xy_backgroundDownloadPause:@"http://106.2.184.232:9999/sw.bos.baidu.com/sw-search-sp/software/89179b0b248b1/QQ_8.9.20026.0_setup.exe"];
}

- (IBAction)continue:(id)sender {
    
    [self.app xy_backgroundDownloadContinue:@"http://106.2.184.232:9999/sw.bos.baidu.com/sw-search-sp/software/89179b0b248b1/QQ_8.9.20026.0_setup.exe"];
}

- (AppDelegate *)app {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}



@end
