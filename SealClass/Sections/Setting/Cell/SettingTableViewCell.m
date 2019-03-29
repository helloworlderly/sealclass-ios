//
//  SettingTableViewCell.m
//  SealClass
//
//  Created by 张改红 on 2019/3/4.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "SettingTableViewCell.h"
#import "Masonry.h"
@implementation SettingTableViewCell
+(SettingTableViewCell *)configCell:(UITableView *)tableView{
    SettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingTableViewCell"];
    if (!cell) {
        cell = [[SettingTableViewCell alloc] initWithStyle:(UITableViewCellStyleValue1) reuseIdentifier:@"SettingTableViewCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews{
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.arrowImageView];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(14);
        make.top.equalTo(self.contentView);
        make.height.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(100);
    }];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-14);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.height.offset(22);
        make.width.offset(22);
    }];
}

#pragma mark - Getters and setters
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:17];
    }
    return _titleLabel;
}

- (UIImageView *)arrowImageView{
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_arrow"]];
        _arrowImageView.hidden = YES;
    }
    return _arrowImageView;
}
@end
