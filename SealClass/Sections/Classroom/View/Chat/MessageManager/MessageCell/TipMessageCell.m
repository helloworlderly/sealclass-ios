//
//  RoleUpdateMessageCell.m
//  SealClass
//
//  Created by 张改红 on 2019/3/13.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "TipMessageCell.h"
#import "MessageHelper.h"
@interface TipMessageCell ()
@property (nonatomic, strong) UILabel *infoLabel;
@end
@implementation TipMessageCell
#pragma mark - Super Api
-(void)loadSubView{
    [super loadSubView];
    [self.baseContainerView addSubview:self.infoLabel];
}

- (void)setModel:(MessageModel *)model{
    [super setModel:model];
    [self setDataInView];
    [self.infoLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.baseContainerView).offset(6);
        make.width.offset(model.contentSize.width);
        make.height.offset(model.contentSize.height);
        make.centerX.equalTo(self.baseContainerView);
    }];
}

#pragma mark - helper
- (void)setDataInView{
    self.infoLabel.text = [[MessageHelper sharedInstance] formatMessage:self.model.message.content];
}
#pragma mark - Getters and setters
- (UILabel *)infoLabel{
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.font = [UIFont systemFontOfSize:InfoTextFont];
        _infoLabel.textColor = [UIColor whiteColor];
        _infoLabel.numberOfLines = 0;
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.layer.masksToBounds = YES;
        _infoLabel.layer.cornerRadius = 4.f;
        _infoLabel.backgroundColor = HEXCOLOR(0xc9c9c9);
    }
    return _infoLabel;
}
@end
