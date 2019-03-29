//
//  VideoListCell.m
//  SealClass
//
//  Created by liyan on 2019/3/5.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "VideoListCell.h"
#import "Masonry.h"
#import "RTCService.h"
#import "ClassroomService.h"

#define  RoleAssistantColor [UIColor colorWithHexString:@"F5A623" alpha:1]
#define  RoleTeacherColor  [UIColor colorWithHexString:@"FF5500" alpha:1]

@interface VideoListCell()

@property (nonatomic, strong) UIView *backGroundView;
@property (nonatomic, strong) UILabel *roleLable;
@property (nonatomic, strong) UILabel *nameLable;
@property (nonatomic, strong) UILabel *promptLable;

@end

@implementation VideoListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        [self addSubViews];
    }
    return self;
}

- (void)addSubViews {
    [self.contentView addSubview:self.backGroundView];
    [self.contentView addSubview:self.WaitLable];
    [self.contentView addSubview:self.promptLable];
    [self.contentView addSubview:self.videoView];
    [self.contentView addSubview:self.roleLable];
    [self.contentView addSubview:self.nameLable];

    self.videoView.frame = CGRectMake(0, 10, 112, 94.0-10);
   
    [self.backGroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(0);
        make.top.equalTo(self.contentView.mas_top).offset(10);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(0);
        make.right.equalTo(self.contentView.mas_right).offset(0);
    }];
    [self.WaitLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.videoView.mas_centerY);
        make.centerX.equalTo(self.videoView.mas_centerX);
        make.height.equalTo(@25);
        make.width.equalTo(@84);
    }];
    [self.promptLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.videoView.mas_centerY);
        make.centerX.equalTo(self.videoView.mas_centerX);
        make.height.equalTo(@25);
        make.width.equalTo(@84);
    }];
    [self.roleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(4);
        make.top.equalTo(self.contentView.mas_top).offset(14);
        make.height.equalTo(@18);
        make.width.equalTo(@24);
    }];
    [self.nameLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(4);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-4);
        make.height.equalTo(@12);
        make.width.equalTo(self.contentView.mas_width);
    }];

}


- (void)setModel:(RoomMember *)member showAssistantPrompt:(BOOL)assistentPrompt showTeacherPrompt:(BOOL)teacherPrompt {
    [self resetDefaultStyle];
    if (member == nil) {
        return;
    }
    if (member.userId == nil) {
        self.promptLable.hidden = YES;
        self.nameLable.hidden = YES;
        self.roleLable.hidden = YES;
        self.WaitLable.hidden = NO;
        self.videoView.hidden = YES;
    }else {
        switch (member.role) {
            case RoleAssistant:
                if (assistentPrompt) {
                    self.promptLable.hidden = NO;
                    self.videoView.hidden = YES;
                    self.promptLable.text = NSLocalizedStringFromTable(@"Assitaning", @"SealClass", nil);
                }else {
                    self.videoView.hidden = NO;
                    self.promptLable.hidden = YES;
                }
                self.roleLable.backgroundColor = RoleAssistantColor;
                self.roleLable.text = NSLocalizedStringFromTable(@"RoleAssitant", @"SealClass", nil);
                break;
            case RoleTeacher:
                if (teacherPrompt) {
                    self.videoView.hidden = YES;
                    self.promptLable.hidden = NO;
                    self.promptLable.text = NSLocalizedStringFromTable(@"Teaching", @"SealClass", nil);
                }else {
                    self.videoView.hidden = NO;
                    self.promptLable.hidden = YES;
                }
                self.roleLable.backgroundColor = RoleTeacherColor;
                self.roleLable.text = NSLocalizedStringFromTable(@"RoleTeacher", @"SealClass", nil);
                break;
            case RoleStudent:
                self.roleLable.hidden = YES;
                break;
            case RoleAudience:
                self.roleLable.hidden =YES;
                
                break;
                
            default:
                break;
        }
        [self remakeNameLable:member];
        [self renderVideo:member];
    }
}

