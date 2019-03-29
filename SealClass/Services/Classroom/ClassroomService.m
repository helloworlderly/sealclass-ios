//
//  ClassroomService.m
//  SealClass
//
//  Created by LiFei on 2019/2/27.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "ClassroomService.h"
#import "HTTPUtility.h"
#import "MemberChangeMessage.h"
#import "WhiteboardMessage.h"
#import "DeviceMessage.h"
#import "DisplayCommandMessage.h"
#import "MemberChangeMessage.h"
#import "TurnPageMessage.h"
#import "RoleChangedMessage.h"
#import "AssistantTransferMessage.h"
#import "ApplySpeechMessage.h"
#import "TicketExpiredMessage.h"
#import "InviteUpgradeMessage.h"
#import "ControlDeviceNotifyMessage.h"

@interface ClassroomService ()
@property (nonatomic, copy) NSString *auth;
@end

@implementation ClassroomService

+ (instancetype)sharedService {
    static ClassroomService *service;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[ClassroomService alloc] init];
    });
    return service;
}

#pragma mark - IM
- (void)registerCommandMessages {
    [IMClient registerMessageType:[MemberChangeMessage class]];
    [IMClient registerMessageType:[WhiteboardMessage class]];
    [IMClient registerMessageType:[DeviceMessage class]];
    [IMClient registerMessageType:[DisplayCommandMessage class]];
    [IMClient registerMessageType:[TurnPageMessage class]];
    [IMClient registerMessageType:[RoleChangedMessage class]];
    [IMClient registerMessageType:[AssistantTransferMessage class]];
    [IMClient registerMessageType:[ApplySpeechMessage class]];
    [IMClient registerMessageType:[ApplySpeechResultMessage class]];
    [IMClient registerMessageType:[TicketExpiredMessage class]];
    [IMClient registerMessageType:[InviteUpgradeMessage class]];
    [IMClient registerMessageType:[ControlDeviceNotifyMessage class]];
}

- (BOOL)isHoldMessage:(RCMessage *)message {
    BOOL needHold = NO;
    if ([message.content isKindOfClass:[MemberChangeMessage class]]) {
        needHold = NO;
        [self onReceiveCommandMessage:(MemberChangeMessage*)message.content];
    } else if ([message.content isKindOfClass:[WhiteboardMessage class]]) {
        needHold = YES;
        [self onReceiveWhiteboardMessage:(WhiteboardMessage*)message.content];
    } else if ([message.content isKindOfClass:[DeviceMessage class]]) {
        needHold = YES;
        [self onReceiveDeviceMessage:(DeviceMessage*)message.content withSenderId:message.senderUserId];
    } else if([message.content isKindOfClass:[DisplayCommandMessage class]]) {
        needHold = YES;
        [self onReceiveDisplayCommandMessage:(DisplayCommandMessage*)message.content];
    } else if([message.content isKindOfClass:[ApplySpeechMessage class]]) {
        needHold = YES;
        [self onReceiveApplySpeechMessage:(ApplySpeechMessage*)message.content];
    } else if([message.content isKindOfClass:[TurnPageMessage class]]) {
        needHold = YES;
        [self onReceiveTurnPageMessage:(TurnPageMessage*)message.content];
    } else if([message.content isKindOfClass:[RoleChangedMessage class]]) {
        needHold = YES;
        [self onReceiveRoleChangedMessage:(RoleChangedMessage*)message.content];
    } else if([message.content isKindOfClass:[AssistantTransferMessage class]]) {
        needHold = YES;
        [self onReceiveAssistantTransferMessage:(AssistantTransferMessage*)message.content];
    } else if([message.content isKindOfClass:[ApplySpeechResultMessage class]]) {
        needHold = YES;
        [self onReceiveSpeechResultMessage:(ApplySpeechResultMessage*)message.content];
    } else if ([message.content isKindOfClass:[TicketExpiredMessage class]]) {
        needHold = YES;
        [self onReceiveTicketExpiredMessage:(TicketExpiredMessage *)message.content];
    } else if ([message.content isKindOfClass:[InviteUpgradeMessage class]]) {
        needHold = YES;
        [self onReceiveInviteUpgradeMessage:(InviteUpgradeMessage *)message.content];
    } else if ([message.content isKindOfClass:[ControlDeviceNotifyMessage class]]) {
        needHold = YES;
        [self onReceiveControlDeviceNotifyMessage:(ControlDeviceNotifyMessage *)message.content];
    }
    return needHold;
}

