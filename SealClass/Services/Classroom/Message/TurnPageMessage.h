//
//  TurnPageMessage.h
//  SealClass
//
//  Created by Sin on 2019/3/15.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

#define TurnPageMessageIdentifier @"SC:WBMsg"

//白板切换页面消息
@interface TurnPageMessage : RCMessageContent
@property (nonatomic, copy) NSString *whiteboardId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, assign) int currentPage;
@end

