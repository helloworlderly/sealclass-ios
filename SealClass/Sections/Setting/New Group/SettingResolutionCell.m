//
//  SettingTableViewCell.m
//  SealClass
//
//  Created by 张改红 on 2019/3/4.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "SettingResolutionCell.h"
#import "Masonry.h"
#import "RTCService.h"
@interface SettingResolutionCell()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *resolutionListView;
@property (nonatomic, strong) NSArray *resolutionArray;
@end;
@implementation SettingResolutionCell
+(SettingResolutionCell *)configCell:(UITableView *)tableView{
    SettingResolutionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingTableViewCell"];
    if (!cell) {
        cell = [[SettingResolutionCell alloc] initWithStyle:(UITableViewCellStyleValue1) reuseIdentifier:@"SettingTableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.resolutionArray = @[@"256x144",@"320x240",@"480x360",@"640x360",@"640x480",@"720x480",@"1280x720"];
        self.separatorInset = UIEdgeInsetsZero;
        self.layoutMargins = UIEdgeInsetsZero;
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews{
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.resolutionListView];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(22);
        make.top.equalTo(self.contentView).offset(14);
        make.height.offset(21);
        make.right.equalTo(self.contentView);
    }];
    [self.resolutionListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_left);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(7);
        make.bottom.equalTo(self.contentView);
        make.width.equalTo(self.titleLabel);
    }];
    [self setupResolutionListView];
}

- (void)setupResolutionListView{
    for (int i = 0; i < self.resolutionArray.count; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((i%2)*100,(i/2)*36, 100, 36)];
        [button setTitle:self.resolutionArray[i] forState:(UIControlStateNormal)];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button addTarget:self action:@selector(didClickButton:) forControlEvents:(UIControlEventTouchUpInside)];
        button.tag = 200+i;
        [button setTitleColor:HEXCOLOR(0x21C194) forState:(UIControlStateSelected)];
        [button setTitleColor:HEXCOLOR(0xffffff) forState:(UIControlStateNormal)];
        [self.resolutionListView addSubview:button];
        if ([self.resolutionArray[i] isEqualToString:[self getDefaultVideoSizePreset]]) {
            button.selected = YES;
        }
    }
}

- (void)didClickButton:(UIButton *)button{
    for (UIButton *btn in self.resolutionListView.subviews) {
        if (button.tag != btn.tag) {
            btn.selected = NO;
        }else{
            button.selected = YES;
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectResolution:)]) {
        [self.delegate didSelectResolution:button.tag - 200 + 1];
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
#pragma mark - Getters and setters
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = HEXCOLOR(0xffffff);
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.text = NSLocalizedStringFromTable(@"Resolution", @"SealClass", nil);
    }
    return _titleLabel;
}

- (UIView *)resolutionListView{
    if (!_resolutionListView) {
        _resolutionListView = [[UIView alloc] init];
    }
    return _resolutionListView;
}
@end