#pragma mark - HTTP

- (void)joinClassroom:(NSString *)roomId
             userName:(NSString *)userName
           isAudience:(BOOL)audience
              success:(nonnull void (^)(Classroom * _Nonnull))successBlock
                error:(nonnull void (^)(ErrorCode))errorBlock {
    if (roomId.length == 0 || userName.length == 0) {
        [self callbackFailureDescription:ErrorCodeParameterError];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:roomId forKey:@"roomId"];
    [dic setObject:@(audience) forKey:@"audience"];
    [dic setObject:userName forKey:@"userName"];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost
                             URLString:@"/room/join"
                            parameters:dic
                              response:^(HTTPResult *result) {
                                  if (result.success) {
                                      NSDictionary *resultDic = result.content[@"result"];
                                      self.auth = resultDic[@"authorization"];
                                      [HTTPUtility setAuthHeader:self.auth];
                                      Classroom *room = [Classroom classroomFromJson:resultDic];
                                      self.currentRoom = room;
                                      if (successBlock) {
                                          dispatch_main_async_safe(^{
                                              successBlock(room);
                                          })
                                      }
                                  } else {
                                      if (errorBlock) {
                                          dispatch_main_async_safe(^{
                                              errorBlock(result.errorCode);
                                          })
                                      }
                                  }
                              }];
}

- (void)leaveClassroom {
    if (![self checkWhetherInRoom]) {
        [self callbackFailureDescription:ErrorCodeUserNotExistInRoom];
        return;
    }
    NSLog(@"leave classroom start");
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.currentRoom.roomId, @"roomId", nil];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost
                             URLString:@"/room/leave"
                            parameters:dic
                              response:^(HTTPResult *result) {
                                  SealClassLog(@"离开 ClassRoomService code = %ld",(long)result.httpCode);
                                  if (result.success) {
//                                      [HTTPUtility setAuthHeader:nil];
                                      self.currentRoom = nil;
                                      dispatch_main_async_safe(^{
                                          if ([self.classroomDelegate respondsToSelector:@selector(roomDidLeave)]) {
                                              [self.classroomDelegate roomDidLeave];
                                          }
                                      });
                                  } else {
                                      [self callbackFailureDescription:result.errorCode];
                                  }
                              }];
}

- (void)getWhiteboardList:(void (^)(NSArray<Whiteboard *> * _Nullable))completeBlock {
    if (![self checkWhetherInRoom]) {
        [self callbackFailureDescription:ErrorCodeUserNotExistInRoom];
        if (completeBlock) {
            completeBlock(nil);
        }
        return;
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.currentRoom.roomId, @"roomId", nil];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodGet
                             URLString:@"/room/whiteboard/list"
                            parameters:dic
                              response:^(HTTPResult *result) {
                                  if (result.success) {
                                      NSMutableArray *boardList = [[NSMutableArray alloc] init];
                                      NSArray *arr = result.content[@"result"];
                                      for (NSDictionary *boardDic in arr) {
                                          Whiteboard *board = [Whiteboard whiteboardFromJson:boardDic];
                                          [boardList addObject:board];
                                      }
                                      if (completeBlock) {
                                          dispatch_main_async_safe(^{
                                              completeBlock(boardList);
                                          });
                                      }
                                  } else {
                                      if (completeBlock) {
                                          dispatch_main_async_safe(^{
                                              completeBlock(nil);
                                          });
                                      }
                                  }
                              }];
}

#pragma mark 角色权限相关，仅助教有权限
- (void)downgradeMembers:(NSArray <NSString *> *)members {
    if (![self checkWhetherInRoom]) {
        [self callbackFailureDescription:ErrorCodeUserNotExistInRoom];
        return;
    }
    if (members.count < 1) {
        [self callbackFailureDescription:ErrorCodeParameterError];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:self.currentRoom.roomId forKey:@"roomId"];
    NSMutableArray *users = [[NSMutableArray alloc] init];
    for (NSString *userId in members) {
        if (userId.length > 0) {
            [users addObject:@{@"userId":userId,@"role":@(RoleAudience)}];
        }
    }
    [dic setObject:users forKey:@"users"];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost URLString:@"/room/downgrade" parameters:dic response:^(HTTPResult *result) {
        if(result.success) {
        }else {
            [self callbackFailureDescription:result.errorCode];
        }
    }];
}

