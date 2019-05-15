//
//  MainContainerView.m
//  SealClass
//
//  Created by Sin on 2019/2/28.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "MainContainerView.h"
#import "RTCService.h"
#import <Masonry.h>
#import "ZoomControl.h"
@interface MainContainerView()<ZoomControlDelegate>
@property (nonatomic, strong) UIView *tapGestureView;
@property (nonatomic, strong) ZoomControl *zoomControl;
@property (nonatomic) CGRect currentVideoFrame;
@property (nonatomic) CGRect originVideoFrame;
@end

@implementation MainContainerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"28313A" alpha:1];
        [self addSubview:self.emptyView];
        [self addSubview:self.videoView];
        [self.videoView addSubview:self.zoomControl];
        [self.videoView bringSubviewToFront:self.zoomControl];
        [self addConstraints];
        self.originVideoFrame = self.videoView.frame;
        self.currentVideoFrame = self.originVideoFrame;
    }
    return self;
}

#pragma mark - ZoomControlDelegate
- (void)zoomControlDelegate:(CGFloat)scale{
    if([self.delegate respondsToSelector:@selector(mainContainerView: scale:)]) {
        [self.delegate mainContainerView:self scale:scale];
    }
}

- (void)fullScreenDidUpdate:(BOOL)isFull{
    [self updateVideoViewFrame:isFull];
    if([self.delegate respondsToSelector:@selector(mainContainerView:fullScreen:)]) {
        [self.delegate mainContainerView:self fullScreen:isFull];
    }
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
    [self.videoView bringSubviewToFront:self.zoomControl];
    self.zoomControl.hidden = NO;
    [self.zoomControl resetDefaultScale];
}

- (void)cancelRenderView {
    for(UIView *v in self.videoView.subviews) {
        if([v isEqual:self.zoomControl]) {
            v.hidden = YES;
        }else {
            [v removeFromSuperview];
        }
    }
}

#pragma mark - private method

- (void)updateVideoViewFrame:(BOOL)isFull {
    self.currentVideoFrame = self.frame;
    if(isFull) {
        [self.superview addSubview:self.videoView];
        [self.superview bringSubviewToFront:self.videoView];
        
    }else {
        [self.videoView removeFromSuperview];
        [self addSubview:self.videoView];
        self.currentVideoFrame = self.originVideoFrame;
    }
    self.videoView.frame = self.currentVideoFrame;
}

#pragma mark - getter
- (UIView *)videoView {
    if(!_videoView) {
        CGFloat width = 750/2;
        CGFloat height = 563/2;
        CGFloat x = (self.frame.size.width - 49 - 112 - width) /2.0 + 30;
        CGFloat y = 64+10;
        _videoView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    }
    return _videoView;
}

- (ZoomControl *)zoomControl{
    if (!_zoomControl) {
        _zoomControl = [[ZoomControl alloc] init];
        _zoomControl.delegate = self;
        _zoomControl.hidden = YES;
    }
    return _zoomControl;
}

- (EmptyView *)emptyView {
    if (!_emptyView) {
        CGFloat width = 750/2;
        CGFloat height = 563/2;
        CGFloat x = (self.frame.size.width - 49 - 112 - width) /2.0 + 30;
        CGFloat y = 64+10;
        _emptyView = [[EmptyView alloc] initWithFrame:CGRectMake(x, y, width, height) role:[ClassroomService sharedService].currentRoom.currentMember.role];
    }
    return _emptyView;
}

- (void)addConstraints {
    [self.zoomControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.videoView).mas_offset(0);
        make.right.mas_equalTo(self.videoView).mas_offset(0);
        make.width.height.mas_equalTo(100);
    }];
}
@end
