//
//  ClassroomService.h
//  SealClass
//
//  Created by LiFei on 2019/2/27.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>
#import "Classroom.h"
#import "RoomMember.h"
#import "ErrorCode.h"
#import "ApplySpeechResultMessage.h"
#import "ClassroomDefine.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ClassroomDelegate <NSObject>
@optional
- (void)roomDidLeave;
- (void)memberDidJoin:(RoomMember *)member;
- (void)memberDidLeave:(RoomMember *)member;
- (void)memberDidKick:(RoomMember *)member;
//转让助教，助教收到的回调
- (void)assistantDidTransfer:(RoomMember *)oldAssistant newAssistant:(RoomMember *)newAssistant;
//除降级外其它角色变化
- (void)roleDidChange:(Role)role
              forUser:(RoomMember *)member;
//设备打开/关闭回调
- (void)deviceDidEnable:(BOOL)enable
                   type:(DeviceType)type
                forUser:(RoomMember *)member operator:(NSString *)operatorId;
//助教请求用户打开设备的回调，助教关闭用户设备没有回调。
- (void)deviceDidInviteEnable:(DeviceType)type ticket:(NSString *)ticket;
- (void)deviceInviteEnableDidApprove:(RoomMember *)member
                          type:(DeviceType)type;
- (void)deviceInviteEnableDidReject:(RoomMember *)member
                         type:(DeviceType)type;
//旁观者申请成为学员的回调
- (void)upgradeDidApply:(RoomMember *)member ticket:(NSString *)ticket overMaxCount:(BOOL)isOver;
//旁观者申请成为学员，助教接受或者拒绝的回调
- (void)applyDidApprove;
- (void)applyDidReject;
- (void)applyDidFailed:(ErrorCode)code;
//助教邀请旁观者成为学员的回调
- (void)upgradeDidInvite:(NSString *)ticket;
//助教邀请旁观者成为学员，旁观者接受或者拒绝的回调
- (void)inviteDidApprove:(RoomMember *)member;
- (void)inviteDidReject:(RoomMember *)member;
//旁观者申请成为学员/助教邀请旁观者成为学员，超时没有回应的回调
- (void)ticketDidExpire:(NSString *)ticket;
//只有创建者才能收到
- (void)whiteboardDidCreate:(Whiteboard *)board;
- (void)whiteboardDidDelete:(Whiteboard *)board;
//显示白板的回调
- (void)whiteboardDidDisplay:(NSString *)boardId;
//显示老师的回调
- (void)teacherDidDisplay;
//显示助教的回调
- (void)assistantDidDisplay;
//显示共享屏幕的回调
- (void)sharedScreenDidDisplay:(NSString *)userId;
//显示空白
- (void)noneDidDisplay;
//
- (void)errorDidOccur:(ErrorCode)code;
@end

@interface ClassroomService : NSObject
@property (nonatomic, strong, nullable) Classroom *currentRoom;
@property (nonatomic, weak) id<ClassroomDelegate> classroomDelegate;

+ (instancetype)sharedService;

#pragma mark - IM
- (void)registerCommandMessages;
- (BOOL)isHoldMessage:(RCMessage *)message;

#pragma mark - HTTP
- (void)joinClassroom:(NSString *)roomId
             userName:(NSString *)userName
           isAudience:(BOOL)audience
              success:(void (^)(Classroom *classroom))successBlock
                error:(void (^)(ErrorCode errorCode))errorBlock;
- (void)leaveClassroom;
- (void)getWhiteboardList:(void (^)( NSArray <Whiteboard *> * _Nullable boardList))completeBlock;

#pragma mark 角色权限相关，仅助教有权限
//将学员降级为旁观者
- (void)downgradeMembers:(NSArray <NSString *> *)members;
//邀请旁观者升级为学员
- (void)inviteUpgrade:(NSString *)userId;
//指定学员为老师
- (void)assignTeacher:(NSString *)userId;
//转让助教
- (void)transferAssistant:(NSString *)userId;
//同意旁观者升级为学员（对应 applyUpgrade）
- (void)approveUpgrade:(NSString *)ticket;
//拒绝旁观者升级为学员（对应 applyUpgrade）
- (void)rejectUpgrade:(NSString *)ticket;
- (void)kickMember:(NSString *)userId;
- (void)enableDevice:(BOOL)enable
                type:(DeviceType)type
             forUser:(NSString *)userId;
#pragma mark 教室显示相关，仅助教/老师有权限
- (void)createWhiteboard;
- (void)deleteWhiteboard:(NSString *)boardId;
- (void)displayWhiteboard:(NSString *)boardId;
- (void)displayTeacher;
- (void)displayAssistant;
#pragma mark 操作当前用户设备状态，仅助教/老师/学员有权限
- (void)enableDevice:(BOOL)enable
            withType:(DeviceType)type;
//用户同意助教打开设备
- (void)approveEnableDevice:(NSString *)ticket;
//用户拒绝助教打开设备
- (void)rejectEnableDevice:(NSString *)ticket;
#pragma mark 旁观者升级相关，仅旁观者有权限
//申请成为学员
- (void)applyUpgrade;
//同意助教邀请自己成为学员（对应 inviteUpgrade）
- (void)approveInvite:(NSString *)ticket;
//拒绝助教邀请自己成为学员（对应 inviteUpgrade）
- (void)rejectInvite:(NSString *)ticket;
#pragma mark - Util
- (NSString *)generateWhiteboardURL:(NSString *)boardId;
@end

NS_ASSUME_NONNULL_END
