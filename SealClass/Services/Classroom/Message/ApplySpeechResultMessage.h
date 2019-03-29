//
//  ApplySpeechResultMessage.h
//  SealClass
//
//  Created by Sin on 2019/3/14.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

typedef NS_ENUM(NSUInteger, SpeechResultAction) {
    //同意
    SpeechResultApprove = 1,
    //拒绝
    SpeechResultReject = 2,
};

#define SpeechResultMessageIdentifier @"SC:SRMsg"

//请求发言的结果消息，可能助教同意或者拒绝
@interface ApplySpeechResultMessage : RCMessageContent
@property (nonatomic, copy) NSString *operatorId;
@property (nonatomic, copy) NSString *operatorName;
@property (nonatomic, assign) SpeechResultAction action;
@end
