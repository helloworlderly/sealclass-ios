//
//  SettingView.m
//  SealClass
//
//  Created by 张改红 on 2019/4/22.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "SettingView.h"
#import "SettingResolutionCell.h"
@interface SettingView ()<UITableViewDelegate, UITableViewDataSource, SettingResolutionCellDelegate>
@property (nonatomic, strong) NSArray *resolutionArray;
@end
@implementation SettingView
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.scrollEnabled = NO;
        self.tableHeaderView = [self getHeaderView];
        self.tableFooterView = [UIView new];
        self.backgroundColor = [HEXCOLOR(0x000000) colorWithAlphaComponent:0.6];
        self.dataSource = self;
        self.delegate = self;
        if (@available(iOS 11.0, *)) {
            self.insetsContentViewsToSafeArea = NO;
        }
    }
    return self;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SettingResolutionCell *cell = [SettingResolutionCell configCell:tableView];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 191;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

#pragma mark - SettingResolutionCellDelegate
- (void)didSelectResolution:(RongRTCVideoSizePreset)perset{
    RongRTCVideoCaptureParam *param = [RTCService sharedInstance].captureParam;
    param.videoSizePreset = perset;
    [self hiden];
}

#pragma mark - Pubic

- (void)showSettingViewInView:(UIView *)view{
    [view addSubview:self];
}

- (void)hiden{
    [self removeFromSuperview];
}


#pragma mark - Helper
- (UIView *)getHeaderView{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 45)];
    label.text = NSLocalizedStringFromTable(@"Setting", @"SealClass", nil);
    label.textColor = HEXCOLOR(0xffffff);
    label.font = [UIFont systemFontOfSize:16.5];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}
@end
