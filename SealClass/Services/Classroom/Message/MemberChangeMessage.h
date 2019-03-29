//
//  MemberChangeMessage.h
//  SealClass
//
//  Created by Sin on 2019/3/12.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

#define MemberChangeMessageIdentifier @"SC:RMCMsg"

typedef NS_ENUM(NSUInteger, MemberChangeAction) {
    //加入
    MemberChangeActionJoin = 1,
    //离开
    MemberChangeActionLeave = 2,
    //被踢掉线
    MemberChangeActionKick = 3,
};

/**
 RTC room 命令消息，由服务下发，通知端上特定用户的行为，如加入、离开、被踢等
 @note 该消息只能由服务下发
 */
@interface MemberChangeMessage : RCMessageContent
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, assign) MemberChangeAction action;
@property (nonatomic, assign) int role;
@property (nonatomic, assign) long timestamp;
@end

