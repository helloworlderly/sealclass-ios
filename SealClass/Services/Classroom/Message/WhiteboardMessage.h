//
//  WhiteboardMessage.h
//  SealClass
//
//  Created by Sin on 2019/3/12.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

#define WhiteboardMessageIdentifier @"SC:WBMsg"

typedef NS_ENUM(NSUInteger, WhiteboardAction) {
    //创建
    WhiteboardActionCreate = 1,
    //删除
    WhiteboardActionDelete = 2,
};


/**
 RTC room 白板消息，由服务下发，通知端上白板的行为，如创建、删除等
 @note 该消息只能由服务下发
 */
@interface WhiteboardMessage : RCMessageContent
@property (nonatomic, copy) NSString *whiteboardId;
@property (nonatomic, copy) NSString *whiteboardName;
@property (nonatomic, assign) WhiteboardAction action;
@end

