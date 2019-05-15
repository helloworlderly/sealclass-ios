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

@class MainContainerView;
@protocol MainContainerViewDelegate <NSObject>
- (void)mainContainerView:(MainContainerView *_Nullable)view scale:(CGFloat)scale;
- (void)mainContainerView:(MainContainerView *_Nullable)view fullScreen:(BOOL)isFull;
@end

NS_ASSUME_NONNULL_BEGIN

@interface MainContainerView : UIView

@property (nonatomic, strong) UIView *videoView;

@property (nonatomic, strong) EmptyView *emptyView;

@property (nonatomic, strong) RoomMember *member;

@property (nonatomic, weak) id<MainContainerViewDelegate> delegate;

@property (nonatomic, assign, readonly) BOOL isFullScreen;

@property (nonatomic, readonly) CGRect currentVideoFrame;

- (void)didChangeRole:(Role)role;

- (void)containerViewRenderView:(RoomMember *)member;

- (void)cancelRenderView;

@end

NS_ASSUME_NONNULL_END
