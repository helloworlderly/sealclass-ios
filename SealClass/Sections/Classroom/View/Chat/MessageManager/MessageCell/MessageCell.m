//
//  MessageCell.m
//  SealClass
//
//  Created by 张改红 on 2019/3/6.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "MessageCell.h"
#import "Masonry.h"
#import "RolePortraitView.h"
#import "ClassroomService.h"
@interface MessageCell()
@property(nonatomic, strong) RolePortraitView *headerImage;
@property(nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *sendStatusContentView;
@property (nonatomic, strong) UIActivityIndicatorView *sendIndicatorView;
@property (nonatomic, strong) UIButton *sendFailView;
@end
@implementation MessageCell
#pragma mark - Super Api
- (void)loadSubView{
    [super loadSubView];
    [self.baseContainerView addSubview:self.headerImage];
    [self.baseContainerView addSubview:self.nameLabel];
    [self.baseContainerView addSubview:self.messageContentView];
    [self.baseContainerView addSubview:self.sendStatusContentView];
}

- (void)setDataModel:(MessageModel *)model {
    [super setDataModel:model];
    [self setOrUpdateLayout];
    [self setDataInView];
    [self updateSentStatus];
}

#pragma mark - Api
- (void)updateSentStatus {
    switch (self.model.message.sentStatus) {
        case SentStatus_SENDING:
            [self showSendIndicatorView:YES];
            break;
        case SentStatus_FAILED:
            [self showSendIndicatorView:NO];
            [self showSendFailView];
            break;
        case SentStatus_SENT:
            [self showSendIndicatorView:NO];
            [self hidenSendFailView];
            break;
        default:
            break;
    }
    NSLog(@"rcim updateSentStatus %@",@(self.model.message.sentStatus));
}

#pragma mark - Helper
- (void)setDataInView{
    RoomMember *member = [[ClassroomService sharedService].currentRoom getMember:self.model.message.senderUserId];
    
    if(member.name.length > 0){
        self.nameLabel.text = member.name;
    }else{
        if (self.model.message.content.senderUserInfo.name.length > 0) {
            self.nameLabel.text = self.model.message.content.senderUserInfo.name;
        }else{
            self.nameLabel.text = self.model.message.senderUserId;
        }
    }
    if (!member) {
        member = [[RoomMember alloc] init];
    }
    member.name = self.nameLabel.text;
    [self.headerImage addHeaderBackground:member];
}

- (void)showSendIndicatorView:(BOOL)show{
    [self.sendIndicatorView removeFromSuperview];
    [self.sendIndicatorView stopAnimating];
    if (show) {
        [self.sendStatusContentView addSubview:self.sendIndicatorView];
        [self.sendIndicatorView startAnimating];
    }
}

- (void)showSendFailView{
    [self.sendStatusContentView addSubview:self.sendFailView];
}

- (void)hidenSendFailView{
   [self.sendFailView removeFromSuperview];
}

- (void)setOrUpdateLayout{
    if (self.model.message.messageDirection == MessageDirection_RECEIVE) {
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        [self.headerImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.baseContainerView).offset(6);
            make.left.equalTo(self.baseContainerView).offset(10);
            make.height.width.offset(40);
        }];
        
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.headerImage.mas_top).offset(0);
            make.left.equalTo(self.headerImage.mas_right).offset(10);
            make.height.offset(16);
            make.width.offset(200);
        }];

        [self.messageContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(6);
            make.bottom.equalTo(self.baseContainerView.mas_bottom).offset(-6);
            make.left.equalTo(self.headerImage.mas_right).offset(10);
            make.width.offset(self.model.contentSize.width);
        }];
        
        [self.sendStatusContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(6);
            make.bottom.equalTo(self.baseContainerView.mas_bottom).offset(-6);
            make.left.equalTo(self.headerImage.mas_right).offset(10);
            make.width.offset(0);
        }];
    }else{
        [self.headerImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.baseContainerView).offset(6);
            make.right.equalTo(self.baseContainerView).offset(-10);
            make.height.width.offset(40);
        }];
        
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.headerImage.mas_top).offset(0);
            make.right.equalTo(self.headerImage.mas_left).offset(-10);
            make.height.offset(16);
            make.width.offset(200);
        }];
        self.nameLabel.textAlignment = NSTextAlignmentRight;
        
        [self.messageContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(6);
            make.bottom.equalTo(self.baseContainerView.mas_bottom).offset(-6);
            make.right.equalTo(self.headerImage.mas_left).offset(-10);
            make.width.offset(self.model.contentSize.width);
        }];
        
        [self.sendStatusContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.messageContentView);
            make.right.equalTo(self.messageContentView.mas_left).offset(-10);
            make.width.height.offset(25);
        }];
    }
}

#pragma mark - Getters & setters
- (UIView *)messageContentView{
    if (!_messageContentView) {
        _messageContentView = [[UIView alloc] init];
        _messageContentView.backgroundColor = HEXCOLOR(0xffffff);
        _messageContentView.layer.masksToBounds = YES;
        _messageContentView.layer.cornerRadius = 4;
        
    }
    return _messageContentView;
}

- (RolePortraitView *)headerImage{
    if (!_headerImage) {
        _headerImage = [[RolePortraitView alloc] init];
        _headerImage.layer.masksToBounds = YES;
        _headerImage.layer.cornerRadius = 20;
    }
    return _headerImage;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:12];
        _nameLabel.textColor = HEXCOLOR(0x737373);
    }
    return _nameLabel;
}

- (UIView *)sendStatusContentView{
    if (!_sendStatusContentView) {
        _sendStatusContentView = [[UIView alloc] init];
    }
    return _sendStatusContentView;
}

- (UIActivityIndicatorView *)sendIndicatorView{
    if (!_sendIndicatorView) {
        _sendIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _sendIndicatorView.frame = CGRectMake(0, 0, 25, 25);
    }
    return _sendIndicatorView;
}

- (UIButton *)sendFailView{
    if (!_sendFailView) {
        _sendFailView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [_sendFailView setImage:[UIImage imageNamed:@"sendMsg_failed_tip"] forState:UIControlStateNormal];
    }
    return _sendFailView;
}
@end
