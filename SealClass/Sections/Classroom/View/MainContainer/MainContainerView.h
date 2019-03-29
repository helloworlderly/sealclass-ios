//
//  MainContainerView.h
//  SealClass
//
//  Created by Sin on 2019/2/28.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClassroomService.h"
#import "EmptyView.h"
#import "RoomMember.h"

NS_ASSUME_NONNULL_BEGIN

@interface MainContainerView : UIView

@property (nonatomic, strong) UIView *videoView;

@property (nonatomic, strong) EmptyView *emptyView;

@property (nonatomic, strong) RoomMember *member;

//水平方向移动视频 view ，正数向右移动，负数向左移动
- (void)moveVideoViewTo:(CGFloat)offset;

- (void)didChangeRole:(Role)role;

- (void)containerViewRenderView:(RoomMember *)member;

- (void)cancelRenderView;

@end

NS_ASSUME_NONNULL_END
