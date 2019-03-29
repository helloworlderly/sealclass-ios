//
//  NormalAlertView.m
//  SealClass
//
//  Created by liyan on 2019/3/12.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "NormalAlertView.h"
#import "Masonry.h"

typedef enum : NSUInteger {
    ClassRoomAlertViewCancel,
    ClassRoomAlertViewConfirm,
} ClassRoomAlertViewActionTag;

#define AWidth 320
#define AHeight 134

@interface NormalAlertView()

@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *downgradeButton;
@property (nonatomic, strong) UIView *horizontalLine;
@property (nonatomic, strong) UIView *verticalLine;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *leftTitle;
@property (nonatomic, strong) NSString *rightTitle;
@property (nonatomic, copy) ButtonBlock cancel;
@property (nonatomic, copy) ButtonBlock confirm;

@end

@implementation NormalAlertView

+ (void)showAlertWithTitle:(NSString *)title  confirmTitle:(NSString *)confirmTitle  confirm:(ButtonBlock)confirm{
    NormalAlertView * alertView = [[NormalAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    alertView.backgroundColor = [HEXCOLOR(0x000000) colorWithAlphaComponent:0.5];
    alertView.title = title;
    alertView.rightTitle = confirmTitle;
    alertView.confirm = confirm;
    [alertView addCancelSubview];
    [alertView showAlertView];
}

+ (void)showAlertWithTitle:(NSString *)title  leftTitle:(NSString *)leftTitle rightTitle:(NSString *)rightTitle  cancel:(ButtonBlock)cancel confirm:(ButtonBlock)confirm {
    NormalAlertView * alertView = [[NormalAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    alertView.backgroundColor = [HEXCOLOR(0x000000) colorWithAlphaComponent:0.5];
    alertView.title = title;
    alertView.leftTitle = leftTitle;
    alertView.rightTitle = rightTitle;
    alertView.cancel = cancel;
    alertView.confirm =confirm;
    [alertView addSubviews];
    [alertView showAlertView];
}
- (void)showAlertView {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

-(void)dismissAlertView{
    [self removeFromSuperview];
}

- (void)addCancelSubview {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake((UIScreenWidth - AWidth) / 2, (UIScreenHeight - AHeight) / 2, AWidth, AHeight)];
    contentView.backgroundColor = [UIColor colorWithHexString:@"FFFFFF" alpha:1];
    contentView.layer.cornerRadius = 8;
    contentView.layer.masksToBounds = YES;
    [self addSubview:contentView];
    [contentView addSubview:self.titleLable];
    [contentView addSubview:self.cancelButton];
    CGSize size = contentView.bounds.size;
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView.mas_top).offset(20);
        make.left.equalTo(contentView.mas_left).offset(13);
        make.right.equalTo(contentView.mas_right).offset(-13);
        make.bottom.equalTo(contentView.mas_bottom).offset(-54);
    }];
    [self.downgradeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cancelButton.mas_right).offset(0);
        make.bottom.equalTo(contentView.mas_bottom).offset(0);
        make.height.equalTo(@43);
        make.width.equalTo(@(size.width));
    }];
}

- (void)addSubviews {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake((UIScreenWidth - AWidth) / 2, (UIScreenHeight - AHeight) / 2, AWidth, AHeight)];
    contentView.backgroundColor = [UIColor colorWithHexString:@"FFFFFF" alpha:1];
    contentView.layer.cornerRadius = 8;
    contentView.layer.masksToBounds = YES;
    [self addSubview:contentView];
    [contentView addSubview:self.titleLable];
    [contentView addSubview:self.cancelButton];
    [contentView addSubview:self.downgradeButton];
    [contentView addSubview:self.horizontalLine];
    [contentView addSubview:self.verticalLine];
    CGSize size = contentView.bounds.size;
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView.mas_top).offset(20);
        make.left.equalTo(contentView.mas_left).offset(13);
        make.right.equalTo(contentView.mas_right).offset(-13);
        make.bottom.equalTo(contentView.mas_bottom).offset(-54);
    }];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView.mas_left).offset(0);
        make.bottom.equalTo(contentView.mas_bottom).offset(0);
        make.height.equalTo(@43);
        make.width.equalTo(@(size.width / 2));
    }];
    [self.downgradeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cancelButton.mas_right).offset(0);
        make.bottom.equalTo(contentView.mas_bottom).offset(0);
        make.height.equalTo(@43);
        make.width.equalTo(@(size.width / 2));
    }];
    [self.horizontalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView.mas_left).offset(0);
        make.right.equalTo(contentView.mas_right).offset(0);
        make.bottom.equalTo(self.cancelButton.mas_top).offset(0);
        make.height.equalTo(@0.5);
    }];
    [self.verticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cancelButton.mas_right).offset(0);
        make.bottom.equalTo(contentView.mas_bottom).offset(0);
        make.width.equalTo(@0.5);
        make.height.equalTo(@43);
    }];
    
}

- (void)buttonAction:(UIButton *)button {
    if (button.tag == ClassRoomAlertViewCancel) {
        self.cancel();
    }else {
        self.confirm();
    }
    [self dismissAlertView];
}

- (UILabel *)titleLable {
    if(!_titleLable) {
        _titleLable = [[UILabel alloc] init];
        _titleLable.font = [UIFont systemFontOfSize:18];
        _titleLable.textAlignment = NSTextAlignmentCenter;
        _titleLable.text = self.title;
        _titleLable.numberOfLines = 0;
        _titleLable.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _titleLable.textColor = [UIColor colorWithHexString:@"262626" alpha:1];
    }
    return _titleLable;
}

- (UIButton *)cancelButton {
    if(!_cancelButton) {
        _cancelButton = [[UIButton alloc] init];
        _cancelButton.backgroundColor =  [UIColor clearColor];
        [_cancelButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [_cancelButton setTitleColor:[UIColor colorWithHexString:@"262626" alpha:1] forState:UIControlStateNormal];
        [_cancelButton setTitle:self.leftTitle forState:UIControlStateNormal];
        _cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _cancelButton.tag = ClassRoomAlertViewCancel;
        [_cancelButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _cancelButton;
}

- (UIButton *)downgradeButton {
    if(!_downgradeButton) {
        _downgradeButton = [[UIButton alloc] init];
        _downgradeButton.backgroundColor =  [UIColor clearColor];
        [_downgradeButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [_downgradeButton setTitleColor:[UIColor colorWithHexString:@"21C194" alpha:1] forState:UIControlStateNormal];
        [_downgradeButton setTitle:self.rightTitle forState:UIControlStateNormal];
        _downgradeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _downgradeButton.tag = ClassRoomAlertViewConfirm;
        [_downgradeButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downgradeButton;
}

- (UIView *)horizontalLine {
    if (!_horizontalLine) {
        _horizontalLine = [[UIView alloc] init];
        _horizontalLine.backgroundColor = [UIColor colorWithHexString:@"E5E5E5" alpha:1];
    }
    return _horizontalLine;
}

- (UIView *)verticalLine {
    if (!_verticalLine) {
        _verticalLine = [[UIView alloc] init];
        _verticalLine.backgroundColor = [UIColor colorWithHexString:@"E5E5E5" alpha:1];
    }
    return _verticalLine;
}
@end
