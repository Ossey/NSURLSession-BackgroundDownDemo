//
//  DownloadViewController.m
//  BackgroundDownloadDemo
//
//  Created by mofeini on 17/2/19.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "DownloadViewController.h"
#import "AppDelegate+XYBackgroundTask.h"

@interface DownloadViewController ()

@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (nonatomic, strong) AppDelegate *app;

@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDownloadProgress:) name:XYDownloadProgressNotification object:nil];
}

#pragma mark - notify 
- (void)updateDownloadProgress:(NSNotification *)note {
    CGFloat fProgress = [note.object floatValue];
    
    self.progressLabel.text = [NSString stringWithFormat:@"%.2f%%",fProgress * 100];
    self.progressView.progress = fProgress;
}

- (IBAction)download:(id)sender {
    
    
    [self.app xy_backgroundDownloadBeginWithURL:@"http://sw.bos.baidu.com/sw-search-sp/software/797b4439e2551/QQ_mac_5.0.2.dmg"];
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
