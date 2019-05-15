//
//  RTCService.h
//  SealClass
//
//  Created by LiFei on 2019/2/27.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongRTCLib/RongRTCLib.h>

NS_ASSUME_NONNULL_BEGIN
//1.连接 im，加入 rtc room
//2.显示自己的视频：先发布后渲染
//3.显示别人的视频：先订阅后渲染

@interface RTCService : NSObject

+ (instancetype)sharedInstance;

/**
 当前加入的 rtc 房间
 @dicussion 当加入房间成功之后，才会是有效值
 */
@property (nonatomic, strong, readonly) RongRTCRoom *rtcRoom;

/**
 视频录制参数，如分辨率，前后摄像头等
 @dicussion 如需自定义设置录制参数，请在渲染当前用户视频前设置
 */
@property (nonatomic, strong) RongRTCVideoCaptureParam * captureParam;

/**
 设置 rtc 房间代理

 @param delegate 代理
 @dicussion 当 rtcRoom 字段为有效值后，才可以正常设置
 */
- (void)setRTCRoomDelegate:(id<RongRTCRoomDelegate>)delegate;

/**
 加入 rtc 房间

 @param roomId 房间 id
 @param success 成功
 @param error 失败
 */
- (void)joinRongRTCRoom:(NSString *)roomId success:(void (^)( RongRTCRoom *room))success error:(void (^)(RongRTCCode code))error;

/**
 退出 rtc 房间

 @param roomId 房间 id
 @param success 成功
 @param error 失败
 */
- (void)leaveRongRTCRoom:(NSString*)roomId success:(void (^)(void))success error:(void (^)(RongRTCCode code))error;

#pragma mark - 发布/订阅音视频流
#pragma mark 针对当前用户
/**
 发布当前用的音视频流
 */
- (void)publishLocalUserDefaultAVStream;

/**
 取消发布当前用户的音视频流
 */
- (void)unpublishLocalUserDefaultAVStream;

/**
 将当前用户的视频渲染到指定 view 上

 @param view view
 @param enable 是否开启摄像头
 */
- (void)renderLocalVideoOnView:(UIView *)view cameraEnable:(BOOL)enable;

/**
 将除当前用户外其他用户的视频渲染到指定 view 上

 @param view view
 @param userId 其他用户 id
 */
- (void)renderRemoteVideoOnView:(UIView *)view forUser:(NSString *)userId;

/**
 将某个用户的屏幕共享渲染到指定 view 上

 @param view view
 @param userId 用户 id
 */
- (void)renderUserSharedScreenOnView:(UIView *)view forUser:(NSString *)userId;

/**
 取消 view 上的视频渲染

 @param view 需要被取消渲染的 view
 @return 取消渲染是否成功
 */
- (BOOL)cancelRenderVideoInView:(UIView *)view;

/**
 按照一定比例将视频裁剪
 
 @param view 视频所在的父 view
 @param scale 缩放比例
 */
- (void)clipVideoInView:(UIView *)view scale:(CGFloat)scale;

#pragma mark 针对远端用户
/**
 订阅远端用户的音视频流

 @param remoteUser 远端用户
 */
- (void)subscribeRemoteUserAVStream:(RongRTCRemoteUser *)remoteUser;

/**
 取消订阅远端用户的音视频流

 @param remoteUser 远端用户
 */
- (void)unsubscribeRemoteUserAVStream:(RongRTCRemoteUser *)remoteUser;

#pragma mark - 顶部工具栏接口
/**
 关闭/打开麦克风
 
 @param disable YES 关闭，NO 打开
 */
- (void)setMicrophoneDisable:(BOOL)disable;

/**
 采集运行中关闭或打开摄像头
 
 @param disable YES 关闭，否则打开
 */
- (void)setCameraDisable:(BOOL)disable;

/**
 切换前后摄像头
 */
- (void)switchCamera;

/**
 切换使用外放/听筒
 */
- (void)useSpeaker:(BOOL)useSpeaker;

/**
 关闭音视频流
 */
- (void)stopCapture;

- (UIImage *)imageForCurrentUser;

/**
 获取除当前用户之外其他人的视频截图

 @param userId 用户 id
 @return 截图
 */
- (UIImage *)imageForOtherUser:(NSString *)userId;

- (void)refreshCurrentImage;
@end

NS_ASSUME_NONNULL_END
