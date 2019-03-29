//
//  TimeStampCell.m
//  SealClass
//
//  Created by 张改红 on 2019/3/6.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "TimeStampCell.h"
#import "TimeStampMessage.h"
@interface TimeStampCell ()
@property (nonatomic, strong) UILabel *infoLabel;

@end
@implementation TimeStampCell
#pragma mark - Super Api
-(void)loadSubView{
    [super loadSubView];
    [self.baseContainerView addSubview:self.infoLabel];
}

- (void)setModel:(MessageModel *)model{
    [super setModel:model];
    [self setDataInView];
    [self.infoLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.baseContainerView).offset(10);
        make.width.offset(model.contentSize.width);
        make.height.offset(model.contentSize.height);
        make.centerX.equalTo(self.baseContainerView);
    }];
}

#pragma mark - helper
- (void)setDataInView{
    TimeStampMessage *timeMsg = (TimeStampMessage *)(self.model.message.content);
    self.infoLabel.text = timeMsg.timeText;
}
#pragma mark - Getters and setters
- (UILabel *)infoLabel{
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.font = [UIFont systemFontOfSize:TimeTextFont];
        _infoLabel.textColor = [UIColor whiteColor];
        _infoLabel.numberOfLines = 0;
        _infoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.layer.masksToBounds = YES;
        _infoLabel.layer.cornerRadius = 4.f;
        _infoLabel.backgroundColor = HEXCOLOR(0xc9c9c9);
    }
    return _infoLabel;
}
@end
