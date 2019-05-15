//
//  RecentSharedWhiteboardCell.m
//  SealClass
//
//  Created by liyan on 2019/3/6.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "RecentSharedWhiteboardCell.h"
#import "Masonry.h"

@interface RecentSharedWhiteboardCell()

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *nameLable;

@end

@implementation RecentSharedWhiteboardCell

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
    [self.contentView addSubview:self.backView];
    [self.backView addSubview:self.nameLable];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(30);
        make.left.equalTo(self.contentView.mas_left).offset(30);
        make.right.equalTo(self.contentView.mas_right).offset(-30);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(0);
    }];
    [self.nameLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backView.mas_top).offset(0);
        make.left.equalTo(self.backView.mas_left).offset(0);
        make.right.equalTo(self.backView.mas_right).offset(0);
        make.bottom.equalTo(self.backView.mas_bottom).offset(0);
    }];
}

- (void)setModel:(Whiteboard *)whiteboard {
    if (!whiteboard) {
        return;
    }
    self.nameLable.text = whiteboard.name;
}

- (void)resetDefaultStyle {
    self.nameLable.text = nil;
}

- (UIView *)backView {
    if(!_backView) {
        _backView = [[UIView alloc] init];
    }
    return _backView;
}

- (UILabel *)nameLable {
    if(!_nameLable) {
        _nameLable = [[UILabel alloc] init];
        _nameLable.backgroundColor = [UIColor colorWithHexString:@"ffffff" alpha:1];
        _nameLable.font = [UIFont systemFontOfSize:12];
        _nameLable.textAlignment = NSTextAlignmentCenter;
        _nameLable.textColor = [UIColor colorWithHexString:@"000000" alpha:1];
    }
    return _nameLable;
}
@end