- (void)inviteUpgrade:(NSString *)userId {
    if (![self checkWhetherInRoom]) {
        [self callbackFailureDescription:ErrorCodeUserNotExistInRoom];
        return;
    }
    if (userId.length == 0) {
        [self callbackFailureDescription:ErrorCodeParameterError];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:self.currentRoom.roomId forKey:@"roomId"];
    [dic setObject:userId forKey:@"userId"];
    [dic setObject:@(RoleStudent) forKey:@"role"];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost
                             URLString:@"/room/upgrade/invite"
                            parameters:dic
                              response:^(HTTPResult *result) {
                                  if (result.success) {
                                  } else {
                                      [self callbackFailureDescription:result.errorCode];
                                  }
                              }];
}

- (void)assignTeacher:(NSString *)userId {
    if (![self checkWhetherInRoom]) {
        [self callbackFailureDescription:ErrorCodeUserNotExistInRoom];
        return;
    }
    if (userId.length == 0) {
        [self callbackFailureDescription:ErrorCodeParameterError];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:self.currentRoom.roomId forKey:@"roomId"];
    [dic setObject:userId forKey:@"userId"];
    [dic setObject:@(RoleTeacher) forKey:@"role"];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost URLString:@"/room/change-role" parameters:dic response:^(HTTPResult *result) {
        if(result.success){
        }else {
            [self callbackFailureDescription:result.errorCode];
        }
    }];
}

- (void)transferAssistant:(NSString *)userId {
    if (![self checkWhetherInRoom]) {
        [self callbackFailureDescription:ErrorCodeUserNotExistInRoom];
        return;
    }
    if (userId.length == 0) {
        [self callbackFailureDescription:ErrorCodeParameterError];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:self.currentRoom.roomId forKey:@"roomId"];
    [dic setObject:userId forKey:@"userId"];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost URLString:@"/room/transfer" parameters:dic response:^(HTTPResult *result) {
        if(result.success){
        }else {
            [self callbackFailureDescription:result.errorCode];
        }
    }];
}

- (void)approveUpgrade:(NSString *)ticket{
    if (![self checkWhetherInRoom]) {
        [self callbackFailureDescription:ErrorCodeUserNotExistInRoom];
        return;
    }
    if (ticket.length == 0) {
        [self callbackFailureDescription:ErrorCodeParameterError];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:self.currentRoom.roomId forKey:@"roomId"];
    [dic setObject:ticket forKey:@"ticket"];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost URLString:@"/room/speech/approve" parameters:dic response:^(HTTPResult *result) {
        if(result.success){
        }else {
            [self callbackFailureDescription:result.errorCode];
        }
    }];
}

- (void)rejectUpgrade:(NSString *)ticket {
    if (![self checkWhetherInRoom]) {
        [self callbackFailureDescription:ErrorCodeUserNotExistInRoom];
        return;
    }
    if (ticket.length == 0) {
        [self callbackFailureDescription:ErrorCodeParameterError];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:self.currentRoom.roomId forKey:@"roomId"];
    [dic setObject:ticket forKey:@"ticket"];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost URLString:@"/room/speech/reject" parameters:dic response:^(HTTPResult *result) {
        if(result.success){
        }else {
            [self callbackFailureDescription:result.errorCode];
        }
    }];
}

- (void)kickMember:(NSString *)userId {
    if (![self checkWhetherInRoom]) {
        [self callbackFailureDescription:ErrorCodeUserNotExistInRoom];
        return;
    }
    if (userId.length == 0) {
        [self callbackFailureDescription:ErrorCodeParameterError];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:self.currentRoom.roomId forKey:@"roomId"];
    [dic setObject:userId forKey:@"userId"];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost
                             URLString:@"/room/kick"
                            parameters:dic
                              response:^(HTTPResult *result) {
                                  if (result.success) {
                                  } else {
                                      [self callbackFailureDescription:result.errorCode];
                                  }
                              }];
}

