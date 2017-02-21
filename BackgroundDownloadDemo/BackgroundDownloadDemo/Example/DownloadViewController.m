//
//  DownloadViewController.m
//  BackgroundDownloadDemo
//
//  Created by mofeini on 17/2/19.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "DownloadViewController.h"
#import "Download2ViewController.h"
#import "XYBackgroundSession.h"
#import "AppDelegate.h"

@interface DownloadViewController () <XYBackgroundDownloadProtocol>

@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (nonatomic, strong) AppDelegate *app;


@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"下载";
    
    [[XYBackgroundSession sharedInstance] xy_downloadState:^(DownloadState state) {
        NSLog(@"%ld", state);
    }];

}

- (IBAction)jumpTo2Vc:(id)sender {
    
    [self.navigationController pushViewController:[Download2ViewController new] animated:YES];
}



#pragma mark - 下载操作
- (IBAction)download:(id)sender {
    
    [[XYBackgroundSession sharedInstance] xy_download:@"https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg" progress:^(CGFloat totalBytesWritten, CGFloat totalBytesExpectedToWrite, NSString *downProgress) {
        
        CGFloat fProgress = [downProgress floatValue];
        
        self.progressLabel.text = [NSString stringWithFormat:@"%.2f%%",fProgress * 100];

        self.progressView.progress = fProgress;
        
    } success:^(NSURLSessionDownloadTask *task, NSString *filePath) {
        
        NSLog(@"%@", filePath);
        
    } failure:^(NSError *error) {
        
    }];
}

- (IBAction)pause:(id)sender {
    
    [[XYBackgroundSession sharedInstance] xy_pauseDownload];
}

- (IBAction)continue:(id)sender {
    
    [[XYBackgroundSession sharedInstance] xy_continueDownload];
}

- (AppDelegate *)app {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}



@end
