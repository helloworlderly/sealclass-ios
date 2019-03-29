//
//  UpgradeDidApplyView.m
//  SealClass
//
//  Created by liyan on 2019/3/11.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "UpgradeDidApplyView.h"
#import "Masonry.h"

#define TLeftOffset 204
#define TViewHeight 44

@interface UpgradeDidApplyView()

@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UIButton *acceptButton;
@property (nonatomic, strong) UIButton *cancelButton;

@end

@implementation UpgradeDidApplyView


- (instancetype)initWithMember:(RoomMember *)member ticket:(NSString *)ticket{
    self = [super initWithFrame:CGRectMake(TLeftOffset, 0, UIScreenWidth - TLeftOffset*2, TViewHeight)];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"FCFCFC" alpha:1];
        self.layer.cornerRadius = 2;
        self.layer.masksToBounds = YES;
        self.member = member;
        self.ticket = ticket;
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews {
    [self addSubview:self.titleLable];
    [self addSubview:self.acceptButton];
    [self addSubview:self.cancelButton];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-15);
        make.top.equalTo(self.mas_top).offset(10);
        make.height.equalTo(@24);
        make.width.equalTo(@24);
    }];
    [self.acceptButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(10);
        make.right.equalTo(self.cancelButton.mas_left).offset(-20);
        make.height.equalTo(@24);
        make.width.equalTo(@24);
    }];
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.acceptButton.mas_left).offset(-20);
        make.top.equalTo(self.mas_top).offset(11);
        make.left.equalTo(self.mas_left).offset(16);
        make.height.equalTo(@22);
    }];
}

- (void)buttonAction:(UIButton *)button {
    if(self.delegate && [self.delegate respondsToSelector:@selector(upgradeDidApplyView:didTapAtTag:)]) {
        [self.delegate upgradeDidApplyView:self didTapAtTag:button.tag];
    }
}

- (UILabel *)titleLable {
    if(!_titleLable) {
        _titleLable = [[UILabel alloc] init];
        _titleLable.font = [UIFont systemFontOfSize:16];
        _titleLable.textAlignment = NSTextAlignmentLeft;
        _titleLable.text = [NSString stringWithFormat:@"%@ %@",self.member.name,NSLocalizedStringFromTable(@"RequestSpeek", @"SealClass", nil)];
        _titleLable.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _titleLable.textColor = [UIColor colorWithHexString:@"303030" alpha:1];
    }
    return _titleLable;
}

- (UIButton *)acceptButton {
    if(!_acceptButton) {
        _acceptButton = [[UIButton alloc] init];
        [_acceptButton setBackgroundImage:[UIImage imageNamed:@"accept"] forState:UIControlStateNormal];
        [_acceptButton setBackgroundImage:[UIImage imageNamed:@"accept_sel"]  forState:UIControlStateSelected];        _acceptButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _acceptButton.tag = UpgradeDidApplyViewAccept;
        [_acceptButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _acceptButton;
}

- (UIButton *)cancelButton {
    if(!_cancelButton) {
        _cancelButton = [[UIButton alloc] init];
        [_cancelButton setBackgroundImage:[UIImage imageNamed:@"refuse"] forState:UIControlStateNormal];
        [_cancelButton setBackgroundImage:[UIImage imageNamed:@"refuse_sel"]  forState:UIControlStateSelected];
        _cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _cancelButton.tag = UpgradeDidApplyViewRefuse;
        [_cancelButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

@end