- (void)enableDevice:(BOOL)enable
                type:(DeviceType)type
             forUser:(NSString *)userId {
    if (![self checkWhetherInRoom]) {
        [self callbackFailureDescription:ErrorCodeUserNotExistInRoom];
        return;
    }
    if (userId.length == 0) {
        [self callbackFailureDescription:ErrorCodeParameterError];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:self.currentRoom.roomId forKey:@"roomId"];
    if(DeviceTypeCamera == type) {
        [dic setObject:@(enable) forKey:@"cameraOn"];
    }else {
        [dic setObject:@(enable) forKey:@"microphoneOn"];
    }
    [dic setObject:userId forKey:@"userId"];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost
                             URLString:@"/room/device/control"
                            parameters:dic
                              response:^(HTTPResult *result) {
                                  if (result.success) {
                                      
                                  } else {
                                      [self callbackFailureDescription:result.errorCode];
                                  }
                              }];
}

#pragma mark 教室显示相关，仅助教/老师有权限
- (void)createWhiteboard {
    if (![self checkWhetherInRoom]) {
        [self callbackFailureDescription:ErrorCodeUserNotExistInRoom];
        return;
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.currentRoom.roomId, @"roomId", nil];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost
                             URLString:@"/room/whiteboard/create"
                            parameters:dic
                              response:^(HTTPResult *result) {
                                  if (result.success) {
                                      Whiteboard *board = [[Whiteboard alloc] init];
                                      board.boardId = result.content[@"result"];
                                      dispatch_main_async_safe(^{
                                          if ([self.classroomDelegate respondsToSelector:@selector(whiteboardDidCreate:)]) {
                                              [self.classroomDelegate whiteboardDidCreate:board];
                                          }
                                      });
                                  } else {
                                      [self callbackFailureDescription:result.errorCode];
                                  }
                              }];
}

- (void)deleteWhiteboard:(NSString *)boardId {
    if (![self checkWhetherInRoom]) {
        [self callbackFailureDescription:ErrorCodeUserNotExistInRoom];
        return;
    }
    if (boardId.length == 0) {
        [self callbackFailureDescription:ErrorCodeParameterError];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:self.currentRoom.roomId forKey:@"roomId"];
    [dic setObject:boardId forKey:@"whiteboardId"];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost
                             URLString:@"/room/whiteboard/delete"
                            parameters:dic
                              response:^(HTTPResult *result) {
                                  if (result.success) {
                                      
                                  } else {
                                      [self callbackFailureDescription:result.errorCode];
                                  }
                              }];
}

- (void)display:(DisplayType)type
       withInfo:(NSString *)info {
    if (![self checkWhetherInRoom]) {
        [self callbackFailureDescription:ErrorCodeUserNotExistInRoom];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:self.currentRoom.roomId forKey:@"roomId"];
    [dic setObject:@(type) forKey:@"type"];
    if (type == DisplayWhiteboard) {
        [dic setObject:info forKey:@"uri"];
    } else {
        [dic setObject:info forKey:@"userId"];
    }
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost
                             URLString:@"/room/display"
                            parameters:dic
                              response:^(HTTPResult *result) {
                                  if (result.success) {
                                      self.currentRoom.currentDisplayType = type;
                                      self.currentRoom.currentDisplayURI = info;
                                  } else {
                                      [self callbackFailureDescription:result.errorCode];
                                  }
                              }];
}

- (void)displayWhiteboard:(NSString *)boardId {
    if (boardId.length == 0) {
        [self callbackFailureDescription:ErrorCodeParameterError];
        return;
    }
    [self display:DisplayWhiteboard withInfo:boardId];
}

- (void)displayTeacher {
    [self display:DisplayTeacher withInfo:self.currentRoom.teacher.userId];
}

- (void)displayAssistant {
    [self display:DisplayAssistant withInfo:self.currentRoom.assistant.userId];
}

