//
//  AssistantTransferMessage.h
//  SealClass
//
//  Created by Sin on 2019/3/14.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

#define AssistantTransferMessageIdentifier @"SC:ATMsg"
//助教变更消息，当助教变成功变更为另一个人时触发
@interface AssistantTransferMessage : RCMessageContent
@property (nonatomic, copy) NSString *operatorId;
@property (nonatomic, copy) NSString *toUserId;
@end


