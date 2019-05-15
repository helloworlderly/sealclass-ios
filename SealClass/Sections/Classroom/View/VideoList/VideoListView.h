//
//  VideoListView.h
//  SealClass
//
//  Created by liyan on 2019/3/5.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VideoListView,RoomMember;
@protocol VideoListViewDelegate <NSObject>

- (void)videoListView:(VideoListView *_Nullable)view didTap:(RoomMember *_Nullable)member;

@end

NS_ASSUME_NONNULL_BEGIN

@interface VideoListView : UIView

@property (nonatomic, assign) BOOL showAssistantPrompt;

@property (nonatomic, assign) BOOL showTeacherPrompt;

@property (nonatomic, weak) id<VideoListViewDelegate> delegate;


- (void)updateUserVideo:(NSString *)userId;

- (void)reloadVideoList;

- (void)showAssistantPrompt:(BOOL)showAssistantPrompt showTeacherPrompt:(BOOL)showTeacherPrompt;

@end

NS_ASSUME_NONNULL_END