#pragma mark 操作当前用户设备状态，仅助教/老师/学员有权限
- (void)enableDevice:(BOOL)enable
            withType:(DeviceType)type {
    if (![self checkWhetherInRoom]) {
        [self callbackFailureDescription:ErrorCodeUserNotExistInRoom];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:self.currentRoom.roomId forKey:@"roomId"];
    if (type == DeviceTypeCamera) {
        [dic setObject:@(enable) forKey:@"cameraOn"];
    } else if (type == DeviceTypeMicrophone) {
        [dic setObject:@(enable) forKey:@"microphoneOn"];
    }
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost
                             URLString:@"/room/device/sync"
                            parameters:dic
                              response:^(HTTPResult *result) {
                                  if (result.success) {
                                      if (type == DeviceTypeMicrophone) {
                                          [self.currentRoom updateMember:self.currentRoom.currentMember.userId forMicrophone:enable];
                                      } else if (type == DeviceTypeCamera)  {
                                          [self.currentRoom updateMember:self.currentRoom.currentMember.userId forCamera:enable];
                                      }
                                  } else {
                                      [self callbackFailureDescription:result.errorCode];
                                  }
                              }];
}

- (void)approveEnableDevice:(NSString *)ticket {
    if (![self checkWhetherInRoom]) {
        [self callbackFailureDescription:ErrorCodeUserNotExistInRoom];
        return;
    }
    if (ticket.length == 0) {
        [self callbackFailureDescription:ErrorCodeParameterError];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:self.currentRoom.roomId forKey:@"roomId"];
    [dic setObject:ticket forKey:@"ticket"];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost
                             URLString:@"/room/device/approve"
                            parameters:dic
                              response:^(HTTPResult *result) {
                                  if (result.success) {
                                      
                                  } else {
                                      [self callbackFailureDescription:result.errorCode];
                                  }
                              }];
}

- (void)rejectEnableDevice:(NSString *)ticket  {
    if (![self checkWhetherInRoom]) {
        [self callbackFailureDescription:ErrorCodeUserNotExistInRoom];
        return;
    }
    if (ticket.length == 0) {
        [self callbackFailureDescription:ErrorCodeParameterError];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:self.currentRoom.roomId forKey:@"roomId"];
    [dic setObject:ticket forKey:@"ticket"];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost
                             URLString:@"/room/device/reject"
                            parameters:dic
                              response:^(HTTPResult *result) {
                                  if (result.success) {
                                      
                                  } else {
                                      [self callbackFailureDescription:result.errorCode];
                                  }
                              }];
}

#pragma mark 旁观者升级相关，仅旁观者有权限
- (void)applyUpgrade {
    if (![self checkWhetherInRoom]) {
        [self callbackFailureDescription:ErrorCodeUserNotExistInRoom];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:self.currentRoom.roomId forKey:@"roomId"];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost
                             URLString:@"/room/speech/apply"
                            parameters:dic
                              response:^(HTTPResult *result) {
                                  if (result.success) {
                                      
                                  } else {
                                      dispatch_main_async_safe(^{
                                          if ([self.classroomDelegate respondsToSelector:@selector(applyDidFailed:)]) {
                                              [self.classroomDelegate applyDidFailed:result.errorCode];
                                          }
                                      });
                                  }
                              }];
}

- (void)approveInvite:(NSString *)ticket {
    if (![self checkWhetherInRoom]) {
        [self callbackFailureDescription:ErrorCodeUserNotExistInRoom];
        return;
    }
    if (ticket.length == 0) {
        [self callbackFailureDescription:ErrorCodeParameterError];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:self.currentRoom.roomId forKey:@"roomId"];
    [dic setObject:ticket forKey:@"ticket"];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost
                             URLString:@"/room/upgrade/approve"
                            parameters:dic
                              response:^(HTTPResult *result) {
                                  if (result.success) {
                                      
                                  } else {
                                      [self callbackFailureDescription:result.errorCode];
                                  }
                              }];
}

- (void)rejectInvite:(NSString *)ticket {
    if (![self checkWhetherInRoom]) {
        [self callbackFailureDescription:ErrorCodeUserNotExistInRoom];
        return;
    }
    if (ticket.length == 0) {
        [self callbackFailureDescription:ErrorCodeParameterError];
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:self.currentRoom.roomId forKey:@"roomId"];
    [dic setObject:ticket forKey:@"ticket"];
    [HTTPUtility requestWithHTTPMethod:HTTPMethodPost
                             URLString:@"/room/upgrade/reject"
                            parameters:dic
                              response:^(HTTPResult *result) {
                                  if (result.success) {
                                      
                                  } else {
                                      [self callbackFailureDescription:result.errorCode];
                                  }
                              }];
}

