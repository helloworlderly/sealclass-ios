//
//  RecentSharedVideoCell.m
//  SealClass
//
//  Created by liyan on 2019/3/13.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "RecentSharedVideoCell.h"
#import "Masonry.h"
#import "RTCService.h"
#import "ClassroomService.h"

@interface RecentSharedVideoCell()

@property (nonatomic, strong) UIImageView *thumnailImageView;

@end

@implementation RecentSharedVideoCell

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
    [self.contentView addSubview:self.thumnailImageView];
    [self.thumnailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(30);
        make.left.equalTo(self.contentView.mas_left).offset(30);
        make.right.equalTo(self.contentView.mas_right).offset(-30);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(0);
    }];
}

- (void)setModel:(RoomMember *)member {
    self.thumnailImageView.image = nil;
    UIImage *image = nil;
    if([[ClassroomService sharedService].currentRoom.currentMemberId isEqualToString:member.userId]) {
        image = [[RTCService sharedInstance] imageForCurrentUser];
    }else {
        image = [[RTCService sharedInstance] imageForOtherUser:member.userId];
    }
    if (image != nil) {
        self.thumnailImageView.image = image;
    }
}

- (UIImageView *)thumnailImageView {
    if(!_thumnailImageView) {
        _thumnailImageView = [[UIImageView alloc] init];
        _thumnailImageView.backgroundColor = [UIColor colorWithHexString:@"3D4041" alpha:1];
    }
    return _thumnailImageView;
}

@end
