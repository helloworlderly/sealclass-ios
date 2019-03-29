//
//  ApplySpeechMessage.h
//  SealClass
//
//  Created by Sin on 2019/3/14.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>
#define ApplySpeechMessageIdentifier @"SC:RSMsg"
//申请发言消息，当一个 Audience 申请发言成功之后，会收到此消息，助教需要对此消息进行处理，比如同意发言或者拒绝发言
@interface ApplySpeechMessage : RCMessageContent
@property (nonatomic, copy) NSString *requestUserId;//发起请求的用户id
@property (nonatomic, copy) NSString *requestUserName;//发起请求的用户名
@property (nonatomic, copy) NSString *ticket;//请求凭证
@end

