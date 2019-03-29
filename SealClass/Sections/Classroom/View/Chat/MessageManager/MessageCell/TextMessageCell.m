//
//  TextMessageCell.m
//  SealClass
//
//  Created by 张改红 on 2019/3/6.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "TextMessageCell.h"
#import "Masonry.h"
@implementation TextMessageCell
- (void)loadSubView{
    [super loadSubView];
    [self.messageContentView addSubview:self.contentLabel];
}

- (void)setDataModel:(MessageModel *)model{
    [super setDataModel:model];
    RCTextMessage *message = (RCTextMessage *)(model.message.content);
    self.contentLabel.text = message.content;
    [self.contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.messageContentView).offset(8);
        make.bottom.equalTo(self.messageContentView).offset(-8);
        make.right.equalTo(self.messageContentView).offset(-8);
        make.left.equalTo(self.messageContentView).offset(8);
    }];
}

- (UILabel *)contentLabel{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:Text_Message_Font_Size];
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}
@end
