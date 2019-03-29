//
//  InviteUpgradeMessage.h
//  SealClass
//
//  Created by LiFei on 2019/3/19.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>
#import "ClassroomDefine.h"

typedef NS_ENUM(NSUInteger, InviteUpgradeAction) {
    //邀请
    InviteUpgradeActionInvite = 1,
    //拒绝
    InviteUpgradeActionReject = 2,
    //同意
    InviteUpgradeActionApprove = 3
};

NS_ASSUME_NONNULL_BEGIN

#define InviteUpgradeMessageIdentifier @"SC:IURMsg"

@interface InviteUpgradeMessage : RCMessageContent
@property (nonatomic, assign) InviteUpgradeAction action;
@property (nonatomic, assign) Role role;
@property (nonatomic, copy)   NSString *operatorId;
@property (nonatomic, copy)   NSString *operatorName;
@property (nonatomic, copy)   NSString *ticket;
@end

NS_ASSUME_NONNULL_END
