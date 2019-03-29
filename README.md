# iOS SealClass 源码导读
本文档介绍了 SealClass 的 Demo 整体框架设计，以及核心流程，为开发者了解 Demo 的主要功能提供指导性说明。SealClass Demo 的 [体验和简介地址](https://www.rongcloud.cn/solution/edu#industry-points)。APPKey 的需要您到官网注册获取。同时需要您开通音视频服务。

## 代码目录介绍
iOS 端整体目录结构主要由 Sections，Services，Util，Resources 四个部分组成。

![](./images/Image1.png)

* Section 由四部分组成，每个部分都包含了整个功能的全部实现。WhiteBoard 白板功能，Setting 设置功能， Classroom 课堂功能，Login 登录功能。

* Services 由三部分组成，IM 管理类，Classroom 管理类， RTC 管理类。

* Util 通用的一些工具类。

* Resources 包含了国际化文件，图片资源，以及 Emoji 表情。

## 主体业务介绍
SealClass 的主体业务主要在 Sections 文件夹里。分为白板（WhiteBoard），设置（Setting），课堂（Classroom）, 登录（Login）。每个模块按照具体的功能再次进一步划分。

### 登录
---
登录模块的 UI 在 `LoginViewController.m` 文件里。相关的业务逻辑实现在 `LoginHelper.m` 文件里。 SealClass 依赖于 IMService，RTCService，ClassroomService。首先要调用 ClassroomService 登录课堂，成功之后调用 IMService 连接 IM 。IM 连接成功之后调用 RTCService 加入房间。  

* 登录成功的回调

```
- (void)classroomDidJoin:(Classroom *)classroom;

```

* 登录失败的回调

```
- (void)classroomDidJoinFail;

```
### 设置
---
设置模块分为两个页面，一个是展示用户选择的分辨率页面 `SettingViewController.m` ，另一个是选择分辨率的页面 `SelectResolutionController.m` 。
### 课堂
---
课堂区域主要分为标题栏（Title），通话操作栏（Title），侧边导航栏（ToolPanel），最近共享列表（RecentShared），共享画布区域（MainContainer），消息区（Chat），视频区（VideoList），在线成员列表（PersonList）八个部分。

![](./images/Image2.png)

**标题栏，通话操作栏**     
对应于 Title 文件夹下的 `ClassroomTitleView`文件 。包含了以下内容：加入课堂的时间计时，课堂ID，摄像头切换，麦克风开关，摄像头开关，静音开关，以及退出课堂功能。相关事件回调在 `ClassroomViewController.m` 文件的`- (void)classroomTitleView:(UIButton *)button didTapAtTag:(ClassroomTitleViewActionTag)tag` 代理里。

**侧边导航栏**     
对应于 ToolPanel 文件夹下的 `ToolPanelView` 文件。包含了新建白板，最近共享，人员列表，视频列表，消息区展示。
相关事件回调在 `ClassroomViewController.m` 文件的 `- (void)toolPanelView:(UIButton *)button didTapAtTag:(ToolPanelViewActionTag)tag;` 代理里。


**最近共享列表**   
对应于 RecentSharedView 文件夹下的 `RecentSharedView` 文件。展示的是助教和讲师的视频和白版。只有助教和讲师可以看到和操作最近共享列表。

**共享画布区域**  
对应于 MainContainer 文件夹下的 `MainContainerView`文件。展示了共享的视频或白板

**消息区**   
对应于 Chat 文件夹下的 `ChatAreaView`文件。可以在消息区发送和接受课堂中的消息。

**视频区**
对应于 VideoListView 文件夹下的 `VideoListView`文件。展示了课堂中除了旁听人以外的人的视频。

**在线成员列表**   
对应于 PersonList 文件夹下的 `PersonListView`文件。助教可以对课堂里边的成成员进行角色以及设备等的控制。

### 白板
---
白板模块 `WhiteboardControl`文件里。助教或者讲师点击了共享白板或者新建白板，共享画布区会显示此白板。

## Service 部分介绍
Service 部分由 （音视频）RTCService，（IM）IMService，（课堂）ClaassroomService 三个部分组成。
### RTCService 说明
---
对应于`RTCService` 文件。通过单例模式实现。

* 加入房间

```
/**
 加入 rtc 房间

 @param roomId 房间 id
 @param success 成功
 @param error 失败
 */
- (void)joinRongRTCRoom:(NSString *)roomId success:(void (^)( RongRTCRoom *room))success error:(void (^)(RongRTCCode code))error;
-
```

* 退出房间

```
/**
 退出 rtc 房间

 @param roomId 房间 id
 @param success 成功
 @param error 失败
 */
- (void)leaveRongRTCRoom:(NSString*)roomId success:(void (^)(void))success error:(void (^)(RongRTCCode code))error;

```

* 发布当前用户的音视频流

```
/**
 发布当前用户的音视频流
 */
- (void)publishLocalUserDefaultAVStream;

```

* 取消发布当前用户的音视频流

```
/**
 取消发布当前用户的音视频流
 */
- (void)unpublishLocalUserDefaultAVStream;

```

* 将当前用户的视频渲染到指定 view 上

```
/**
 将当前用户的视频渲染到指定 view 上

 @param view view
 @param enable 是否开启摄像头
 */
- (void)renderLocalVideoOnView:(UIView *)view cameraEnable:(BOOL)enable;

```

* 将除当前用户外其他用户的视频渲染到指定 view 上

```
/**
 将除当前用户外其他用户的视频渲染到指定 view 上

 @param view view
 @param userId 其他用户 id
 */
- (void)renderRemoteVideoOnView:(UIView *)view forUser:(NSString *)userId;

```

*  将某个用户的屏幕共享渲染到指定 view 上

```
/**
 将某个用户的屏幕共享渲染到指定 view 上

 @param view view
 @param userId 用户 id
 */
- (void)renderUserSharedScreenOnView:(UIView *)view forUser:(NSString *)userId;

```

*  取消 view 上的视频渲染

```
/**
 取消 view 上的视频渲染

 @param view 需要被取消渲染的 view
 @return 取消渲染是否成功
 */
- (BOOL)cancelRenderVideoInView:(UIView *)view;

```

*  订阅远端用户的音视频流

```
/**
 订阅远端用户的音视频流

 @param remoteUser 远端用户
 */
- (void)subscribeRemoteUserAVStream:(RongRTCRemoteUser *)remoteUser;

```

* 取消订阅远端用户的音视频流

```
/**
 取消订阅远端用户的音视频流

 @param remoteUser 远端用户
 */
- (void)unsubscribeRemoteUserAVStream:(RongRTCRemoteUser *)remoteUser;

```

*   关闭/打开麦克风

```
/**
 关闭/打开麦克风

 @param disable YES 关闭，NO 打开
 */
- (void)setMicrophoneDisable:(BOOL)disable;

```


*   采集运行中关闭或打开摄像头

```
/**
 采集运行中关闭或打开摄像头

 @param disable YES 关闭，否则打开
 */
- (void)setCameraDisable:(BOOL)disable;

```

* 切换前后摄像头

```
**
 切换前后摄像头
 */
- (void)switchCamera;
```

* 切换使用外放/听筒

```
/**
 切换使用外放/听筒
 */
- (void)useSpeaker:(BOOL)useSpeaker;

```

*  关闭音视频流

```
/**
 关闭音视频流

 */
- (void)stopCapture;

```

*  获取当前用户的视频截图

```
/**
 获取当前用户的视频截图

 @return 截图
 */
- (UIImage *)imageForCurrentUser;

```

*  获取除当前用户之外其他人的视频截图

```
/**
 获取除当前用户之外其他人的视频截图

 @param userId 用户 id
 @return 截图
 */
- (UIImage *)imageForOtherUser:(NSString *)userId;

```

*  更新当前用户视频截图

```
/**
 更新当前用户视频截图

 */
- (void)refreshCurrentImage;

```

### IMService 说明
---
对应于 `IMService` 文件。通过单例模式实现。主要用于课堂内收发消息，以及接收服务端下发的信令消息。

### ClassroomService 说明
---
对应于 `ClassroomService ` 文件。通过单例模式实现。所有接口调用均通过代理形式返回结果，需要设置代理监听。

*  通过实现如下代理来监听课堂人员变化

```
- (void)roomDidLeave;
- (void)memberDidJoin:(RoomMember *)member;
- (void)memberDidLeave:(RoomMember *)member;
- (void)memberDidKick:(RoomMember *)member;

```

*  除降级以外的其他角色变化

```
- (void)roleDidChange:(Role)role forUser:(RoomMember *)member;
```

*  转让助教，助教收到的回调如下。其他人员收到的是 `- (void)roleDidChange:(Role)role forUser:(RoomMember *)member` 回调。

```
- (void)assistantDidTransfer:(RoomMember *)oldAssistant newAssistant:(RoomMember *)newAssistant;

```

*  用户设备（麦克风，摄像头）的打开和关闭的回调

```
- (void)deviceDidEnable:(BOOL)enable  type:(DeviceType)type forUser:(RoomMember *)member operator:(NSString *)operatorId;

```

*  助教请求用户打开设备的回调，助教关闭用户设备没有回调。

```
- (void)deviceDidInviteEnable:(DeviceType)type ticket:(NSString *)ticket;

```

*  用户同意或者拒绝助教打开设备，助教收到的回调

```
- (void)deviceInviteEnableDidApprove:(RoomMember *)member type:(DeviceType)type;

- (void)deviceInviteEnableDidReject:(RoomMember *)member type:(DeviceType)type;

```

*  旁观者申请成为学员，助教收到的回调

```
- (void)upgradeDidApply:(RoomMember *)member ticket:(NSString *)ticket overMaxCount:(BOOL)isOver;

```

*  旁观者申请成为学员，助教接受或者拒绝申请之后，旁观者收到的回调

```
- (void)applyDidApprove;

- (void)applyDidReject;

- (void)applyDidFailed:(ErrorCode)code;

```

*  旁观者申请成为学员/助教邀请旁观者成为学员，超时没有回应的回调

```
- (void)ticketDidExpire:(NSString *)ticket;

```

*  创建白板成功，啥啊暗处白板成功之后的回调，只有创建者能收到。

```
- (void)whiteboardDidCreate:(Whiteboard *)board;
- (void)whiteboardDidDelete:(Whiteboard *)boardId;

```

*  显示白板的回调，所有人都能收到

```
- (void)whiteboardDidDisplay:(NSString *)boardId;

```

*  显示老师的回调，所有人都能收到

```
- (void)teacherDidDisplay;

```

*  显示助教的回调，所有人都能收到

```
- (void)assistantDidDisplay;

```

*  显示共享屏幕的回调，所有人都能收到

```
- (void)sharedScreenDidDisplay:(NSString *)userId;

```

*  显示空白的回调，所有人都能收到

```
- (void)noneDidDisplay;

```

*  所有操作错误的回调。

```
- (void)errorDidOccur:(ErrorCode)code;

```
