//
//  PersonListCell.m
//  SealClass
//
//  Created by liyan on 2019/3/5.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "PersonListCell.h"
#import "Masonry.h"
#import "ClassroomService.h"

#define PCellButtonCount 6
#define PCellButtonWidth 22
#define PCellButtonMargin ((240 - 6 * 22) / 7)

@interface PersonListCell()

@property (nonatomic, strong) UIButton *setTransferBtn;
@property (nonatomic, strong) UIButton *setSpeakerBtn;
@property (nonatomic, strong) UIButton *setVoiceBtn;
@property (nonatomic, strong) UIButton *setCameraBtn;
@property (nonatomic, strong) UIButton *setDowngradeBtn;
@property (nonatomic, strong) UIButton *deletePersonBtn;
@property (nonatomic, strong) NSArray *buttonImageArray;
@property (nonatomic, strong) NSArray *buttonDisableImageArray;
@property (nonatomic, strong) NSArray *buttonHighlightedImageArray;

@end

@implementation PersonListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.buttonImageArray = @[@"transfer", @"speaker", @"voice", @"camera", @"downgrade", @"deletelperson"];
        self.buttonDisableImageArray = @[@"transfer_disable",@"speaker_disable", @"voice_disable", @"camera_disable", @"downgrade_disable", @"deletelperson_disable"];
        self.buttonHighlightedImageArray = @[@"transfer_selected", @"speaker_selected", @"voice_selected", @"camera_selected", @"downgrade_selected", @"deletelperson_selected"];
        [self.buttonArray addObjectsFromArray:@[self.setTransferBtn,self.setSpeakerBtn,self.setVoiceBtn,self.setCameraBtn,self.setDowngradeBtn,self.deletePersonBtn]];
        [self addSubviews];
        [self setButtonDefaultStyle];
    }
    return self;
}

- (void)addSubviews {
    [self.contentView addSubview:self.setTransferBtn];
    [self.contentView addSubview:self.setSpeakerBtn];
    [self.contentView addSubview:self.setVoiceBtn];
    [self.contentView addSubview:self.setCameraBtn];
    [self.contentView addSubview:self.setDowngradeBtn];
    [self.contentView addSubview:self.deletePersonBtn];
    [self.buttonArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:PCellButtonWidth leadSpacing:PCellButtonMargin tailSpacing:PCellButtonMargin];
    [self.buttonArray mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(PCellButtonMargin);
        make.height.equalTo(@PCellButtonWidth);
    }];
}

- (void)tapEvent:(UIButton *)btn {
    btn.selected = !btn.selected;
    if(self.delegate && [self.delegate respondsToSelector:@selector(PersonListCell:didTapButton:)]) {
        [self.delegate PersonListCell:self didTapButton:btn];
    }
}

- (NSMutableArray *)buttonArray {
    if (!_buttonArray) {
        _buttonArray = [[NSMutableArray alloc] init];
    }
    return _buttonArray;
}

- (void)setModel:(RoomMember *)member {
    if (!member ) {
        return;
    }
    self.member = member;
    [self setButtonDefaultStyle];
    
    RoomMember *currentMember = [ClassroomService sharedService].currentRoom.currentMember;
    SealClassLog(@"memberID = %@ ,memberRole = %lu",member.userId,(unsigned long)member.role);
    SealClassLog(@"currentMemberID = %@ ,currentMemberRole = %lu",currentMember.userId,(unsigned long)currentMember.role);
    switch (currentMember.role) {
        case RoleAssistant:
                [self refreshCameraAndMicoroPhone:self.setVoiceBtn enable:member.microphoneEnable];
                [self refreshCameraAndMicoroPhone:self.setCameraBtn enable:member.cameraEnable];
            if (member.role == RoleTeacher) {
                [self setButton:self.setSpeakerBtn enable:NO];
            }
            if (member.role == RoleAudience) {
                [self setButton:self.setTransferBtn enable:NO];
                [self setButton:self.setSpeakerBtn enable:NO];
                [self setButton:self.setVoiceBtn enable:NO];
                [self setButton:self.setCameraBtn enable:NO];
                [self changeUpgradeButtonEnable:YES];
                [self setButton:self.deletePersonBtn enable:YES];
            }
            break;
            
        case RoleTeacher:  case RoleStudent:  case RoleAudience:
            [self setButton:self.setTransferBtn enable:NO];
            [self setButton:self.setSpeakerBtn enable:NO];
            [self setButton:self.setVoiceBtn enable:NO];
            [self setButton:self.setCameraBtn enable:NO];
            if (member.role == RoleAudience) {
                [self changeUpgradeButtonEnable:NO];
            }else {
                [self setButton:self.setDowngradeBtn enable:NO];
            }
            [self setButton:self.deletePersonBtn enable:NO];
            break;
            
        default:
            break;
    }
}

