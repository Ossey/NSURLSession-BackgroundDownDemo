//
//  Download2ViewController.m
//  BackgroundDownloadDemo
//
//  Created by mofeini on 17/2/19.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "Download2ViewController.h"
#import "DownloadViewCell.h"

static NSString *const cellIdentfier = @"DownloadViewCell";

@interface Download2ViewController () <UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@end

@implementation Download2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.tableView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.tableView.frame = self.view.bounds;
}


- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        [_tableView registerNib:[UINib nibWithNibName:@"DownloadViewCell" bundle:nil] forCellReuseIdentifier:cellIdentfier];
        _tableView.dataSource = self;
        _tableView.rowHeight = 88;
    }
    return _tableView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DownloadViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentfier forIndexPath:indexPath];
    
    return cell;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

@end
