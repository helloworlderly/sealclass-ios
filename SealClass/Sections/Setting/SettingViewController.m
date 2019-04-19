//
//  SettingViewController.m
//  SealClass
//
//  Created by 张改红 on 2019/3/4.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "SettingViewController.h"
#import "SelectResolutionController.h"
#import "SettingTableViewCell.h"
#import "RTCService.h"
@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedStringFromTable(@"Setting", @"SealClass", nil);
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = HEXCOLOR(0xf2f2f3);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

//设置是否隐藏
- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SettingTableViewCell *cell = [SettingTableViewCell configCell:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        cell.titleLabel.textColor = HEXCOLOR(0x979797);
        cell.titleLabel.font = [UIFont systemFontOfSize:12];
        cell.titleLabel.text = NSLocalizedStringFromTable(@"Resolution", @"SealClass", nil);
    }else if (indexPath.row == 1) {
        cell.titleLabel.text = [self getDefaultVideoSizePreset];
        cell.arrowImageView.hidden = NO;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 28;
    }
    return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 1) {
        SelectResolutionController *selectResolutionVC = [[SelectResolutionController alloc] init];
        [self.navigationController pushViewController:selectResolutionVC animated:YES];
    }
}

#pragma mark - Helper
- (NSString *)getDefaultVideoSizePreset{
    RongRTCVideoCaptureParam *param = [RTCService sharedInstance].captureParam;
    NSString *videoSizeText = @"640x480";
    switch (param.videoSizePreset) {
        case RongRTCVideoSizePreset256x144:
            videoSizeText = @"256x144";
            break;
        case RongRTCVideoSizePreset320x240:
            videoSizeText = @"320x240";
            break;
        case RongRTCVideoSizePreset480x360:
            videoSizeText = @"480x360";
            break;
        case RongRTCVideoSizePreset640x360:
            videoSizeText = @"640x360";
            break;
        case RongRTCVideoSizePreset640x480:
            videoSizeText = @"640x480";
            break;
        case RongRTCVideoSizePreset720x480:
            videoSizeText = @"720x480";
            break;
        case RongRTCVideoSizePreset1280x720:
            videoSizeText = @"1280x720";
            break;
        default:
            break;
    }
    return videoSizeText;
}
@end