#pragma mark - Util
- (NSString *)generateWhiteboardURL:(NSString *)boardId {
    if (![self checkWhetherInRoom]) {
        return nil;
    }
    Role role = self.currentRoom.currentMember.role;
    NSString *roomId = self.currentRoom.roomId;
    return [NSString stringWithFormat:@"%@&role=%@&roomId=%@&authorization=%@", boardId, @(role), roomId, self.auth];
}

#pragma mark - Helper
- (BOOL)checkWhetherInRoom {
    return self.currentRoom.roomId.length > 0;
}

- (void)callbackFailureDescription:(ErrorCode)code {
    dispatch_main_async_safe(^{
        if ([self.classroomDelegate respondsToSelector:@selector(errorDidOccur:)]) {
            [self.classroomDelegate errorDidOccur:code];
        }
    });
}

- (void)onReceiveCommandMessage:(MemberChangeMessage *)msg{
    dispatch_main_async_safe(^{
        if(msg.action == MemberChangeActionJoin) {
            if([self.classroomDelegate respondsToSelector:@selector(memberDidJoin:)]) {
                RoomMember *mem = [[RoomMember alloc] init];
                mem.userId = msg.userId;
                mem.name = msg.userName;
                mem.role = (Role)msg.role;
                mem.joinTime = msg.timestamp;
                mem.cameraEnable = YES;
                mem.microphoneEnable = YES;
                if ([self.currentRoom addMemeber:mem]) {
                    [self.classroomDelegate memberDidJoin:mem];
                }
            }
        }else if(msg.action == MemberChangeActionLeave){
            if([self.classroomDelegate respondsToSelector:@selector(memberDidLeave:)]) {
                RoomMember *mem = [[RoomMember alloc] init];
                mem.userId = msg.userId;
                mem.name = msg.userName;
                mem.role = (Role)msg.role;
                mem.joinTime = msg.timestamp;
                if([self.currentRoom removeMemeber:mem]) {                
                    [self.classroomDelegate memberDidLeave:mem];
                }
            }
        }else if(msg.action == MemberChangeActionKick) {
            if ([msg.userId isEqualToString:self.currentRoom.currentMember.userId]) {
                if ([self.classroomDelegate respondsToSelector:@selector(roomDidLeave)]) {
                    [self.classroomDelegate roomDidLeave];
                }
                self.currentRoom = nil;
            } else {
                RoomMember *mem = [self.currentRoom getMember:msg.userId];
                [self.currentRoom removeMemeber:mem];
                if([self.classroomDelegate respondsToSelector:@selector(memberDidKick:)]) {
                    [self.classroomDelegate memberDidKick:mem];
                }
            }
        }
    });
}

- (void)onReceiveWhiteboardMessage:(WhiteboardMessage *)msg{
    dispatch_main_async_safe(^{
        if(WhiteboardActionCreate == msg.action) {
            if([self.classroomDelegate respondsToSelector:@selector(whiteboardDidCreate:)]) {
                Whiteboard *wBoard = [[Whiteboard alloc] init];
                wBoard.boardId = msg.whiteboardId;
                wBoard.name = msg.whiteboardName;
                [self.classroomDelegate whiteboardDidCreate:wBoard];
            }
        }else if (WhiteboardActionDelete == msg.action) {
            if([self.classroomDelegate respondsToSelector:@selector(whiteboardDidDelete:)]) {
                Whiteboard *wBoard = [[Whiteboard alloc] init];
                wBoard.boardId = msg.whiteboardId;
                wBoard.name = msg.whiteboardName;
                [self.classroomDelegate whiteboardDidDelete:wBoard];
            }
        }
    });
}

