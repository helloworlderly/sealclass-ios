//
//  MainContainerView.m
//  SealClass
//
//  Created by Sin on 2019/2/28.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "MainContainerView.h"
#import "RTCService.h"

@interface MainContainerView()
@property (nonatomic, strong) UIView *tapGestureView;
@end

@implementation MainContainerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"28313A" alpha:1];
        [self addSubview:self.emptyView];
        [self addSubview:self.videoView];
    }
    return self;
}

- (UIView *)videoView {
    if(!_videoView) {
        CGFloat width = 750/2;
        CGFloat height = 563/2;
        CGFloat x = (self.frame.size.width - width-133) /2.0;
        CGFloat y = (self.frame.size.height - height) / 2.0;
        _videoView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    }
    return _videoView;
}

- (EmptyView *)emptyView {
    if (!_emptyView) {
        CGFloat width = 750/2;
        CGFloat height = 563/2;
        CGFloat x = (self.frame.size.width - width-133) /2.0;
        CGFloat y = (self.frame.size.height - height) / 2.0;
        _emptyView = [[EmptyView alloc] initWithFrame:CGRectMake(x, y, width, height) role:[ClassroomService sharedService].currentRoom.currentMember.role];
    }
    return _emptyView;
}

- (void)didChangeRole:(Role)role {
    [self.emptyView changeRole:role];
}
- (void)containerViewRenderView:(RoomMember *)member {
    self.videoView.hidden = NO;
    if([[ClassroomService sharedService].currentRoom.currentMemberId isEqualToString:member.userId]) {
        RoomMember *curMemeber =[ClassroomService sharedService].currentRoom.currentMember;
        [[RTCService sharedInstance] renderLocalVideoOnView:self.videoView cameraEnable:curMemeber.cameraEnable];
    }else {
        [[RTCService sharedInstance] renderRemoteVideoOnView:self.videoView forUser:member.userId];
    }
    self.member = member;

}

- (void)cancelRenderView {
    for(UIView *v in self.videoView.subviews) {
        [v removeFromSuperview];
    }
}

- (void)moveVideoViewTo:(CGFloat)offset {
    CGFloat width = 750/2;
    CGFloat height = 563/2;
    CGFloat x = (self.frame.size.width - width-133) /2.0+offset;
    CGFloat y = (self.frame.size.height - height) / 2.0;
    self.videoView.frame = CGRectMake(x, y, width, height);
    self.emptyView.frame = CGRectMake(x, y, width, height);
}

@end
