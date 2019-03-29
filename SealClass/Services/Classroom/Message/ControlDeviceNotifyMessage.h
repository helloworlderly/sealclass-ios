//
//  ControlDeviceNotifyMessage.h
//  SealClass
//
//  Created by LiFei on 2019/3/19.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>
#import "ClassroomDefine.h"

typedef NS_ENUM(NSUInteger, ControlDeviceAction) {
    //邀请
    ControlDeviceActionInvite = 1,
    //拒绝
    ControlDeviceActionReject = 2,
    //同意
    ControlDeviceActionApprove = 3
};

NS_ASSUME_NONNULL_BEGIN

#define ControlDeviceNotifyMessageIdentifier @"SC:CDNMsg"

@interface ControlDeviceNotifyMessage : RCMessageContent
@property (nonatomic, assign) ControlDeviceAction action;
@property (nonatomic, assign) DeviceType type;
@property (nonatomic, copy)   NSString *opUserId;
@property (nonatomic, copy)   NSString *opUserName;
@property (nonatomic, copy)   NSString *ticket;
@end

NS_ASSUME_NONNULL_END
