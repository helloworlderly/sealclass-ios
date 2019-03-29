//
//  EmptyView.m
//  SealClass
//
//  Created by Zhaoqianyu on 2019/3/13.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "EmptyView.h"
#import <Masonry/Masonry.h>

#define ImageWidth 111
#define ImageHeight 82

@interface EmptyView()

@property(nonatomic, assign) Role currentRole;
@property(nonatomic, strong) UIImageView *emptyImageView;
@property(nonatomic, strong) UILabel *emptyLabel;

@end

@implementation EmptyView

- (instancetype)initWithFrame:(CGRect)frame role:(Role)role; {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.emptyImageView];
        [self addSubview:self.emptyLabel];
        [self.emptyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        [self.emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self).mas_offset((self.bounds.size.height-ImageHeight)/2+ImageHeight-10);
            make.centerX.mas_equalTo(self);
            make.height.mas_equalTo(9);
        }];
        [self changeRole:role];
    }
    return self;
}

- (void)changeRole:(Role)role {
    self.currentRole = role;
    switch (role) {
        case RoleAssistant:
        case RoleTeacher:
            self.emptyImageView.image = [UIImage imageNamed:@"empty_teacher"];
            self.emptyLabel.text = @"当前无共享内容，您可以新建共享内容";
            break;
        default:
            self.emptyImageView.image = [UIImage imageNamed:@"empty_student"];
            self.emptyLabel.text = @"当前无共享内容，请耐心等待";
            break;
    }
}

#pragma mark - Getters & setters

- (UIImageView *)emptyImageView {
    if (!_emptyImageView) {
        _emptyImageView = [UIImageView new];
        _emptyImageView.contentMode = UIViewContentModeCenter;
        self.backgroundColor = HEXCOLOR(0xffffff);
    }
    return _emptyImageView;
}

- (UILabel *)emptyLabel {
    if (!_emptyLabel) {
        _emptyLabel = [UILabel new];
        _emptyLabel.textColor = HEXCOLOR(0xb2b2b2);
        _emptyLabel.font = [UIFont systemFontOfSize:6];
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _emptyLabel;
}

@end