- (void)onReceiveDeviceMessage:(DeviceMessage *)msg withSenderId:(NSString *)senderId{
    dispatch_main_async_safe(^{
        if (msg.type == DeviceTypeCamera) {
            [self.currentRoom updateMember:msg.userId forCamera:msg.enable];
            if ([self.classroomDelegate respondsToSelector:@selector(deviceDidEnable:type:forUser:operator:)]) {
                [self.classroomDelegate deviceDidEnable:msg.enable type:DeviceTypeCamera forUser:[self.currentRoom getMember:msg.userId] operator:senderId];
            }
        } else if (msg.type == DeviceTypeMicrophone) {
            [self.currentRoom updateMember:msg.userId forMicrophone:msg.enable];
            if ([self.classroomDelegate respondsToSelector:@selector(deviceDidEnable:type:forUser:operator:)]) {
                [self.classroomDelegate deviceDidEnable:msg.enable type:DeviceTypeMicrophone forUser:[self.currentRoom getMember:msg.userId] operator:senderId];
            }
        }
    });
}

- (void)onReceiveDisplayCommandMessage:(DisplayCommandMessage *)msg{
    dispatch_main_async_safe(^{
        [self.currentRoom updateDisplayUri:msg.display];
        DisplayType type = self.currentRoom.currentDisplayType;
        if (type == DisplayAssistant) {
            if ([self.classroomDelegate respondsToSelector:@selector(assistantDidDisplay)]) {
                [self.classroomDelegate assistantDidDisplay];
            }
        } else if (type == DisplayTeacher) {
            if ([self.classroomDelegate respondsToSelector:@selector(teacherDidDisplay)]) {
                [self.classroomDelegate teacherDidDisplay];
            }
        } else if (type == DisplayWhiteboard) {
            if ([self.classroomDelegate respondsToSelector:@selector(whiteboardDidDisplay:)]) {
                [self.classroomDelegate whiteboardDidDisplay:self.currentRoom.currentDisplayURI];
            }
        } else if (type == DisplaySharedScreen) {
            if ([self.classroomDelegate respondsToSelector:@selector(sharedScreenDidDisplay:)]) {
                [self.classroomDelegate sharedScreenDidDisplay:self.currentRoom.currentDisplayURI];
            }
        } else if (type == DisplayNone) {
            if ([self.classroomDelegate respondsToSelector:@selector(noneDidDisplay)]) {
                [self.classroomDelegate noneDidDisplay];
            }
        }
    });
}

- (void)onReceiveApplySpeechMessage:(ApplySpeechMessage *)msg {
    dispatch_main_async_safe(^{
        if (self.currentRoom.currentMember.role == RoleAssistant) {
            if ([self.classroomDelegate respondsToSelector:@selector(upgradeDidApply:ticket:overMaxCount:)]) {
                RoomMember *mem = [self.currentRoom getMember:msg.requestUserId];
                if(!mem) {
                    mem = [[RoomMember alloc] init];
                    mem.userId = msg.requestUserId;
                    mem.name = msg.requestUserName;
                }
                BOOL isMaxCount = [self.currentRoom getMemberCountWithoutAudience] >= 16 ? YES : NO;
                [self.classroomDelegate upgradeDidApply:mem ticket:msg.ticket overMaxCount:isMaxCount];
            }
        }
    });
}

- (void)onReceiveSpeechResultMessage:(ApplySpeechResultMessage *)msg {
    dispatch_main_async_safe(^{
        if (msg.action == SpeechResultApprove) {
            if ([self.classroomDelegate respondsToSelector:@selector(applyDidApprove)]) {
                [self.classroomDelegate applyDidApprove];
            }
        } else if (msg.action == SpeechResultReject) {
            if ([self.classroomDelegate respondsToSelector:@selector(applyDidReject)]) {
                [self.classroomDelegate applyDidReject];
            }
        }
    });
}

- (void)onReceiveTurnPageMessage:(TurnPageMessage *)msg {
    dispatch_main_async_safe(^{
        
    });
}

- (void)onReceiveRoleChangedMessage:(RoleChangedMessage *)msg {
    dispatch_main_async_safe(^{
        for(NSDictionary *dic in msg.users) {
            NSString *userId = dic[@"userId"];
            Role role = (Role)[dic[@"role"] intValue];
            if([self.classroomDelegate respondsToSelector:@selector(roleDidChange:forUser:)]) {
                [self.currentRoom updateMemeber:userId forRole:role];
                [self.classroomDelegate roleDidChange:role forUser:[self.currentRoom getMember:userId]];
            }
        }
    });
}