- (void)resetDefaultStyle {
    self.nameLable.text = nil;
    self.roleLable.text = nil;
    self.roleLable.backgroundColor = [UIColor clearColor];
    self.roleLable.hidden = NO;
    self.nameLable.hidden = NO;
    self.WaitLable.hidden = YES;
    self.promptLable.text = nil;
    self.promptLable.hidden = YES;
    self.videoView.hidden = NO;
    [self cancelVideo];
}

- (void)renderVideo:(RoomMember *)member {
    if([[ClassroomService sharedService].currentRoom.currentDisplayURI isEqualToString:member.userId] || member.role == RoleAudience) {
        return;
    }
    if([[ClassroomService sharedService].currentRoom.currentMemberId isEqualToString:member.userId]) {
        RoomMember *curMemeber =[ClassroomService sharedService].currentRoom.currentMember;
        [[RTCService sharedInstance] renderLocalVideoOnView:self.videoView cameraEnable:curMemeber.cameraEnable];
    }else {
        [[RTCService sharedInstance] renderRemoteVideoOnView:self.videoView forUser:member.userId];
    }
}

- (void)cancelVideo {
    [[RTCService sharedInstance] cancelRenderVideoInView:self.videoView];
}

- (void)remakeNameLable:(RoomMember *)member {
    NSString * nameTxt = [[NSString alloc] init];
    nameTxt =  member.name.length > 5 ? [NSString stringWithFormat:@"%@...",[member.name substringToIndex:5]] : member.name;
    self.nameLable.text = nameTxt;
}

- (UIView *)backGroundView {
    if(!_backGroundView) {
        _backGroundView = [[UIView alloc] init];
        _backGroundView.backgroundColor = [UIColor colorWithHexString:@"3D4041" alpha:1];
        _backGroundView.hidden = NO;
    }
    return _backGroundView;
}

- (UIView *)videoView {
    if(!_videoView) {
        _videoView = [[UIView alloc] init];
        _videoView.backgroundColor = [UIColor colorWithHexString:@"3D4041" alpha:1];
    }
    return _videoView;
}

- (UILabel *)roleLable {
    if(!_roleLable) {
        _roleLable = [[UILabel alloc] init];
        _roleLable.font = [UIFont systemFontOfSize:10];
        _roleLable.textAlignment = NSTextAlignmentCenter;
        _roleLable.textColor = [UIColor colorWithHexString:@"FFFFFF" alpha:1];
        _roleLable.layer.cornerRadius = 4;
        _roleLable.layer.masksToBounds = YES;
    }
    return _roleLable;
}
- (UILabel *)nameLable {
    if(!_nameLable) {
        _nameLable = [[UILabel alloc] init];
        _nameLable.font = [UIFont systemFontOfSize:11];
        _nameLable.numberOfLines = 1;
        _nameLable.textAlignment = NSTextAlignmentLeft;
        _nameLable.textColor = [UIColor colorWithHexString:@"FFFFFF" alpha:1];
    }
    return _nameLable;
}

- (UILabel *)WaitLable {
    if(!_WaitLable) {
        _WaitLable = [[UILabel alloc] init];
        _WaitLable.font = [UIFont systemFontOfSize:9];
        _WaitLable.numberOfLines = 2;
        _WaitLable.textAlignment = NSTextAlignmentCenter;
        _WaitLable.backgroundColor = [UIColor clearColor];
        _WaitLable.textColor = [UIColor colorWithHexString:@"FFFFFF" alpha:1];
        _WaitLable.text =  NSLocalizedStringFromTable(@"WaitTeacher", @"SealClass", nil);
        _WaitLable.hidden = YES;
    }
    return _WaitLable;
}

- (UILabel *)promptLable {
    if(!_promptLable) {
        _promptLable = [[UILabel alloc] init];
        _promptLable.font = [UIFont systemFontOfSize:9];
        _promptLable.numberOfLines = 1;
        _promptLable.textAlignment = NSTextAlignmentCenter;
        _promptLable.backgroundColor = [UIColor clearColor];
        _promptLable.textColor = [UIColor colorWithHexString:@"FFFFFF" alpha:1];
        _promptLable.text =  NSLocalizedStringFromTable(@"WaitTeacher", @"SealClass", nil);
        _promptLable.hidden = YES;
    }
    return _promptLable;
}

@end
