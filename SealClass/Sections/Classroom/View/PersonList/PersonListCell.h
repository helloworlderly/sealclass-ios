//
//  PersonListCell.h
//  SealClass
//
//  Created by liyan on 2019/3/5.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomMember.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    PersonListCellActionTagAssistantTransfer,//转让助教
    PersonListCellActionTagSetSpeaker,//设置讲师
    PersonListCellActionTagSetVoice,//设置麦克风
    PersonListCellActionTagSetCamera,//设置摄像头
    PersonListCellActionTagDownGrade,//降级
    PersonListCellActionTagDeletelPerson,//删除人
} PersonListCellActionTag;

@class PersonListCell;
@protocol PersonListCellDelegate <NSObject>

- (void)PersonListCell:(PersonListCell *)cell didTapButton:(UIButton *)button;

@end

@interface PersonListCell : UITableViewCell

@property (nonatomic, weak) id<PersonListCellDelegate> delegate;

@property (nonatomic, strong) RoomMember *member;

@property (nonatomic, strong) NSMutableArray *buttonArray;

- (void)setModel:(RoomMember *)member;

@end

NS_ASSUME_NONNULL_END
