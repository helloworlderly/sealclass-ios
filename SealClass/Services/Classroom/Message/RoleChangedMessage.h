//
//  RoleChangedMessage.h
//  SealClass
//
//  Created by Sin on 2019/3/14.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

#define RoleChangedMessageIdentifier @"SC:RCMsg"

@interface RoleChangedMessage : RCMessageContent
@property (nonatomic, copy) NSString *operatorId;
@property (nonatomic, strong) NSArray <NSDictionary *>*users;//String userId;int role
@end