- (void)refreshCameraAndMicoroPhone:(UIButton *)button enable:(BOOL)enable {
    if (button.tag == PersonListCellActionTagSetVoice) {
        enable ?  [self.setVoiceBtn setBackgroundImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal] :[self.setVoiceBtn setBackgroundImage:[UIImage imageNamed:@"voice_close"] forState:UIControlStateNormal];
    }
    if (button.tag == PersonListCellActionTagSetCamera) {
        enable ?  [self.setCameraBtn setBackgroundImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal] :[self.setCameraBtn setBackgroundImage:[UIImage imageNamed:@"camera_close"] forState:UIControlStateNormal];
    }
}

- (void)changeUpgradeButtonEnable:(BOOL)enable {
    if (enable) {
        self.setDowngradeBtn.enabled = YES;
        [self.setDowngradeBtn setBackgroundImage:[UIImage imageNamed:@"upgrade"] forState:UIControlStateNormal];
    }else {
        self.setDowngradeBtn.enabled = NO;
        [self.setDowngradeBtn setBackgroundImage:[UIImage imageNamed:@"upgrade_disable"] forState:UIControlStateNormal];
    }
    [self.setDowngradeBtn setBackgroundImage:[UIImage imageNamed:@"upgrade_selected"] forState:UIControlStateHighlighted];
    
}

- (void)setButton:(UIButton *)button enable:(BOOL)enable {
    button.enabled = enable;
    if (enable) {
        [button setBackgroundImage:[UIImage imageNamed:[self.buttonImageArray objectAtIndex:button.tag]] forState:UIControlStateNormal];
    }else {
        [button setBackgroundImage:[UIImage imageNamed:[self.buttonDisableImageArray objectAtIndex:button.tag]] forState:UIControlStateNormal];
    }
    [button setBackgroundImage:[UIImage imageNamed:[self.buttonHighlightedImageArray objectAtIndex:button.tag]] forState:UIControlStateHighlighted];

}

- (void)setButtonDefaultStyle {
    [self setButton:self.setTransferBtn enable:YES];
    [self setButton:self.setSpeakerBtn enable:YES];
    [self setButton:self.setVoiceBtn enable:YES];
    [self setButton:self.setCameraBtn enable:YES];
    [self setButton:self.setDowngradeBtn enable:YES];
    [self setButton:self.deletePersonBtn enable:YES];
}

- (UIButton *)setTransferBtn {
    if(!_setTransferBtn) {
        _setTransferBtn = [[UIButton alloc] init];
        [_setTransferBtn addTarget:self action:@selector(tapEvent:) forControlEvents:UIControlEventTouchUpInside];
        _setTransferBtn.tag = PersonListCellActionTagAssistantTransfer;
        
    }
    return _setTransferBtn;
}
- (UIButton *)setSpeakerBtn {
    if(!_setSpeakerBtn) {
        _setSpeakerBtn = [[UIButton alloc] init];
        [_setSpeakerBtn addTarget:self action:@selector(tapEvent:) forControlEvents:UIControlEventTouchUpInside];
        _setSpeakerBtn.tag = PersonListCellActionTagSetSpeaker;
    }
    return _setSpeakerBtn;
}
- (UIButton *)setVoiceBtn {
    if(!_setVoiceBtn) {
        _setVoiceBtn = [[UIButton alloc] init];
        [_setVoiceBtn addTarget:self action:@selector(tapEvent:) forControlEvents:UIControlEventTouchUpInside];
        _setVoiceBtn.tag = PersonListCellActionTagSetVoice;
    }
    return _setVoiceBtn;
}
- (UIButton *)setCameraBtn {
    if(!_setCameraBtn) {
        _setCameraBtn = [[UIButton alloc] init];
        [_setCameraBtn addTarget:self action:@selector(tapEvent:) forControlEvents:UIControlEventTouchUpInside];
        _setCameraBtn.tag = PersonListCellActionTagSetCamera;
        
    }
    return _setCameraBtn;
}
- (UIButton *)setDowngradeBtn {
    if(!_setDowngradeBtn) {
        _setDowngradeBtn = [[UIButton alloc] init];
        [_setDowngradeBtn addTarget:self action:@selector(tapEvent:) forControlEvents:UIControlEventTouchUpInside];
        _setDowngradeBtn.tag =  PersonListCellActionTagDownGrade;
        
    }
    return _setDowngradeBtn;
}
- (UIButton *)deletePersonBtn {
    if(!_deletePersonBtn) {
        _deletePersonBtn = [[UIButton alloc] init];
        _deletePersonBtn.tag =  PersonListCellActionTagDeletelPerson;
        [_deletePersonBtn addTarget:self action:@selector(tapEvent:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _deletePersonBtn;
}

@end