- (void)onReceiveAssistantTransferMessage:(AssistantTransferMessage *)msg {
    dispatch_main_async_safe(^{
        if([self.classroomDelegate respondsToSelector:@selector(roleDidChange:forUser:)]) {
            [self.currentRoom updateMemeber:msg.toUserId forRole:RoleAssistant];
            [self.currentRoom updateMemeber:msg.operatorId forRole:RoleStudent];
            [self.classroomDelegate roleDidChange:RoleAssistant forUser:[self.currentRoom getMember:msg.toUserId]];
//            [self.classroomDelegate roleDidChange:RoleStudent forUser:[self.currentRoom getMember:msg.operatorId]];
        }
        if ([self.classroomDelegate respondsToSelector:@selector(assistantDidTransfer:newAssistant:)]){
            [self.classroomDelegate assistantDidTransfer:[self.currentRoom getMember:msg.operatorId] newAssistant:[self.currentRoom getMember:msg.toUserId]];
        }
    });
}

- (void)onReceiveTicketExpiredMessage:(TicketExpiredMessage *)msg {
    dispatch_main_async_safe(^{
        if ([self.classroomDelegate respondsToSelector:@selector(ticketDidExpire:)]) {
            [self.classroomDelegate ticketDidExpire:msg.ticket];
        }
    });
}

- (void)onReceiveInviteUpgradeMessage:(InviteUpgradeMessage *)msg {
    dispatch_main_async_safe(^{
        if (msg.action == InviteUpgradeActionInvite) {
            if (self.currentRoom.currentMember.role == RoleAudience) {
                if ([self.classroomDelegate respondsToSelector:@selector(upgradeDidInvite:)]) {
                    [self.classroomDelegate upgradeDidInvite:msg.ticket];
                }
            }
        } else if (msg.action == InviteUpgradeActionApprove) {
            if (self.currentRoom.currentMember.role == RoleAssistant) {
                if ([self.classroomDelegate respondsToSelector:@selector(inviteDidApprove:)]) {
                    RoomMember *mem = [self.currentRoom getMember:msg.operatorId];
                    if(!mem) {
                        mem = [[RoomMember alloc] init];
                        mem.userId = msg.operatorId;
                        mem.name = msg.operatorName;
                    }
                    mem.role = msg.role;
                    [self.classroomDelegate inviteDidApprove:mem];
                }
            }
        } else if (msg.action == InviteUpgradeActionReject) {
            if (self.currentRoom.currentMember.role == RoleAssistant) {
                if ([self.classroomDelegate respondsToSelector:@selector(inviteDidReject:)]) {
                    RoomMember *mem = [self.currentRoom getMember:msg.operatorId];
                    if(!mem) {
                        mem = [[RoomMember alloc] init];
                        mem.userId = msg.operatorId;
                        mem.name = msg.operatorName;
                    }
                    [self.classroomDelegate inviteDidReject:mem];
                }
            }
        }
    });
}

- (void)onReceiveControlDeviceNotifyMessage:(ControlDeviceNotifyMessage *)msg {
    dispatch_main_async_safe(^{
        if (msg.action == ControlDeviceActionInvite) {
            if ([self.classroomDelegate respondsToSelector:@selector(deviceDidInviteEnable:ticket:)]) {
                [self.classroomDelegate deviceDidInviteEnable:msg.type ticket:msg.ticket];
            }
        } else if (msg.action == ControlDeviceActionApprove) {
            if (self.currentRoom.currentMember.role == RoleAssistant) {
                if ([self.classroomDelegate respondsToSelector:@selector(deviceInviteEnableDidApprove:type:)]) {
                    RoomMember *mem = [self.currentRoom getMember:msg.opUserId];
                    [self.classroomDelegate deviceInviteEnableDidApprove:mem type:msg.type];
                }
            }
        } else if (msg.action == ControlDeviceActionReject) {
            if (self.currentRoom.currentMember.role == RoleAssistant) {
                if ([self.classroomDelegate respondsToSelector:@selector(deviceInviteEnableDidReject:type:)]) {
                    RoomMember *mem = [self.currentRoom getMember:msg.opUserId];
                    [self.classroomDelegate deviceInviteEnableDidReject:mem type:msg.type];
                }
            }
        }
    });
}

@end
