//
//  VideoListCell.h
//  SealClass
//
//  Created by liyan on 2019/3/5.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomMember.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoListCell : UITableViewCell

@property (nonatomic, strong) UIView *videoView;

@property (nonatomic, strong) UILabel *WaitLable;

- (void)setModel:(RoomMember *)member showAssistantPrompt:(BOOL)assistentPrompt showTeacherPrompt:(BOOL)teacherPrompt;

- (void)renderVideo:(RoomMember *)member;

- (void)cancelVideo;

@end

NS_ASSUME_NONNULL_END
