//
//  AppDelegate+XYWindow.m
//  BackgroundDownloadDemo
//
//  Created by mofeini on 17/2/19.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "AppDelegate+XYWindow.h"
#import <objc/runtime.h>
#import "Download2ViewController.h"
#import "AppDelegate+XYBackgroundTask.h"


@implementation AppDelegate (XYWindow)

- (void)setWindow:(UIWindow *)window {
    objc_setAssociatedObject(self, @selector(window), window, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (UIWindow *)window {
    
    UIWindow *w = objc_getAssociatedObject(self, @selector(window));
    if (w == nil) {
        self.window = (w = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds]);
        Download2ViewController *vc = [Download2ViewController new];
//        __weak typeof(self) weakSelf = self;
//       weakSelf.backgroundDownloadDelegate = vc;
        w.rootViewController = [[UINavigationController alloc] initWithRootViewController:vc];
        
    }

    return w;
}

@end
